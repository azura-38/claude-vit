import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../services/encryption_service.dart';
import 'package:open_filex/open_filex.dart';


/// Service for copying, deleting, and retrieving files in the app's
/// private documents directory. Mirrors the React LocalDocumentService.
class FileStorageService {
  static const String _documentsSubDir = 'documents';

  /// Returns the app-private documents directory, creating it if needed.
  Future<Directory> _getDocumentsDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final docsDir = Directory(p.join(appDir.path, _documentsSubDir));
    if (!await docsDir.exists()) {
      await docsDir.create(recursive: true);
    }
    return docsDir;
  }

   /// Copy a file from [source] into the app's documents directory
  /// with the given [destFileName]. Returns the relative path from
  /// the app documents root (e.g., "documents/doc_123.pdf").
  /// The file is encrypted using AES-256 before being saved.
  Future<String> copyFileToAppDir(File source, String destFileName) async {
    final docsDir = await _getDocumentsDir();
    final destPath = p.join(docsDir.path, destFileName);
    
    final bytes = await source.readAsBytes();
    final encryptedBytes = await EncryptionService().encryptBytes(bytes);
    
    final destFile = File(destPath);
    await destFile.writeAsBytes(encryptedBytes);
    
    return '$_documentsSubDir/$destFileName';
  }

  /// Delete a file by its relative path.
  Future<void> deleteFile(String relativePath) async {
    final appDir = await getApplicationDocumentsDirectory();
    final file = File(p.join(appDir.path, relativePath));
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Get a [File] reference by relative path.
  /// This returns a path to a DECRYPTED version of the file in the temp directory.
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

  /// Check if a file exists by relative path.
  Future<bool> fileExists(String relativePath) async {
    final appDir = await getApplicationDocumentsDirectory();
    return File(p.join(appDir.path, relativePath)).exists();
  }

  /// Get the absolute path for a relative path.
  /// This returns a path to a DECRYPTED version of the file in the temp directory.
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
      } catch (_) {
        // Best effort
      }
    }
  }

  bool _looksLikeLegacyPlaintext(List<int> bytes) {
    if (bytes.length < 4) return false;
    if (bytes[0] == 0x25 && bytes[1] == 0x50 && bytes[2] == 0x44 && bytes[3] == 0x46) {
      return true;
    }
    if (bytes[0] == 0xFF && bytes[1] == 0xD8) {
      return true;
    }
    if (bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47) {
      return true;
    }
    return false;
  }

  Future<void> openAndCleanFile(String path) async {
    await OpenFilex.open(path);
    // Delay cleanup to give the external OS intent time to initialize and read the file stream.
    // 30s is sufficient for most apps to hand over the file to a viewer.
    Future.delayed(const Duration(seconds: 30), () {
      cleanupTempFile(path);
    });
  }

  /// Cleans up ALL decrypted temp files. Call on app startup and after viewing documents.
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
