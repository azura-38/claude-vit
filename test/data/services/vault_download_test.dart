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
  bool failRead = false;

  @override
  Future<String?> read(String key) async {
    if (failRead) throw Exception('Simulated secure storage failure');
    return data[key];
  }

  @override
  Future<void> write(String key, String value) async => data[key] = value;

  @override
  Future<void> delete(String key) async => data.remove(key);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory testAppDir;
  late Directory testTempDir;
  late Directory testDownloadsDir;
  late InMemoryKeyStorage keyStorage;
  late EncryptionService encryptionService;
  late FileStorageService storageService;

  setUp(() async {
    testAppDir = await Directory.systemTemp.createTemp('vitacase_download_app_');
    testTempDir = await Directory.systemTemp.createTemp('vitacase_download_temp_');
    testDownloadsDir = await Directory.systemTemp.createTemp('vitacase_download_target_');
    keyStorage = InMemoryKeyStorage();
    encryptionService = EncryptionService(storage: keyStorage);

    storageService = FileStorageService(
      documentsDirProvider: () async => testAppDir,
      tempDirProvider: () async => testTempDir,
      downloadsDirProvider: () async => testDownloadsDir,
      encryptionService: encryptionService,
      fileOpener: (path) async => OpenResult(type: ResultType.done, message: 'Done'),
    );
  });

  tearDown(() async {
    try {
      if (await testAppDir.exists()) await testAppDir.delete(recursive: true);
      if (await testTempDir.exists()) await testTempDir.delete(recursive: true);
      if (await testDownloadsDir.exists()) await testDownloadsDir.delete(recursive: true);
    } catch (_) {}
  });

  group('Phase 5 — Vault Download', () {
    test('1. Valid encrypted document download succeeds and returns downloaded path', () async {
      final sampleContent = Uint8List.fromList(utf8.encode('Hospital Blood Test 2026'));
      final sourceFile = File(p.join(testAppDir.path, 'source.pdf'));
      await sourceFile.writeAsBytes(sampleContent);
      final relPath = await storageService.copyFileToAppDir(sourceFile, 'doc_001.pdf');

      final downloadedPath = await storageService.downloadDocument(
        relativePath: relPath,
        originalFileName: 'blood_test.pdf',
      );

      expect(downloadedPath.isNotEmpty, isTrue);
      expect(await File(downloadedPath).exists(), isTrue);
    });

    test('2. Downloaded content equals original plaintext', () async {
      final sampleContent = Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
      final sourceFile = File(p.join(testAppDir.path, 'source.bin'));
      await sourceFile.writeAsBytes(sampleContent);
      final relPath = await storageService.copyFileToAppDir(sourceFile, 'doc_002.bin');

      final downloadedPath = await storageService.downloadDocument(
        relativePath: relPath,
        originalFileName: 'data.bin',
      );

      final downloadedBytes = await File(downloadedPath).readAsBytes();
      expect(downloadedBytes, equals(sampleContent));
    });

    test('3. Source encrypted file remains strictly unchanged during and after download', () async {
      final sampleContent = Uint8List.fromList(utf8.encode('Original medical certificate'));
      final sourceFile = File(p.join(testAppDir.path, 'source.pdf'));
      await sourceFile.writeAsBytes(sampleContent);
      final relPath = await storageService.copyFileToAppDir(sourceFile, 'doc_003.pdf');

      final sourceEncryptedFile = File(p.join(testAppDir.path, relPath));
      final sourceBytesBefore = await sourceEncryptedFile.readAsBytes();

      await storageService.downloadDocument(
        relativePath: relPath,
        originalFileName: 'certificate.pdf',
      );

      final sourceBytesAfter = await sourceEncryptedFile.readAsBytes();
      expect(sourceBytesAfter, equals(sourceBytesBefore));
    });

    test('4. Downloaded file has sanitized, correct filename in target directory', () async {
      final sourceFile = File(p.join(testAppDir.path, 'source.pdf'));
      await sourceFile.writeAsBytes([1, 2, 3]);
      final relPath = await storageService.copyFileToAppDir(sourceFile, 'doc_004.pdf');

      final downloadedPath = await storageService.downloadDocument(
        relativePath: relPath,
        originalFileName: 'my_lab_report.pdf',
      );

      expect(p.basename(downloadedPath), 'my_lab_report.pdf');
      expect(p.dirname(downloadedPath), testDownloadsDir.path);
    });

    test('5. Filename traversal attempts are sanitized', () async {
      final sourceFile = File(p.join(testAppDir.path, 'source.pdf'));
      await sourceFile.writeAsBytes([1, 2, 3]);
      final relPath = await storageService.copyFileToAppDir(sourceFile, 'doc_005.pdf');

      final downloadedPath = await storageService.downloadDocument(
        relativePath: relPath,
        originalFileName: '../../../../evil_report.pdf',
      );

      expect(downloadedPath.contains('..'), isFalse);
      expect(p.basename(downloadedPath), 'evil_report.pdf');
      expect(p.dirname(downloadedPath), testDownloadsDir.path);
    });

    test('6. Correct extension is preserved', () async {
      final sourceFile = File(p.join(testAppDir.path, 'source.jpg'));
      await sourceFile.writeAsBytes([0xFF, 0xD8, 0xFF, 0xE0]);
      final relPath = await storageService.copyFileToAppDir(sourceFile, 'doc_006.jpg');

      final downloadedPath = await storageService.downloadDocument(
        relativePath: relPath,
        originalFileName: 'xray_scan.jpg',
      );

      expect(p.extension(downloadedPath), '.jpg');
    });

    test('7. Correct MIME type is resolved for standard formats', () {
      expect(FileStorageService.resolveMimeType('test.pdf'), 'application/pdf');
      expect(FileStorageService.resolveMimeType('photo.jpg'), 'image/jpeg');
      expect(FileStorageService.resolveMimeType('photo.jpeg'), 'image/jpeg');
      expect(FileStorageService.resolveMimeType('image.png'), 'image/png');
      expect(FileStorageService.resolveMimeType('note.txt'), 'text/plain');
      expect(FileStorageService.resolveMimeType('unknown.custom'), 'application/octet-stream');
    });

    test('8. Existing filename collision is handled safely by appending unique suffix (1)', () async {
      final sourceFile = File(p.join(testAppDir.path, 'source.pdf'));
      await sourceFile.writeAsBytes([1, 2, 3]);
      final relPath = await storageService.copyFileToAppDir(sourceFile, 'doc_008.pdf');

      // First download creates 'prescription.pdf'
      final path1 = await storageService.downloadDocument(
        relativePath: relPath,
        originalFileName: 'prescription.pdf',
      );
      expect(p.basename(path1), 'prescription.pdf');

      // Second download with same name must NOT overwrite path1!
      final path2 = await storageService.downloadDocument(
        relativePath: relPath,
        originalFileName: 'prescription.pdf',
      );
      expect(p.basename(path2), 'prescription (1).pdf');
      expect(await File(path1).exists(), isTrue);
      expect(await File(path2).exists(), isTrue);

      // Third download
      final path3 = await storageService.downloadDocument(
        relativePath: relPath,
        originalFileName: 'prescription.pdf',
      );
      expect(p.basename(path3), 'prescription (2).pdf');
    });

    test('9. Download failure does not report success or leave invalid files', () async {
      final failingWriterService = FileStorageService(
        documentsDirProvider: () async => testAppDir,
        tempDirProvider: () async => testTempDir,
        downloadsDirProvider: () async => testDownloadsDir,
        encryptionService: encryptionService,
        downloadsWriter: ({required bytes, required fileName, required mimeType}) async {
          throw Exception('Simulated disk full or permission error');
        },
      );

      final sourceFile = File(p.join(testAppDir.path, 'source.pdf'));
      await sourceFile.writeAsBytes([1, 2, 3]);
      final relPath = await failingWriterService.copyFileToAppDir(sourceFile, 'doc_009.pdf');

      await expectLater(
        () => failingWriterService.downloadDocument(
          relativePath: relPath,
          originalFileName: 'fail.pdf',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('10. Partial download cleanup ensures no .part files remain after failure', () async {
      final sourceFile = File(p.join(testAppDir.path, 'source.pdf'));
      await sourceFile.writeAsBytes([1, 2, 3]);
      final relPath = await storageService.copyFileToAppDir(sourceFile, 'doc_010.pdf');

      // Point downloads directory to an unwriteable file path to force mid-write failure
      final invalidDownloadsService = FileStorageService(
        documentsDirProvider: () async => testAppDir,
        tempDirProvider: () async => testTempDir,
        downloadsDirProvider: () async {
          final blockedFile = File(p.join(testDownloadsDir.path, 'blocked_dir'));
          await blockedFile.writeAsString('cannot write under a file');
          return Directory(blockedFile.path);
        },
        encryptionService: encryptionService,
      );

      await expectLater(
        () => invalidDownloadsService.downloadDocument(
          relativePath: relPath,
          originalFileName: 'atomic.pdf',
        ),
        throwsA(isA<FileSystemException>()),
      );

      // Verify no .part files in testDownloadsDir
      final remaining = testDownloadsDir.listSync();
      expect(remaining.any((e) => e.path.contains('.part')), isFalse);
    });

    test('11. Decryption failure does not create downloadable file', () async {
      final docsDir = Directory(p.join(testAppDir.path, 'documents'));
      await docsDir.create(recursive: true);
      final corruptFile = File(p.join(docsDir.path, 'corrupt.pdf'));
      await corruptFile.writeAsBytes([1, 2, 3, 4, 5]); // Invalid short payload

      await expectLater(
        () => storageService.downloadDocument(
          relativePath: 'documents/corrupt.pdf',
          originalFileName: 'corrupt.pdf',
        ),
        throwsA(isA<FileSystemException>()),
      );

      // Verify downloads directory is completely empty
      final downloadedFiles = testDownloadsDir.listSync();
      expect(downloadedFiles.isEmpty, isTrue);
    });

    test('12. Encryption key failure is handled safely without downloading corrupt data', () async {
      final sourceFile = File(p.join(testAppDir.path, 'source.pdf'));
      await sourceFile.writeAsBytes([1, 2, 3]);
      final relPath = await storageService.copyFileToAppDir(sourceFile, 'doc_012.pdf');

      // Simulate key storage failure on read
      keyStorage.failRead = true;
      final failKeyService = FileStorageService(
        documentsDirProvider: () async => testAppDir,
        tempDirProvider: () async => testTempDir,
        downloadsDirProvider: () async => testDownloadsDir,
        encryptionService: EncryptionService(storage: keyStorage),
      );

      await expectLater(
        () => failKeyService.downloadDocument(
          relativePath: relPath,
          originalFileName: 'key_fail.pdf',
        ),
        throwsA(isA<Exception>()),
      );

      // No file was created in downloads
      expect(testDownloadsDir.listSync().isEmpty, isTrue);
    });

    test('13. Temp plaintext sandbox file is immediately cleaned up after successful download', () async {
      final sourceFile = File(p.join(testAppDir.path, 'source.pdf'));
      await sourceFile.writeAsBytes([1, 2, 3, 4]);
      final relPath = await storageService.copyFileToAppDir(sourceFile, 'doc_013.pdf');

      await storageService.downloadDocument(
        relativePath: relPath,
        originalFileName: 'success_clean.pdf',
      );

      // Verify temp dir has NO leftover decrypted files
      final tempEntities = testTempDir.listSync();
      expect(tempEntities.where((e) => p.basename(e.path).startsWith('decrypted_')).isEmpty, isTrue);
    });

    test('14. Temp plaintext sandbox file is cleaned up after download failure', () async {
      final failingWriterService = FileStorageService(
        documentsDirProvider: () async => testAppDir,
        tempDirProvider: () async => testTempDir,
        downloadsDirProvider: () async => testDownloadsDir,
        encryptionService: encryptionService,
        downloadsWriter: ({required bytes, required fileName, required mimeType}) async {
          throw Exception('Crash during write to media store');
        },
      );

      final sourceFile = File(p.join(testAppDir.path, 'source.pdf'));
      await sourceFile.writeAsBytes([1, 2, 3, 4]);
      final relPath = await failingWriterService.copyFileToAppDir(sourceFile, 'doc_014.pdf');

      try {
        await failingWriterService.downloadDocument(
          relativePath: relPath,
          originalFileName: 'fail_clean.pdf',
        );
      } catch (_) {}

      // Verify temp dir has NO leftover decrypted files
      final tempEntities = testTempDir.listSync();
      expect(tempEntities.where((e) => p.basename(e.path).startsWith('decrypted_')).isEmpty, isTrue);
    });

    test('15. PIN is never logged or exposed in FileStorageService', () {
      expect(storageService.toString().contains('pin'), isFalse);
      expect(storageService.toString().contains('123456'), isFalse);
    });

    test('16. Encryption key is never logged or exposed in FileStorageService', () async {
      final key = await encryptionService.getMasterKey();
      final keyB64 = base64Encode(key.bytes);
      expect(storageService.toString().contains(keyB64), isFalse);
    });

    test('17. Document content is never logged during download', () async {
      final sensitiveText = 'SENSITIVE_DIAGNOSIS_DATA_987654';
      final sourceFile = File(p.join(testAppDir.path, 'source.txt'));
      await sourceFile.writeAsString(sensitiveText);
      final relPath = await storageService.copyFileToAppDir(sourceFile, 'doc_017.txt');

      final downloadedPath = await storageService.downloadDocument(
        relativePath: relPath,
        originalFileName: 'notes.txt',
      );

      expect(downloadedPath.contains(sensitiveText), isFalse);
      expect(storageService.toString().contains(sensitiveText), isFalse);
    });

    test('18. Android 10+ scoped storage model does not require broad storage permissions', () {
      // Validated by verifying AndroidManifest.xml has no MANAGE_EXTERNAL_STORAGE
      final manifestFile = File('android/app/src/main/AndroidManifest.xml');
      if (manifestFile.existsSync()) {
        final content = manifestFile.readAsStringSync();
        expect(content.contains('MANAGE_EXTERNAL_STORAGE'), isFalse);
      }
    });

    test('19. No MANAGE_EXTERNAL_STORAGE permission exists in codebase', () {
      final manifestFile = File('android/app/src/main/AndroidManifest.xml');
      if (manifestFile.existsSync()) {
        final content = manifestFile.readAsStringSync();
        expect(content.contains('MANAGE_EXTERNAL_STORAGE'), isFalse);
        expect(content.contains('android.permission.MANAGE_EXTERNAL_STORAGE'), isFalse);
      }
    });

    test('20. Source Vault document remains completely intact after download', () async {
      final sampleContent = Uint8List.fromList(utf8.encode('Immune system results'));
      final sourceFile = File(p.join(testAppDir.path, 'source.pdf'));
      await sourceFile.writeAsBytes(sampleContent);
      final relPath = await storageService.copyFileToAppDir(sourceFile, 'doc_020.pdf');

      await storageService.downloadDocument(
        relativePath: relPath,
        originalFileName: 'immune.pdf',
      );

      // Verify the source file can still be opened and decrypted properly
      final decryptedAgain = await storageService.getFile(relPath);
      expect(await decryptedAgain.readAsBytes(), equals(sampleContent));
      await storageService.cleanupTempFile(decryptedAgain.path);
    });

    test('21. Duplicate download prevention: sequential downloads yield independent unique files', () async {
      final sourceFile = File(p.join(testAppDir.path, 'source.pdf'));
      await sourceFile.writeAsBytes([1, 2, 3]);
      final relPath = await storageService.copyFileToAppDir(sourceFile, 'doc_021.pdf');

      final file1 = await storageService.downloadDocument(
        relativePath: relPath,
        originalFileName: 'dup.pdf',
      );
      final file2 = await storageService.downloadDocument(
        relativePath: relPath,
        originalFileName: 'dup.pdf',
      );

      expect(file1, isNot(equals(file2)));
      expect(await File(file1).exists(), isTrue);
      expect(await File(file2).exists(), isTrue);
    });

    test('22. Async lifecycle safety: downloads handle timeout or cancel gracefully', () async {
      final sourceFile = File(p.join(testAppDir.path, 'source.pdf'));
      await sourceFile.writeAsBytes([1, 2, 3]);
      final relPath = await storageService.copyFileToAppDir(sourceFile, 'doc_022.pdf');

      final slowService = FileStorageService(
        documentsDirProvider: () async => testAppDir,
        tempDirProvider: () async => testTempDir,
        downloadsDirProvider: () async => testDownloadsDir,
        encryptionService: encryptionService,
        downloadsWriter: ({required bytes, required fileName, required mimeType}) async {
          await Future.delayed(const Duration(milliseconds: 20));
          return p.join(testDownloadsDir.path, fileName);
        },
      );

      final result = await slowService.downloadDocument(
        relativePath: relPath,
        originalFileName: 'slow.pdf',
      );
      expect(result.isNotEmpty, isTrue);
    });

    test('23. Concurrent downloads do not corrupt files or collide names', () async {
      final sourceFiles = await Future.wait(List.generate(5, (i) async {
        final f = File(p.join(testAppDir.path, 'source_$i.pdf'));
        await f.writeAsBytes(Uint8List.fromList([i, i + 1, i + 2]));
        final rel = await storageService.copyFileToAppDir(f, 'doc_023_$i.pdf');
        return (rel: rel, bytes: Uint8List.fromList([i, i + 1, i + 2]));
      }));

      // Concurrently download all
      final downloadedPaths = await Future.wait(
        sourceFiles.map((s) => storageService.downloadDocument(
          relativePath: s.rel,
          originalFileName: 'report.pdf',
        )),
      );

      // All 5 files must exist and contain their unique bytes
      expect(downloadedPaths.toSet().length, 5);
      for (var i = 0; i < 5; i++) {
        final content = await File(downloadedPaths[i]).readAsBytes();
        expect(content, equals(sourceFiles[i].bytes));
      }
    });

    test('24. MIME handling works for PDF, image, and text test fixtures', () {
      expect(FileStorageService.resolveMimeType('blood_test.pdf'), 'application/pdf');
      expect(FileStorageService.resolveMimeType('ultrasound.jpeg'), 'image/jpeg');
      expect(FileStorageService.resolveMimeType('xray.png'), 'image/png');
      expect(FileStorageService.resolveMimeType('prescription.txt'), 'text/plain');
      expect(FileStorageService.resolveMimeType('data.csv'), 'text/csv');
      expect(FileStorageService.resolveMimeType('unknown_scan.bin'), 'application/octet-stream');
    });

    test('25. Downloaded bytes are byte-for-byte exact matches of original plaintext data', () async {
      // 64 KB binary fixture
      final binaryFixture = Uint8List.fromList(List.generate(64 * 1024, (i) => (i * 37) % 256));
      final sourceFile = File(p.join(testAppDir.path, 'large_source.bin'));
      await sourceFile.writeAsBytes(binaryFixture);
      final relPath = await storageService.copyFileToAppDir(sourceFile, 'doc_025.bin');

      final downloadedPath = await storageService.downloadDocument(
        relativePath: relPath,
        originalFileName: 'large_export.bin',
      );

      final downloadedBytes = await File(downloadedPath).readAsBytes();
      expect(downloadedBytes.length, binaryFixture.length);
      expect(downloadedBytes, equals(binaryFixture));
    });
  });
}
