/// Web-safe stub implementation used when dart:io is unavailable.
///
/// VitaCase V1 intentionally exposes the document vault as a preview on web,
/// while encrypted local document storage is enabled on mobile/desktop builds.
class FileStorageService {
  Future<void> init() async {}

  Future<String> copyFileToAppDir(Object source, String destFileName) {
    throw UnsupportedError('Encrypted local document storage is not available on web.');
  }

  Future<void> deleteFile(String relativePath) async {}

  Future<Object> getFile(String relativePath) {
    throw UnsupportedError('Encrypted local document storage is not available on web.');
  }

  Future<bool> fileExists(String relativePath) async => false;

  Future<String> getAbsolutePath(String relativePath) {
    throw UnsupportedError('Encrypted local document storage is not available on web.');
  }

  Future<void> cleanupTempFile(String path) async {}

  Future<void> openAndCleanFile(String path) {
    throw UnsupportedError('Encrypted local document storage is not available on web.');
  }

  Future<void> cleanupAllTempFiles() async {}

  Future<String?> saveDecryptedCopyToDownloads({
    required String relativePath,
    required String originalFileName,
    required String mimeType,
  }) async {
    return null;
  }
}
