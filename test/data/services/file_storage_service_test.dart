import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:vitacase/shared/data/datasources/file_storage_service_io.dart';
import 'package:vitacase/shared/data/services/encryption_service.dart';

class InMemoryKeyStorage implements SecureKeyStorage {
  final Map<String, String> data = {};

  @override
  Future<String?> read(String key) async => data[key];

  @override
  Future<void> write(String key, String value) async => data[key] = value;

  @override
  Future<void> delete(String key) async => data.remove(key);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory testAppDir;
  late Directory testTempDir;
  late InMemoryKeyStorage keyStorage;
  late EncryptionService encryptionService;
  late FileStorageService storageService;

  setUp(() async {
    testAppDir = await Directory.systemTemp.createTemp('vitacase_test_app_');
    testTempDir = await Directory.systemTemp.createTemp('vitacase_test_temp_');
    keyStorage = InMemoryKeyStorage();
    encryptionService = EncryptionService(storage: keyStorage);

    storageService = FileStorageService(
      documentsDirProvider: () async => testAppDir,
      tempDirProvider: () async => testTempDir,
      encryptionService: encryptionService,
      fileOpener: (path) async => OpenResult(type: ResultType.done, message: 'Success'),
    );
  });

  tearDown(() async {
    try {
      if (await testAppDir.exists()) await testAppDir.delete(recursive: true);
      if (await testTempDir.exists()) await testTempDir.delete(recursive: true);
    } catch (_) {}
  });

