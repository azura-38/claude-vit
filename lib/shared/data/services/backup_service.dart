import 'dart:convert';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:isolate';

import '../../../core/utils/uid_manager.dart';
import '../datasources/sembast_database.dart';

class BackupManifest {
  final int version;
  final String scope;
  final String deviceUid;
  final List<String> includes;

  const BackupManifest({
    required this.version,
    required this.scope,
    required this.deviceUid,
    required this.includes,
  });

  Map<String, dynamic> toJson() => {
    'version': version,
    'scope': scope,
    'device_uid': deviceUid,
    'includes': includes,
  };

  factory BackupManifest.fromJson(Map<String, dynamic> json) {
    return BackupManifest(
      version: json['version'] as int? ?? 1,
      scope: json['scope'] as String? ?? 'same_device_only',
      deviceUid: json['device_uid'] as String? ?? '',
      includes:
          (json['includes'] as List<dynamic>? ?? const [])
              .map((item) => item.toString())
              .toList(),
    );
  }
}

class BackupService {
  static const String backupFileName = '.vitacase_backup.zip';

  /// Collects the database file and documents directory into a single ZIP file.
  /// Runs in a background isolate to prevent UI jank.
  Future<String> exportBackup() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final tempDir = await getTemporaryDirectory();
    final uid = await UIDManager.getUID();

    final dbPath = p.join(docsDir.path, "vitacase.db");
    final documentsPath = p.join(docsDir.path, "documents");
    final outputPath = p.join(tempDir.path, backupFileName);

    final data = _BackupTaskData(
      dbPath: dbPath,
      documentsPath: documentsPath,
      outputPath: outputPath,
      manifest: BackupManifest(
        version: 1,
        scope: 'same_device_only',
        deviceUid: uid,
        includes: const ['vitacase.db', 'documents/'],
      ),
    );

    // Run the heavy lifting in a background isolate
    await Isolate.run(() => _exportTask(data));

    return outputPath;
  }

  /// Restores from a ZIP file by overwriting the current database and documents.
  /// Runs in a background isolate to prevent UI jank.
  Future<void> importBackup(String zipPath) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final uid = await UIDManager.getUID();

    // Close any active database connection before modifying DB on disk
    try {
      await SembastDatabase().close();
    } catch (_) {}

    final data = _RestoreTaskData(
      zipPath: zipPath,
      targetDocsPath: docsDir.path,
      currentDeviceUid: uid,
    );

    try {
      // Run the heavy lifting in a background isolate
      await Isolate.run(() => _importTask(data));
    } finally {
      // Reset the database singleton completer so the next init will bind to the new file cleanly
      SembastDatabase().reset();
    }
  }
}

/// Data container for the export isolate
class _BackupTaskData {
  final String dbPath;
  final String documentsPath;
  final String outputPath;
  final BackupManifest manifest;

  _BackupTaskData({
    required this.dbPath,
    required this.documentsPath,
    required this.outputPath,
    required this.manifest,
  });
}

/// Data container for the import isolate
class _RestoreTaskData {
  final String zipPath;
  final String targetDocsPath;
  final String currentDeviceUid;

  _RestoreTaskData({
    required this.zipPath,
    required this.targetDocsPath,
    required this.currentDeviceUid,
  });
}

/// Top-level function for background export
void _exportTask(_BackupTaskData data) {
  final encoder = ZipFileEncoder();
  encoder.create(data.outputPath);

  // 1. Add Database file
  final dbFile = File(data.dbPath);
  if (dbFile.existsSync()) {
    encoder.addFileSync(dbFile, "vitacase.db");
  }

  // 2. Add Documents directory recursively
  final documentsDir = Directory(data.documentsPath);
  if (documentsDir.existsSync()) {
    _addDirectoryToZipSync(encoder, documentsDir, "documents");
  }

  // 3. Add a manifest so restore code can validate version/scope
  final manifest = jsonEncode(data.manifest.toJson());
  encoder.addArchiveFile(
    ArchiveFile('vitacase_manifest.json', manifest.length, manifest.codeUnits),
  );

  encoder.close();
}

