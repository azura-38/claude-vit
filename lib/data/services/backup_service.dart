import 'dart:convert';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:isolate';

import '../../core/utils/uid_manager.dart';

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
      includes: (json['includes'] as List<dynamic>? ?? const [])
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
    
    final data = _RestoreTaskData(
      zipPath: zipPath,
      targetDocsPath: docsDir.path,
      currentDeviceUid: uid,
    );

    // Run the heavy lifting in a background isolate
    await Isolate.run(() => _importTask(data));
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
    encoder.addFile(dbFile, "vitacase.db");
  }

  // 2. Add Documents directory recursively
  final documentsDir = Directory(data.documentsPath);
  if (documentsDir.existsSync()) {
    _addDirectoryToZipSync(encoder, documentsDir, "documents");
  }

  // 3. Add a manifest so restore code can validate version/scope
  final manifest = jsonEncode(data.manifest.toJson());
  encoder.addArchiveFile(ArchiveFile(
    'vitacase_manifest.json',
    manifest.length,
    manifest.codeUnits,
  ));

  encoder.close();
}

/// Top-level function for background import
void _importTask(_RestoreTaskData data) {
  final zipFile = File(data.zipPath);
  final bytes = zipFile.readAsBytesSync();
  final archive = ZipDecoder().decodeBytes(bytes);
  final manifestEntry = archive.findFile('vitacase_manifest.json');
  if (manifestEntry == null || !manifestEntry.isFile) {
    throw const FileSystemException('Backup manifest is missing.');
  }

  final manifestJson = utf8.decode((manifestEntry.content as List<int>));
  final manifest = BackupManifest.fromJson(
    jsonDecode(manifestJson) as Map<String, dynamic>,
  );

  if (manifest.scope == 'same_device_only' &&
      manifest.deviceUid != data.currentDeviceUid) {
    throw const FileSystemException(
      'This backup belongs to a different device and cannot be restored here.',
    );
  }

  // 1. Prepare temp directory
  final tempDirPath = p.join(data.targetDocsPath, "restore_temp");
  final tempDir = Directory(tempDirPath);
  if (tempDir.existsSync()) {
    tempDir.deleteSync(recursive: true);
  }
  tempDir.createSync();

  // 2. Extract files – guard against path traversal attacks
  for (final file in archive) {
    final normalized = p.normalize(file.name).replaceAll('\\', '/');

    // SECURITY: Reject entries that escape the target directory.
    if (p.isAbsolute(normalized) || normalized.contains('../') || normalized.startsWith('..')) {
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

  // 3. Atomically replace old content
  final dbPath = p.join(data.targetDocsPath, "vitacase.db");
  final oldDbPath = p.join(data.targetDocsPath, "vitacase.db.old");
  final newDbPath = p.join(tempDirPath, "vitacase.db");

  final docsPath = p.join(data.targetDocsPath, "documents");
  final oldDocsPath = p.join(data.targetDocsPath, "documents_old");
  final newDocsPath = p.join(tempDirPath, "documents");

  if (File(dbPath).existsSync()) File(dbPath).renameSync(oldDbPath);
  if (Directory(docsPath).existsSync()) Directory(docsPath).renameSync(oldDocsPath);

  if (File(newDbPath).existsSync()) File(newDbPath).renameSync(dbPath);
  if (Directory(newDocsPath).existsSync()) Directory(newDocsPath).renameSync(docsPath);

  // 4. Cleanup
  if (File(oldDbPath).existsSync()) File(oldDbPath).deleteSync();
  if (Directory(oldDocsPath).existsSync()) Directory(oldDocsPath).deleteSync(recursive: true);
  if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
}

/// Synchronous directory adding for use in isolates
void _addDirectoryToZipSync(ZipFileEncoder encoder, Directory dir, String zipPath) {
  final List<FileSystemEntity> entities = dir.listSync();
  for (final entity in entities) {
    final String name = p.basename(entity.path);
    if (entity is File) {
      encoder.addFile(entity, p.join(zipPath, name));
    } else if (entity is Directory) {
      _addDirectoryToZipSync(encoder, entity, p.join(zipPath, name));
    }
  }
}
