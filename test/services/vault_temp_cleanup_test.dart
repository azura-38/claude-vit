// ignore_for_file: depend_on_referenced_packages
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:vitacase/shared/data/datasources/file_storage_service_io.dart';
import 'package:vitacase/shared/data/services/encryption_service.dart';

class MockPathProviderPlatform extends PathProviderPlatform {
  final String tempPath;
  final String appDocPath;

  MockPathProviderPlatform({required this.tempPath, required this.appDocPath});

  @override
  Future<String?> getTemporaryPath() async => tempPath;

  @override
  Future<String?> getApplicationDocumentsPath() async => appDocPath;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late Directory docDir;
  late Directory externalDir;
  late FileStorageService storageService;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    final systemTemp = Directory.systemTemp.createTempSync('vitacase_test_');
    tempDir = Directory(p.join(systemTemp.path, 'temp'))..createSync(recursive: true);
    docDir = Directory(p.join(systemTemp.path, 'app_docs'))..createSync(recursive: true);
    externalDir = Directory(p.join(systemTemp.path, 'external_downloads'))..createSync(recursive: true);

    PathProviderPlatform.instance = MockPathProviderPlatform(
      tempPath: tempDir.path,
      appDocPath: docDir.path,
    );

    storageService = FileStorageService();
  });

  tearDown(() {
    try {
      tempDir.parent.deleteSync(recursive: true);
    } catch (_) {}
  });

  group('Vault Temporary Decrypted File Security & Cleanup Tests', () {
    test('A & B: Decrypted temporary file is created with prefix and cleaned safely while encrypted source remains untouched', () async {
      // 1. Create a dummy encrypted document in app documents
      final rawContent = 'Confidential Medical Report Data 2026';
      final rawBytes = Uint8List.fromList(rawContent.codeUnits);
      final encryptedBytes = await EncryptionService().encryptBytes(rawBytes);

      final docSubDir = Directory(p.join(docDir.path, 'documents'))..createSync(recursive: true);
      final encryptedFile = File(p.join(docSubDir.path, 'doc_001.enc'));
      await encryptedFile.writeAsBytes(encryptedBytes);

      // 2. Retrieve decrypted file (simulating Open flow)
      final decryptedFile = await storageService.getFile('documents/doc_001.enc');
      expect(await decryptedFile.exists(), isTrue);
      expect(p.basename(decryptedFile.path).startsWith('decrypted_'), isTrue);
      expect(await decryptedFile.readAsString(), equals(rawContent));

      // 3. Perform cleanup
      await storageService.cleanupTempFile(decryptedFile.path);

      // 4. Temporary file is gone, but encrypted source remains intact
      expect(await decryptedFile.exists(), isFalse, reason: 'Decrypted temporary file must be deleted');
      expect(await encryptedFile.exists(), isTrue, reason: 'Original encrypted file must remain untouched');
    });

    test('C: Finally block guarantees cleanup even when open operation throws', () async {
      final rawContent = 'Lab Results';
      final rawBytes = Uint8List.fromList(rawContent.codeUnits);
      final encryptedBytes = await EncryptionService().encryptBytes(rawBytes);
      final docSubDir = Directory(p.join(docDir.path, 'documents'))..createSync(recursive: true);
      final encryptedFile = File(p.join(docSubDir.path, 'lab_002.enc'))..writeAsBytesSync(encryptedBytes);

      String? tempFilePath;
      try {
        final tempFile = await storageService.getFile('documents/lab_002.enc');
        tempFilePath = tempFile.path;
        expect(await tempFile.exists(), isTrue);
        throw Exception('Simulated OpenFilex failure or crash');
      } catch (_) {
        // Exception expected in test flow
      } finally {
        if (tempFilePath != null) {
          await storageService.cleanupTempFile(tempFilePath);
        }
      }

      expect(tempFilePath, isNotNull);
      expect(await File(tempFilePath!).exists(), isFalse, reason: 'Temporary file must be cleaned in finally block');
      expect(await encryptedFile.exists(), isTrue);
    });

    test('D: No temporary file exists if decryption fails on corrupted data', () async {
      final docSubDir = Directory(p.join(docDir.path, 'documents'))..createSync(recursive: true);
      File(p.join(docSubDir.path, 'corrupt.enc')).writeAsBytesSync([0x00, 0x01, 0x02, 0x03]);

      await expectLater(
        () => storageService.getFile('documents/corrupt.enc'),
        throwsA(isA<FileSystemException>()),
      );

      final tempEntities = tempDir.listSync();
      expect(tempEntities, isEmpty, reason: 'No temporary file should be left if decryption fails');
    });

    test('E: An unrelated temporary file is NOT deleted by cleanupTempFile', () async {
      final unrelatedFile = File(p.join(tempDir.path, 'cache_data.json'))..writeAsStringSync('{}');
      expect(await unrelatedFile.exists(), isTrue);

      await storageService.cleanupTempFile(unrelatedFile.path);

      expect(await unrelatedFile.exists(), isTrue, reason: 'Unrelated temp files without prefix must not be deleted');
    });

    test('F: Path outside the application temporary directory is NOT deleted (Path Traversal Protection)', () async {
      final outsideFile = File(p.join(externalDir.path, 'decrypted_outside.pdf'))..writeAsStringSync('Sensitive');
      expect(await outsideFile.exists(), isTrue);

      await storageService.cleanupTempFile(outsideFile.path);

      expect(await outsideFile.exists(), isTrue, reason: 'Files outside temp dir must be rejected by ownership validation');
    });

    test('G: A user Downloads file is NOT deleted', () async {
      final downloadsDir = Directory(p.join(externalDir.path, 'Downloads'))..createSync(recursive: true);
      final downloadedDoc = File(p.join(downloadsDir.path, 'Prescription_2026.pdf'))..writeAsStringSync('Rx PDF');
      expect(await downloadedDoc.exists(), isTrue);

      await storageService.cleanupTempFile(downloadedDoc.path);

      expect(await downloadedDoc.exists(), isTrue, reason: 'User Downloads must never be touched by temp cleanup');
    });

    test('H: cleanupAllTempFiles purges only decrypted_* files in tempDir', () async {
      final decTemp1 = File(p.join(tempDir.path, 'decrypted_123_test.pdf'))..writeAsStringSync('temp1');
      final decTemp2 = File(p.join(tempDir.path, 'decrypted_456_image.png'))..writeAsStringSync('temp2');
      final keepTemp = File(p.join(tempDir.path, 'app_session.tmp'))..writeAsStringSync('keep');

      await storageService.cleanupAllTempFiles();

      expect(await decTemp1.exists(), isFalse);
      expect(await decTemp2.exists(), isFalse);
      expect(await keepTemp.exists(), isTrue, reason: 'Non-decrypted temp files must remain untouched');
    });

    test('I: Cleanup on non-existent or inaccessible file does not throw or crash', () async {
      await expectLater(
        () => storageService.cleanupTempFile(p.join(tempDir.path, 'decrypted_non_existent.pdf')),
        returnsNormally,
      );
    });
  });
}