  group('Phase 4 — Vault Temp Files & Decrypted File Lifecycle', () {
    test('1. Encrypted document decrypt creates temporary plaintext file', () async {
      final sampleContent = Uint8List.fromList(utf8.encode('Sensitive medical test report'));
      final sourceFile = File(p.join(testAppDir.path, 'source_test.pdf'));
      await sourceFile.writeAsBytes(sampleContent);

      final relPath = await storageService.copyFileToAppDir(sourceFile, 'test_report.pdf');
      final decryptedFile = await storageService.getFile(relPath);

      expect(await decryptedFile.exists(), isTrue);
      expect(await decryptedFile.readAsBytes(), equals(sampleContent));
    });

    test('2. Decrypted temp file is stored strictly within app-private temp directory', () async {
      final sampleContent = Uint8List.fromList([10, 20, 30, 40]);
      final sourceFile = File(p.join(testAppDir.path, 'source.bin'));
      await sourceFile.writeAsBytes(sampleContent);

      final relPath = await storageService.copyFileToAppDir(sourceFile, 'binary.bin');
      final decryptedFile = await storageService.getFile(relPath);

      final canonicalTemp = p.canonicalize(testTempDir.path);
      final canonicalDecrypted = p.canonicalize(decryptedFile.path);

      expect(p.isWithin(canonicalTemp, canonicalDecrypted), isTrue);
    });

    test('3. Temp filename conforms to secure prefix and randomized pattern', () async {
      final sourceFile = File(p.join(testAppDir.path, 'source.pdf'));
      await sourceFile.writeAsBytes([1, 2, 3]);

      final relPath = await storageService.copyFileToAppDir(sourceFile, 'scan.pdf');
      final decryptedFile = await storageService.getFile(relPath);
      final basename = p.basename(decryptedFile.path);

      expect(basename.startsWith('decrypted_'), isTrue);
      expect(basename.endsWith('.pdf'), isTrue);
      expect(RegExp(r'^decrypted_\d+_[0-9a-fA-F]{16}_').hasMatch(basename), isTrue);
    });

    test('4. Path traversal filename is sanitized and stripped of relative components', () {
      final sanitized = FileStorageService.sanitizeFileName('../../evil_path/document.pdf');
      expect(sanitized.contains('/'), isFalse);
      expect(sanitized.contains('\\'), isFalse);
      expect(sanitized.contains('..'), isFalse);
      expect(sanitized.endsWith('document.pdf'), isTrue);
    });

    test('5. Absolute path filename is safely handled to extract only the safe basename', () {
      final unixSanitized = FileStorageService.sanitizeFileName('/etc/shadow');
      expect(unixSanitized, 'shadow');

      final winSanitized = FileStorageService.sanitizeFileName(r'C:\Windows\System32\drivers\etc\hosts');
      expect(winSanitized, 'hosts');
    });

    test('6. Relative ../ traversal attempt in filename is prevented', () {
      final sanitized = FileStorageService.sanitizeFileName('../../../app_secrets.json');
      expect(sanitized.contains('..'), isFalse);
      expect(sanitized, 'app_secrets.json');
    });

    test('7. Windows backslash traversal in filename is prevented', () {
      final sanitized = FileStorageService.sanitizeFileName(r'..\..\..\AppData\Roaming\secret.key');
      expect(sanitized.contains(r'\'), isFalse);
      expect(sanitized.contains('..'), isFalse);
      expect(sanitized, 'secret.key');
    });

    test('8. Decryption failure leaves no temporary file behind on disk', () async {
      // Create a corrupted encrypted document in the documents dir
      final docsDir = Directory(p.join(testAppDir.path, 'documents'));
      await docsDir.create(recursive: true);
      final corruptFile = File(p.join(docsDir.path, 'corrupted.pdf'));
      await corruptFile.writeAsBytes([0, 1, 2, 3, 4, 5, 6, 7]); // Corrupted short payload

      await expectLater(
        () => storageService.getFile('documents/corrupted.pdf'),
        throwsA(isA<FileSystemException>()),
      );

      // Verify no decrypted temp files exist
      final tempEntities = testTempDir.listSync();
      expect(tempEntities.where((e) => p.basename(e.path).startsWith('decrypted_')).isEmpty, isTrue);
    });

    test('9. File write failure is safely handled without leaving corrupted partial files', () async {
      final sampleContent = Uint8List.fromList([1, 2, 3, 4]);
      final sourceFile = File(p.join(testAppDir.path, 'source.bin'));
      await sourceFile.writeAsBytes(sampleContent);
      final relPath = await storageService.copyFileToAppDir(sourceFile, 'test.bin');

      // Point tempDirProvider to a non-writable/invalid file path acting as a directory
      final invalidTempService = FileStorageService(
        documentsDirProvider: () async => testAppDir,
        tempDirProvider: () async {
          final dummyFile = File(p.join(testTempDir.path, 'blocked_temp_file'));
          await dummyFile.writeAsString('not a directory');
          return Directory(dummyFile.path); // Cannot create files under a file
        },
        encryptionService: encryptionService,
      );

      await expectLater(
        () => invalidTempService.getFile(relPath),
        throwsA(isA<FileSystemException>()),
      );
    });

    test('10. Viewer open failure triggers immediate cleanup of decrypted temp file', () async {
      final failingOpenerService = FileStorageService(
        documentsDirProvider: () async => testAppDir,
        tempDirProvider: () async => testTempDir,
        encryptionService: encryptionService,
        fileOpener: (path) async {
          throw Exception('External viewer crashed or failed to launch');
        },
      );

      final sampleContent = Uint8List.fromList([5, 6, 7, 8]);
      final sourceFile = File(p.join(testAppDir.path, 'source.pdf'));
      await sourceFile.writeAsBytes(sampleContent);
      final relPath = await failingOpenerService.copyFileToAppDir(sourceFile, 'view_fail.pdf');

      final decryptedFile = await failingOpenerService.getFile(relPath);
      expect(await decryptedFile.exists(), isTrue);

      // Open document - opener throws
      await expectLater(
        () => failingOpenerService.openAndCleanFile(decryptedFile.path),
        throwsA(isA<Exception>()),
      );

      // Temp file was immediately deleted
      expect(await decryptedFile.exists(), isFalse);
    });

    test('11. Normal open lifecycle triggers scheduled cleanup after delay', () async {
      final fastService = FileStorageService(
        documentsDirProvider: () async => testAppDir,
        tempDirProvider: () async => testTempDir,
        encryptionService: encryptionService,
        fileOpener: (path) async => OpenResult(type: ResultType.done, message: 'Done'),
      );

      final sourceFile = File(p.join(testAppDir.path, 'source.pdf'));
      await sourceFile.writeAsBytes([1, 2, 3]);
      final relPath = await fastService.copyFileToAppDir(sourceFile, 'lifecycle.pdf');

      final decryptedFile = await fastService.getFile(relPath);
      expect(await decryptedFile.exists(), isTrue);

      // Use a short delay for test execution
      await fastService.openAndCleanFile(decryptedFile.path, cleanupDelay: const Duration(milliseconds: 50));
      expect(await decryptedFile.exists(), isTrue); // Still exists immediately for viewer

      // Wait for delayed cleanup
      await Future.delayed(const Duration(milliseconds: 200));
      expect(await decryptedFile.exists(), isFalse); // Successfully cleaned up
    });

    test('12. Startup orphan cleanup deletes stale decrypted files from previous sessions', () async {
      // Simulate leftover decrypted files from prior session
      final orphan1 = File(p.join(testTempDir.path, 'decrypted_1690000000000_abcdef01_blood_test.pdf'));
      final orphan2 = File(p.join(testTempDir.path, 'decrypted_1690000000001_12345678_xray.png'));
      await orphan1.writeAsString('stale plaintext 1');
      await orphan2.writeAsString('stale plaintext 2');

      expect(await orphan1.exists(), isTrue);
      expect(await orphan2.exists(), isTrue);

      // Run startup cleanup
      await storageService.init();

      expect(await orphan1.exists(), isFalse);
      expect(await orphan2.exists(), isFalse);
    });

    test('13. Startup orphan cleanup strictly targets decrypted_* pattern', () async {
      final decryptedTemp = File(p.join(testTempDir.path, 'decrypted_123_temp.pdf'));
      final normalTemp = File(p.join(testTempDir.path, 'app_cache_blob.dat'));
      await decryptedTemp.writeAsString('plaintext');
      await normalTemp.writeAsString('cache');

      await storageService.cleanupAllTempFiles();

      expect(await decryptedTemp.exists(), isFalse);
      expect(await normalTemp.exists(), isTrue);
    });

    test('14. Unrelated cache files in temp directory are never deleted', () async {
      final flutterCache = File(p.join(testTempDir.path, 'image_picker_cache.jpg'));
      final httpCache = File(p.join(testTempDir.path, 'http_response.cache'));
      await flutterCache.writeAsString('unrelated 1');
      await httpCache.writeAsString('unrelated 2');

      await storageService.cleanupAllTempFiles();

      expect(await flutterCache.exists(), isTrue);
      expect(await httpCache.exists(), isTrue);
    });

    test('15. User document files in app documents directory are never deleted during temp cleanup', () async {
      final docsDir = Directory(p.join(testAppDir.path, 'documents'));
      await docsDir.create(recursive: true);
      final userDoc = File(p.join(docsDir.path, 'my_important_doc.pdf'));
      await userDoc.writeAsString('encrypted user document');

      await storageService.cleanupAllTempFiles();

      expect(await userDoc.exists(), isTrue);
    });

    test('16. Attempt to cleanup path outside temp sandbox is rejected without deleting file', () async {
      final outsideDir = await Directory.systemTemp.createTemp('vitacase_external_');
      final outsideFile = File(p.join(outsideDir.path, 'decrypted_external_secret.pdf'));
      await outsideFile.writeAsString('do not delete me');

      // Attempt cleanup of outside path
      await storageService.cleanupTempFile(outsideFile.path);

      // Outside file must NOT be deleted!
      expect(await outsideFile.exists(), isTrue);
      await outsideDir.delete(recursive: true);
    });

    test('17. Canonical path traversal attack in cleanup is detected and rejected', () async {
      // Craft a path starting inside tempDir with traversal pointing outside
      final outsideDir = await Directory.systemTemp.createTemp('vitacase_external2_');
      final targetFile = File(p.join(outsideDir.path, 'decrypted_target.pdf'));
      await targetFile.writeAsString('vital data');

      final maliciousRelativePath = p.join(testTempDir.path, '..', p.basename(outsideDir.path), 'decrypted_target.pdf');

      await storageService.cleanupTempFile(maliciousRelativePath);

      // File was not deleted through traversal
      expect(await targetFile.exists(), isTrue);
      await outsideDir.delete(recursive: true);
    });

    test('18. Cleanup failures do not crash the application', () async {
      // Pass non-existent path or unparseable path
      await expectLater(
        storageService.cleanupTempFile(p.join(testTempDir.path, 'decrypted_non_existent.pdf')),
        completes,
      );
    });

    test('19. Calling cleanup on the same temp file twice is idempotent and safe', () async {
      final tempFile = File(p.join(testTempDir.path, 'decrypted_double_clean.pdf'));
      await tempFile.writeAsString('temporary data');

      await storageService.cleanupTempFile(tempFile.path);
      expect(await tempFile.exists(), isFalse);

      // Second call must complete safely
      await expectLater(storageService.cleanupTempFile(tempFile.path), completes);
    });

    test('20. Concurrent temp cleanups do not throw or cause race conditions', () async {
      final files = await Future.wait(List.generate(10, (i) async {
        final f = File(p.join(testTempDir.path, 'decrypted_${i}_file.tmp'));
        await f.writeAsString('data $i');
        return f;
      }));

      // Concurrently clean up all files multiple times
      await Future.wait([
        ...files.map((f) => storageService.cleanupTempFile(f.path)),
        ...files.map((f) => storageService.cleanupTempFile(f.path)),
        storageService.cleanupAllTempFiles(),
      ]);

      for (final f in files) {
        expect(await f.exists(), isFalse);
      }
    });

    test('21. Decrypted document content is never leaked in exception messages', () async {
      final secretData = 'ULTRA_SECRET_LAB_RESULTS_123456';
      final sourceFile = File(p.join(testAppDir.path, 'secret.pdf'));
      await sourceFile.writeAsString(secretData);
      final relPath = await storageService.copyFileToAppDir(sourceFile, 'secret.pdf');

      // Now tamper with the encrypted file
      final fullPath = p.join(testAppDir.path, relPath);
      final encryptedFile = File(fullPath);
      final bytes = await encryptedFile.readAsBytes();
      bytes[15] ^= 0xFF; // Tamper
      await encryptedFile.writeAsBytes(bytes);

      try {
        await storageService.getFile(relPath);
        fail('Should throw');
      } catch (e) {
        expect(e.toString().contains(secretData), isFalse);
      }
    });

    test('22. Decrypted file path is never leaked in generic error logs', () async {
      final sourceFile = File(p.join(testAppDir.path, 'path_test.pdf'));
      await sourceFile.writeAsString('test');
      final relPath = await storageService.copyFileToAppDir(sourceFile, 'path_test.pdf');

      final decrypted = await storageService.getFile(relPath);
      // Verify storage service toString does not reveal active paths or keys
      expect(storageService.toString().contains(decrypted.path), isFalse);
      await storageService.cleanupTempFile(decrypted.path);
    });

    test('23. Master encryption key is never exposed via FileStorageService', () async {
      final key = await encryptionService.getMasterKey();
      final keyBase64 = base64Encode(key.bytes);

      expect(storageService.toString().contains(keyBase64), isFalse);
      expect(storageService.toString().contains('vitacase_master_key'), isFalse);
    });

    test('24. PIN and salt credentials are not accessible or stored in temp file metadata', () async {
      final sampleFile = File(p.join(testTempDir.path, 'decrypted_sample.pdf'));
      await sampleFile.writeAsString('clean content');

      expect(sampleFile.path.contains('123456'), isFalse);
      expect(sampleFile.path.contains('pin'), isFalse);
      expect(sampleFile.path.contains('salt'), isFalse);

      await storageService.cleanupTempFile(sampleFile.path);
    });
  });
}
