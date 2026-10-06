import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../services/encryption_service.dart';

typedef FileOpenerCallback = Future<OpenResult> Function(
  String path, {
  String? type,
  String? uti,
});

/// Mobile/desktop implementation for copying, deleting, opening, retrieving,
/// and downloading encrypted files with secure transient lifecycle management.
class FileStorageService {
  static const String _documentsSubDir = 'documents';
  static const String _decryptedPrefix = 'decrypted_';

  final Future<Directory> Function() _documentsDirProvider;
  final Future<Directory> Function() _tempDirProvider;
  final Future<Directory> Function() _downloadsDirProvider;
  final EncryptionService _encryptionService;
  final FileOpenerCallback _fileOpener;
  final Future<String> Function({
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
  })? _downloadsWriter;

  FileStorageService({
    Future<Directory> Function()? documentsDirProvider,
    Future<Directory> Function()? tempDirProvider,
    Future<Directory> Function()? downloadsDirProvider,
    EncryptionService? encryptionService,
    Function? fileOpener,
    Future<String> Function({
      required Uint8List bytes,
      required String fileName,
      required String mimeType,
    })? downloadsWriter,
  })  : _documentsDirProvider = documentsDirProvider ?? getApplicationDocumentsDirectory,
        _tempDirProvider = tempDirProvider ?? getTemporaryDirectory,
        _downloadsDirProvider = downloadsDirProvider ?? _defaultDownloadsDirProvider,
        _encryptionService = encryptionService ?? EncryptionService(),
        _fileOpener = _wrapFileOpener(fileOpener),
        _downloadsWriter = downloadsWriter;

  static FileOpenerCallback _wrapFileOpener(Function? opener) {
    if (opener == null) {
      return (String path, {String? type, String? uti}) =>
          OpenFilex.open(path, type: type, uti: uti);
    }
    if (opener is FileOpenerCallback) {
      return opener;
    }
    if (opener is Future<OpenResult> Function(String path)) {
      return (String path, {String? type, String? uti}) => opener(path);
    }
    return (String path, {String? type, String? uti}) {
      try {
        final dynamic res = Function.apply(
          opener,
          [path],
          {
            if (type != null) #type: type,
            if (uti != null) #uti: uti,
          },
        );
        if (res is Future<OpenResult>) return res;
      } catch (_) {
        final dynamic res = Function.apply(opener, [path]);
        if (res is Future<OpenResult>) return res;
      }
      return Future.value(OpenResult(type: ResultType.error, message: 'Invalid opener'));
    };
  }

  static Future<Directory> _defaultDownloadsDirProvider() async {
    try {
      final dir = await getDownloadsDirectory();
      if (dir != null) return dir;
    } catch (_) {}
    return getApplicationDocumentsDirectory();
  }

  Future<void> init() async {
    await cleanupAllTempFiles();
  }

  Future<Directory> _getDocumentsDir() async {
    final appDir = await _documentsDirProvider();
    final docsDir = Directory(p.join(appDir.path, _documentsSubDir));
    if (!await docsDir.exists()) {
      await docsDir.create(recursive: true);
    }
    return docsDir;
  }

  Future<Directory> _getTempDir() async {
    final tempDir = await _tempDirProvider();
    if (!await tempDir.exists()) {
      await tempDir.create(recursive: true);
    }
    return tempDir;
  }

  /// Sanitizes a filename to prevent path traversal, control character injection,
  /// and invalid platform device names.
  static String sanitizeFileName(String input) {
    if (input.isEmpty) return 'document.bin';

    // 1. Strip any directory paths (both / and \)
    var name = p.basename(input.replaceAll('\\', '/'));

    // 2. Remove null bytes and control characters
    name = name.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');

    // 3. Remove Windows reserved characters: < > : " / \ | ? *
    name = name.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');

    // 4. Remove path traversal patterns
    name = name.replaceAll('..', '_');

    // 5. Trim leading/trailing dots and whitespaces
    name = name.trim().replaceAll(RegExp(r'^\.+|\.+$'), '');

    // 6. Check Windows reserved device names (CON, PRN, AUX, NUL, COM1-9, LPT1-9)
    final baseNameWithoutExt = p.basenameWithoutExtension(name).toUpperCase();
    const reservedNames = {
      'CON', 'PRN', 'AUX', 'NUL',
      'COM1', 'COM2', 'COM3', 'COM4', 'COM5', 'COM6', 'COM7', 'COM8', 'COM9',
      'LPT1', 'LPT2', 'LPT3', 'LPT4', 'LPT5', 'LPT6', 'LPT7', 'LPT8', 'LPT9'
    };
    if (reservedNames.contains(baseNameWithoutExt)) {
      name = 'safe_$name';
    }

    // 7. Ensure not empty and limit length
    if (name.isEmpty) {
      name = 'document.bin';
    } else if (name.length > 80) {
      final ext = p.extension(name);
      final safeExt = ext.length <= 10 ? ext : '';
      name = '${name.substring(0, 70)}$safeExt';
    }

    return name;
  }

