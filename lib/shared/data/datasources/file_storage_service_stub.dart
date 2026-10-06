import 'dart:typed_data';
import 'package:open_filex/open_filex.dart';

/// Web-safe stub implementation used when dart:io is unavailable.
///
/// VitaCase V1 intentionally exposes the document vault as a preview on web,
/// while encrypted local document storage is enabled on mobile/desktop builds.
class FileStorageService {
  FileStorageService({
    dynamic documentsDirProvider,
    dynamic tempDirProvider,
    dynamic encryptionService,
    dynamic fileOpener,
  });

  Future<void> init() async {}

  Future<String> copyFileToAppDir(Object source, String destFileName) {
    throw UnsupportedError('Encrypted local document storage is not available on web.');
  }

  Future<void> deleteFile(String relativePath) async {}

  Future<dynamic> getFile(String relativePath) {
    throw UnsupportedError('Encrypted local document storage is not available on web.');
  }

  Future<Uint8List> readDecryptedBytes(String relativePath) {
    throw UnsupportedError('Encrypted local document storage is not available on web.');
  }

  Future<bool> fileExists(String relativePath) async => false;

  Future<String> getAbsolutePath(String relativePath) {
    throw UnsupportedError('Encrypted local document storage is not available on web.');
  }

  static String sanitizeFileName(String input) => input;

  static String resolveMimeType(String fileName) => 'application/octet-stream';

  Future<void> cleanupTempFile(String path) async {}

  Future<OpenResult> openAndCleanFile(
    String path, {
    String? mimeType,
    Duration cleanupDelay = const Duration(seconds: 15),
  }) {
    throw UnsupportedError('Encrypted local document storage is not available on web.');
  }

  Future<OpenResult> openSecureDocument(
    String relativePath, {
    String? mimeType,
    Duration cleanupDelay = const Duration(seconds: 25),
  }) {
    throw UnsupportedError('Encrypted local document storage is not available on web.');
  }

  Future<String> downloadDocument({
    required String relativePath,
    required String originalFileName,
  }) {
    throw UnsupportedError('Encrypted local document storage is not available on web.');
  }

  Future<void> cleanupAllTempFiles() async {}
}
