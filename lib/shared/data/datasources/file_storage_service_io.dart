import 'dart:io';

import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../services/encryption_service.dart';

/// Mobile/desktop implementation for copying, deleting, opening and retrieving
/// encrypted files in the app-private documents directory.
class FileStorageService {
  static const String _documentsSubDir = 'documents';

  Future<void> init() async {
    await cleanupAllTempFiles();
  }

  Future<Directory> _getDocumentsDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final docsDir = Directory(p.join(appDir.path, _documentsSubDir));
    if (!await docsDir.exists()) {
      await docsDir.create(recursive: true);
    }
    return docsDir;
  }

  Future<String> copyFileToAppDir(Object source, String destFileName) async {
    final sourceFile = switch (source) {
      File file => file,
      String path => File(path),
      _ => throw ArgumentError('Unsupported file source type: ${source.runtimeType}'),
    };

    final docsDir = await _getDocumentsDir();
    final destPath = p.join(docsDir.path, destFileName);

    final bytes = await sourceFile.readAsBytes();
    final encryptedBytes = await EncryptionService().encryptBytes(bytes);

    final destFile = File(destPath);
    await destFile.writeAsBytes(encryptedBytes);

    return '$_documentsSubDir/$destFileName';
  }

  Future<void> deleteFile(String relativePath) async {
    final appDir = await getApplicationDocumentsDirectory();
    final file = File(p.join(appDir.path, relativePath));
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<File> getFile(String relativePath) async {
    final appDir = await getApplicationDocumentsDirectory();
    final encryptedFile = File(p.join(appDir.path, relativePath));

    if (!await encryptedFile.exists()) {
      throw FileSystemException('File not found', relativePath);
    }

    final bytes = await encryptedFile.readAsBytes();

    try {
      final decryptedBytes = await EncryptionService().decryptBytes(bytes);
      final tempDir = await getTemporaryDirectory();
      final fileName = p.basename(relativePath);
      final uniqueSuffix = DateTime.now().millisecondsSinceEpoch;
      final decryptedPath = p.join(tempDir.path, 'decrypted_${uniqueSuffix}_$fileName');

      final decryptedFile = File(decryptedPath);
      await decryptedFile.writeAsBytes(decryptedBytes);
      return decryptedFile;
    } catch (e) {
      if (_looksLikeLegacyPlaintext(bytes)) {
        final encryptedBytes = await EncryptionService().encryptBytes(bytes);
        await encryptedFile.writeAsBytes(encryptedBytes, flush: true);

        final tempDir = await getTemporaryDirectory();
        final fileName = p.basename(relativePath);
        final uniqueSuffix = DateTime.now().millisecondsSinceEpoch;
        final migratedPath = p.join(tempDir.path, 'decrypted_${uniqueSuffix}_$fileName');
        final migratedFile = File(migratedPath);
        await migratedFile.writeAsBytes(bytes, flush: true);
        return migratedFile;
      }
      throw FileSystemException(
        'Decryption failed. The file is corrupted or not a supported encrypted VitaCase document.',
        relativePath,
      );
    }
  }

  Future<bool> fileExists(String relativePath) async {
    final appDir = await getApplicationDocumentsDirectory();
    return File(p.join(appDir.path, relativePath)).exists();
  }

  Future<String> getAbsolutePath(String relativePath) async {
    final decryptedFile = await getFile(relativePath);
    return decryptedFile.path;
  }

  Future<void> cleanupTempFile(String path) async {
    if (!p.basename(path).startsWith('decrypted_')) return;
    final tempDir = await getTemporaryDirectory();
    if (!path.startsWith(tempDir.path)) return;
    final file = File(path);
    if (await file.exists()) {
      try {
        await file.delete();
      } catch (_) {}
    }
  }

  bool _looksLikeLegacyPlaintext(List<int> bytes) {
    if (bytes.length < 4) return false;
    if (bytes[0] == 0x25 && bytes[1] == 0x50 && bytes[2] == 0x44 && bytes[3] == 0x46) return true;
    if (bytes[0] == 0xFF && bytes[1] == 0xD8) return true;
    if (bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47) return true;
    return false;
  }

  Future<void> openAndCleanFile(String path) async {
    await OpenFilex.open(path);
    Future.delayed(const Duration(seconds: 3), () {
      cleanupTempFile(path);
    });
  }

  Future<void> cleanupAllTempFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final entities = tempDir.listSync();
      for (final entity in entities) {
        if (entity is File && p.basename(entity.path).startsWith('decrypted_')) {
          try {
            await entity.delete();
          } catch (_) {}
        }
      }
    } catch (_) {}
  }
}