/// Top-level function for background import
void _importTask(_RestoreTaskData data) {
  final zipFile = File(data.zipPath);
  if (!zipFile.existsSync()) {
    throw const FileSystemException('Backup archive file not found.');
  }

  final List<int> bytes;
  try {
    bytes = zipFile.readAsBytesSync();
  } catch (e) {
    throw FileSystemException('Failed to read backup archive: $e');
  }

  final Archive archive;
  try {
    archive = ZipDecoder().decodeBytes(bytes);
  } catch (e) {
    throw const FormatException('Invalid or corrupted ZIP archive format.');
  }

  // 1. Verify manifest existence and structure
  final manifestEntry = archive.findFile('vitacase_manifest.json');
  if (manifestEntry == null || !manifestEntry.isFile) {
    throw const FormatException('Backup manifest is missing or invalid.');
  }

  final String manifestRaw;
  try {
    manifestRaw = utf8.decode(manifestEntry.content as List<int>);
  } catch (e) {
    throw const FormatException('Corrupted backup manifest content.');
  }

  final Map<String, dynamic> manifestJson;
  try {
    manifestJson = jsonDecode(manifestRaw) as Map<String, dynamic>;
  } catch (e) {
    throw FormatException('Invalid JSON in backup manifest: $e');
  }

  final manifest = BackupManifest.fromJson(manifestJson);

  // Validate version
  if (manifest.version > 1) {
    throw FormatException('Unsupported backup version (${manifest.version}). Please update VitaCase.');
  }

  // Validate scope and encryption key compatibility
  if (manifest.scope == 'same_device_only' &&
      manifest.deviceUid.isNotEmpty &&
      data.currentDeviceUid.isNotEmpty &&
      manifest.deviceUid != data.currentDeviceUid) {
    throw const FormatException(
      'Cross-device restore blocked: This backup was created on a different device and requires the original hardware encryption key.',
    );
  }

  // Validate mandatory files inside archive
  final dbEntry = archive.findFile('vitacase.db');
  if (dbEntry == null || !dbEntry.isFile) {
    throw const FormatException('Corrupt backup: vitacase.db is missing from archive.');
  }

  // 2. Prepare temp directory for safe extraction
  final tempDirPath = p.join(data.targetDocsPath, "restore_temp");
  final tempDir = Directory(tempDirPath);
  if (tempDir.existsSync()) {
    tempDir.deleteSync(recursive: true);
  }
  tempDir.createSync();

  try {
    // 3. Extract files – guard against path traversal attacks
    for (final file in archive) {
      final normalized = p.normalize(file.name).replaceAll('\\', '/');

      // SECURITY: Reject entries that escape the target directory.
      if (p.isAbsolute(normalized) ||
          normalized.contains('../') ||
          normalized.startsWith('..')) {
        continue;
      }

      if (file.isFile) {
        if (normalized == 'vitacase_manifest.json') {
          continue;
        }
        final fileData = file.content as List<int>;
        final outPath = p.join(tempDirPath, normalized);
        final outFile = File(outPath);
        outFile.createSync(recursive: true);
        outFile.writeAsBytesSync(fileData);
      } else {
        Directory(p.join(tempDirPath, normalized)).createSync(recursive: true);
      }
    }

    final newDbPath = p.join(tempDirPath, "vitacase.db");
    if (!File(newDbPath).existsSync() || File(newDbPath).lengthSync() == 0) {
      throw const FormatException('Extracted database file is missing or empty.');
    }

    // 4. Atomically replace old content with rollback protection
    final dbPath = p.join(data.targetDocsPath, "vitacase.db");
    final oldDbPath = p.join(data.targetDocsPath, "vitacase.db.old");

    final docsPath = p.join(data.targetDocsPath, "documents");
    final oldDocsPath = p.join(data.targetDocsPath, "documents_old");
    final newDocsPath = p.join(tempDirPath, "documents");

    bool renamedDb = false;
    bool renamedDocs = false;

    try {
      if (File(dbPath).existsSync()) {
        File(dbPath).renameSync(oldDbPath);
        renamedDb = true;
      }
      if (Directory(docsPath).existsSync()) {
        Directory(docsPath).renameSync(oldDocsPath);
        renamedDocs = true;
      }

      File(newDbPath).renameSync(dbPath);
      if (Directory(newDocsPath).existsSync()) {
        Directory(newDocsPath).renameSync(docsPath);
      }

      // Cleanup old files ONLY after swap completes successfully
      if (File(oldDbPath).existsSync()) {
        try { File(oldDbPath).deleteSync(); } catch (_) {}
      }
      if (Directory(oldDocsPath).existsSync()) {
        try { Directory(oldDocsPath).deleteSync(recursive: true); } catch (_) {}
      }
    } catch (swapError) {
      // ROLLBACK: Restore previous data if swap failed
      if (renamedDb && File(oldDbPath).existsSync() && !File(dbPath).existsSync()) {
        try { File(oldDbPath).renameSync(dbPath); } catch (_) {}
      }
      if (renamedDocs && Directory(oldDocsPath).existsSync() && !Directory(docsPath).existsSync()) {
        try { Directory(oldDocsPath).renameSync(docsPath); } catch (_) {}
      }
      throw FileSystemException('Atomic restore swap failed: $swapError');
    }
  } finally {
    // 5. Cleanup temp directory
    if (tempDir.existsSync()) {
      try { tempDir.deleteSync(recursive: true); } catch (_) {}
    }
  }
}

/// Synchronous directory adding for use in isolates
void _addDirectoryToZipSync(
  ZipFileEncoder encoder,
  Directory dir,
  String zipPath,
) {
  final List<FileSystemEntity> entities = dir.listSync();
  for (final entity in entities) {
    final String name = p.basename(entity.path);
    if (entity is File) {
      encoder.addFileSync(entity, p.join(zipPath, name));
    } else if (entity is Directory) {
      _addDirectoryToZipSync(encoder, entity, p.join(zipPath, name));
    }
  }
}