  /// Resolves the standard MIME type based on file extension.
  static String resolveMimeType(String fileName) {
    final ext = p.extension(fileName).toLowerCase();
    switch (ext) {
      case '.pdf':
        return 'application/pdf';
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.webp':
        return 'image/webp';
      case '.gif':
        return 'image/gif';
      case '.txt':
        return 'text/plain';
      case '.csv':
        return 'text/csv';
      case '.json':
        return 'application/json';
      case '.doc':
        return 'application/msword';
      case '.docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case '.xls':
        return 'application/vnd.ms-excel';
      case '.xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      default:
        return 'application/octet-stream';
    }
  }

  /// Generates a randomized, sanitized temporary file name.
  String _generateDecryptedFileName(String rawName) {
    final sanitized = sanitizeFileName(rawName);
    final randomHex = List.generate(
      8,
      (_) => Random.secure().nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$_decryptedPrefix${timestamp}_${randomHex}_$sanitized';
  }

  /// Validates whether a candidate path resolves canonically inside the expected temp directory.
  Future<bool> _isPathInsideTemp(String candidatePath) async {
    try {
      final tempDir = await _getTempDir();
      final canonicalTemp = p.canonicalize(tempDir.path);
      final canonicalCandidate = p.canonicalize(candidatePath);

      if (canonicalCandidate == canonicalTemp) return false;
      return p.isWithin(canonicalTemp, canonicalCandidate);
    } catch (_) {
      return false;
    }
  }

  Future<String> copyFileToAppDir(Object source, String destFileName) async {
    final sourceFile = switch (source) {
      File file => file,
      String path => File(path),
      _ => throw ArgumentError('Unsupported file source type: ${source.runtimeType}'),
    };

    final docsDir = await _getDocumentsDir();
    final safeFileName = sanitizeFileName(destFileName);
    final destPath = p.join(docsDir.path, safeFileName);

    final bytes = await sourceFile.readAsBytes();
    final encryptedBytes = await _encryptionService.encryptBytes(bytes);

    final destFile = File(destPath);
    await destFile.writeAsBytes(encryptedBytes);

    return '$_documentsSubDir/$safeFileName';
  }

  Future<void> deleteFile(String relativePath) async {
    final appDir = await _documentsDirProvider();
    final safeRelPath = relativePath.replaceAll('\\', '/');
    final file = File(p.join(appDir.path, safeRelPath));
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<File> getFile(String relativePath) async {
    final appDir = await _documentsDirProvider();
    final safeRelPath = relativePath.replaceAll('\\', '/');
    final encryptedFile = File(p.join(appDir.path, safeRelPath));

    if (!await encryptedFile.exists()) {
      throw FileSystemException('File not found', relativePath);
    }

    final bytes = await encryptedFile.readAsBytes();
    Uint8List decryptedBytes;

    try {
      decryptedBytes = await _encryptionService.decryptBytes(bytes);
    } catch (e) {
      if (_looksLikeLegacyPlaintext(bytes)) {
        try {
          final encryptedBytes = await _encryptionService.encryptBytes(bytes);
          await encryptedFile.writeAsBytes(encryptedBytes, flush: true);
          decryptedBytes = Uint8List.fromList(bytes);
        } catch (_) {
          throw FileSystemException(
            'Decryption failed. The file is corrupted or not a supported encrypted VitaCase document.',
            relativePath,
          );
        }
      } else {
        throw FileSystemException(
          'Decryption failed. The file is corrupted or not a supported encrypted VitaCase document.',
          relativePath,
        );
      }
    }

    File? tempFile;
    try {
      final tempDir = await _getTempDir();
      final safeName = _generateDecryptedFileName(p.basename(relativePath));
      final tempFilePath = p.join(tempDir.path, safeName);

      if (!await _isPathInsideTemp(tempFilePath)) {
        throw FileSystemException('Security violation: path resolves outside temporary sandbox', tempFilePath);
      }

      tempFile = File(tempFilePath);
      await tempFile.writeAsBytes(decryptedBytes, flush: true);
      return tempFile;
    } catch (e) {
      if (tempFile != null && await tempFile.exists()) {
        try {
          await tempFile.delete();
        } catch (_) {}
      }
      if (e is FileSystemException) rethrow;
      throw FileSystemException('Failed to create decrypted temporary file: $e', relativePath);
    }
  }

  /// Decrypts and returns the document bytes purely in memory without creating temporary files.
  Future<Uint8List> readDecryptedBytes(String relativePath) async {
    final appDir = await _documentsDirProvider();
    final safeRelPath = relativePath.replaceAll('\\', '/');
    final encryptedFile = File(p.join(appDir.path, safeRelPath));

    if (!await encryptedFile.exists()) {
      throw FileSystemException('File not found', relativePath);
    }

    final bytes = await encryptedFile.readAsBytes();
    try {
      return await _encryptionService.decryptBytes(bytes);
    } catch (e) {
      if (_looksLikeLegacyPlaintext(bytes)) {
        return Uint8List.fromList(bytes);
      }
      rethrow;
    }
  }

  Future<bool> fileExists(String relativePath) async {
    final appDir = await _documentsDirProvider();
    final safeRelPath = relativePath.replaceAll('\\', '/');
    return File(p.join(appDir.path, safeRelPath)).exists();
  }

  Future<String> getAbsolutePath(String relativePath) async {
    final decryptedFile = await getFile(relativePath);
    return decryptedFile.path;
  }

  /// Deletes a temporary decrypted file.
  /// Strictly rejects any path outside the temporary directory or not matching
  /// the 'decrypted_' prefix. Never crashes on cleanup failures.
  Future<void> cleanupTempFile(String path) async {
    try {
      final fileName = p.basename(path);
      if (!fileName.startsWith(_decryptedPrefix)) {
        return;
      }

      if (!await _isPathInsideTemp(path)) {
        return;
      }

      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Cleanup failures must never crash the application
    }
  }

  bool _looksLikeLegacyPlaintext(List<int> bytes) {
    if (bytes.length < 4) return false;
    if (bytes[0] == 0x25 && bytes[1] == 0x50 && bytes[2] == 0x44 && bytes[3] == 0x46) return true;
    if (bytes[0] == 0xFF && bytes[1] == 0xD8) return true;
    if (bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47) return true;
    return false;
  }

  /// Opens a decrypted document with the platform viewer and guarantees cleanup.
  Future<OpenResult> openAndCleanFile(
    String path, {
    String? mimeType,
    Duration cleanupDelay = const Duration(seconds: 15),
  }) async {
    bool openedSuccessfully = false;
    try {
      if (!await _isPathInsideTemp(path) || !p.basename(path).startsWith(_decryptedPrefix)) {
        throw const FileSystemException('Invalid or unauthorized temporary file path');
      }

      final resolvedMime = mimeType ?? resolveMimeType(path);
      final result = await _fileOpener(path, type: resolvedMime);
      openedSuccessfully = (result.type == ResultType.done);
      return result;
    } catch (e) {
      await cleanupTempFile(path);
      rethrow;
    } finally {
      if (openedSuccessfully) {
        Timer(cleanupDelay, () async {
          await cleanupTempFile(path);
        });
      } else {
        Timer(const Duration(seconds: 2), () async {
          await cleanupTempFile(path);
        });
      }
    }
  }

  /// Securely decrypts an encrypted document into a transient private sandbox temp file,
  /// opens it in an external app with the appropriate MIME type (e.g. application/pdf),
  /// and ensures bounded lifecycle cleanup.
  /// If the opening fails, the file is empty, or decryption fails, cleans up immediately and throws.
  Future<OpenResult> openSecureDocument(
    String relativePath, {
    String? mimeType,
    Duration cleanupDelay = const Duration(seconds: 25),
  }) async {
    File? tempFile;
    try {
      final appDir = await _documentsDirProvider();
      final safeRelPath = relativePath.replaceAll('\\', '/');
      final encryptedFile = File(p.join(appDir.path, safeRelPath));

      if (!await encryptedFile.exists()) {
        throw FileSystemException('Document not found', relativePath);
      }

      final encryptedBytes = await encryptedFile.readAsBytes();
      if (encryptedBytes.isEmpty) {
        throw FileSystemException('Document is empty or corrupted', relativePath);
      }

      // Decrypt
      Uint8List decryptedBytes;
      try {
        decryptedBytes = await _encryptionService.decryptBytes(encryptedBytes);
      } catch (e) {
        if (_looksLikeLegacyPlaintext(encryptedBytes)) {
          decryptedBytes = Uint8List.fromList(encryptedBytes);
        } else {
          throw FileSystemException('Decryption failed', relativePath);
        }
      }

      if (decryptedBytes.isEmpty) {
        throw FileSystemException('Decrypted document is empty', relativePath);
      }

      // Write to secure private temporary directory
      final tempDir = await _getTempDir();
      final safeName = _generateDecryptedFileName(p.basename(relativePath));
      final tempFilePath = p.join(tempDir.path, safeName);

      if (!await _isPathInsideTemp(tempFilePath)) {
        throw FileSystemException('Security violation: path resolves outside temporary sandbox', tempFilePath);
      }

      tempFile = File(tempFilePath);
      await tempFile.writeAsBytes(decryptedBytes, flush: true);

      // Determine MIME type
      final resolvedMime = mimeType ?? resolveMimeType(relativePath);

      // Open via platform opener
      final result = await _fileOpener(tempFile.path, type: resolvedMime);

      if (result.type == ResultType.done) {
        // Successful opening - schedule bounded cleanup
        final pathToClean = tempFile.path;
        Timer(cleanupDelay, () async {
          await cleanupTempFile(pathToClean);
        });
      } else {
        // Failed opening or no app installed - clean up immediately
        await cleanupTempFile(tempFile.path);
      }

      return result;
    } catch (e) {
      if (tempFile != null) {
        await cleanupTempFile(tempFile.path);
      }
      rethrow;
    }
  }

  /// Securely downloads/exports an encrypted Vault document to the device's public Downloads directory.
  /// Decrypts to a transient sandbox temp file, writes to MediaStore/Downloads, and guarantees
  /// immediate cleanup of the temporary plaintext. The original encrypted document is never modified.
  Future<String> downloadDocument({
    required String relativePath,
    required String originalFileName,
  }) async {
    File? tempDecryptedFile;
    try {
      // 1. Decrypt into secure transient sandbox temporary file
      tempDecryptedFile = await getFile(relativePath);

      // 2. Read decrypted plaintext bytes
      final bytes = await tempDecryptedFile.readAsBytes();

      // 3. Sanitize target filename and preserve safe extension
      final rawName = originalFileName.trim().isNotEmpty
          ? originalFileName
          : p.basename(relativePath);
      final safeName = sanitizeFileName(rawName);

      // 4. Resolve MIME type
      final mimeType = resolveMimeType(safeName);

      // 5. Write to Downloads via scoped storage/MediaStore writer
      final writer = _downloadsWriter ?? _defaultDownloadsWriter;
      final savedPath = await writer(
        bytes: bytes,
        fileName: safeName,
        mimeType: mimeType,
      );

      return savedPath;
    } finally {
      // 6. Guaranteed immediate cleanup of temporary plaintext file
      if (tempDecryptedFile != null) {
        await cleanupTempFile(tempDecryptedFile.path);
      }
    }
  }

  Future<String> _defaultDownloadsWriter({
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
  }) async {
    if (Platform.isAndroid) {
      try {
        const channel = MethodChannel('vitacase/downloads');
        final result = await channel.invokeMethod<String>('saveToDownloads', {
          'bytes': bytes,
          'fileName': fileName,
          'mimeType': mimeType,
        });
        if (result != null && result.isNotEmpty) {
          return result;
        }
      } catch (_) {
        // Fallback to direct directory writing if channel not supported or in test
      }
    }

    final downloadsDir = await _getDownloadsDir();
    final targetFile = await _claimUniqueFile(downloadsDir, fileName);

    try {
      await targetFile.writeAsBytes(bytes, flush: true);
      return targetFile.path;
    } catch (e) {
      if (await targetFile.exists()) {
        try {
          await targetFile.delete();
        } catch (_) {}
      }
      throw FileSystemException('Failed to write download file: $e', targetFile.path);
    }
  }

  Future<Directory> _getDownloadsDir() async {
    final dir = await _downloadsDirProvider();
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static Future<File> _claimUniqueFile(Directory dir, String fileName) async {
    final baseName = p.basenameWithoutExtension(fileName);
    final ext = p.extension(fileName);
    var candidate = File(p.join(dir.path, fileName));
    int counter = 1;
    while (true) {
      try {
        await candidate.create(exclusive: true);
        return candidate;
      } on FileSystemException {
        candidate = File(p.join(dir.path, '$baseName ($counter)$ext'));
        counter++;
      }
    }
  }

  /// Deletes all orphaned decrypted temporary files matching the 'decrypted_' pattern
  /// inside the app-private temporary sandbox.
  /// Preserves all unrelated cache files, directories, and user documents.
  Future<void> cleanupAllTempFiles() async {
    try {
      final tempDir = await _getTempDir();
      if (!await tempDir.exists()) return;

      final canonicalTemp = p.canonicalize(tempDir.path);
      final entities = tempDir.listSync(followLinks: false);

      for (final entity in entities) {
        if (entity is File) {
          final fileName = p.basename(entity.path);
          if (fileName.startsWith(_decryptedPrefix)) {
            final canonicalEntity = p.canonicalize(entity.path);
            if (p.isWithin(canonicalTemp, canonicalEntity)) {
              try {
                await entity.delete();
              } catch (_) {}
            }
          }
        }
      }
    } catch (_) {
      // Directory listing failure must not crash the application
    }
  }
}
