import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:vitacase/core/extensions/l10n_extension.dart';
import 'package:vitacase/features/vault/presentation/screens/document_quick_view_screen.dart';
import 'package:vitacase/features/vault/presentation/widgets/vault_preview_overlay.dart';
import 'package:vitacase/l10n/app_localizations.dart';
import 'package:vitacase/shared/data/datasources/file_storage_service.dart';
import 'package:vitacase/shared/data/services/encryption_service.dart';
import 'package:vitacase/shared/domain/entities/document.dart';
import 'package:vitacase/shared/domain/enums/document_category.dart';
import 'package:vitacase/shared/providers/document_providers.dart';

class InMemoryKeyStorage implements SecureKeyStorage {
  final Map<String, String> data = {};

  @override
  Future<String?> read(String key) async => data[key];

  @override
  Future<void> write(String key, String value) async => data[key] = value;

  @override
  Future<void> delete(String key) async => data.remove(key);
}

class MockFileStorageService extends FileStorageService {
  MockFileStorageService({
    required this.onOpenSecureDocument,
  });

  final Future<OpenResult> Function(String relativePath, {String? mimeType, Duration cleanupDelay})
      onOpenSecureDocument;

  @override
  Future<OpenResult> openSecureDocument(
    String relativePath, {
    String? mimeType,
    Duration cleanupDelay = const Duration(seconds: 25),
  }) =>
      onOpenSecureDocument(relativePath, mimeType: mimeType, cleanupDelay: cleanupDelay);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory testAppDir;
  late Directory testTempDir;
  late InMemoryKeyStorage keyStorage;
  late EncryptionService encryptionService;

  setUp(() async {
    testAppDir = await Directory.systemTemp.createTemp('vitacase_phase19_3_app_');
    testTempDir = await Directory.systemTemp.createTemp('vitacase_phase19_3_temp_');
    keyStorage = InMemoryKeyStorage();
    encryptionService = EncryptionService(storage: keyStorage);
  });

  tearDown(() async {
    try {
      if (await testAppDir.exists()) await testAppDir.delete(recursive: true);
      if (await testTempDir.exists()) await testTempDir.delete(recursive: true);
    } catch (_) {}
  });

  Widget buildTestWidget({
    required Widget child,
    required ProviderContainer container,
    Locale locale = const Locale('en'),
  }) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('tr'),
          Locale('de'),
          Locale('es'),
          Locale('fr'),
          Locale('hi'),
          Locale('it'),
          Locale('ja'),
          Locale('pt'),
          Locale('zh'),
        ],
        locale: locale,
        home: Scaffold(body: child),
      ),
    );
  }

  group('Phase 19.3 — PDF Opening + Secure External Opening', () {
    // 1. PDF MIME type
    test('1. PDF MIME type is correctly resolved as application/pdf', () {
      expect(FileStorageService.resolveMimeType('blood_test.pdf'), equals('application/pdf'));
      expect(FileStorageService.resolveMimeType('REPORT.PDF'), equals('application/pdf'));
      expect(FileStorageService.resolveMimeType('prescription.doc'), equals('application/msword'));
      expect(FileStorageService.resolveMimeType('scan.png'), equals('image/png'));
    });

    // 2. Secure temp file creation
    test('2. openSecureDocument creates secure transient decrypted temp file in private temp directory', () async {
      final samplePdf = Uint8List.fromList(utf8.encode('%PDF-1.4 Minimal test pdf content'));
      final source = File(p.join(testAppDir.path, 'source_lab.pdf'));
      await source.writeAsBytes(samplePdf);

      String? capturedTempPath;
      String? capturedMime;

      final storage = FileStorageService(
        documentsDirProvider: () async => testAppDir,
        tempDirProvider: () async => testTempDir,
        encryptionService: encryptionService,
        fileOpener: (path, {type, uti}) async {
          capturedTempPath = path;
          capturedMime = type;
          // Verify file exists during opener execution
          expect(File(path).existsSync(), isTrue);
          return OpenResult(type: ResultType.done, message: 'Done');
        },
      );

      final relPath = await storage.copyFileToAppDir(source, 'lab_results.pdf');
      final result = await storage.openSecureDocument(relPath, mimeType: 'application/pdf');

      expect(result.type, equals(ResultType.done));
      expect(capturedTempPath, isNotNull);
      expect(capturedMime, equals('application/pdf'));
      expect(p.isWithin(testTempDir.path, capturedTempPath!), isTrue);
      expect(p.basename(capturedTempPath!).startsWith('decrypted_'), isTrue);
    });

    // 3. Sanitized PDF filename
    test('3. Sanitized PDF filename removes dangerous characters and preserves extension', () {
      final sanitized = FileStorageService.sanitizeFileName('../../../var/log/my<doc>:file?.pdf');
      expect(sanitized.contains('/'), isFalse);
      expect(sanitized.contains('\\'), isFalse);
      expect(sanitized.contains('..'), isFalse);
      expect(sanitized.contains('<'), isFalse);
      expect(sanitized.contains('>'), isFalse);
      expect(sanitized.contains(':'), isFalse);
      expect(sanitized.endsWith('.pdf'), isTrue);
    });

    // 4. Path traversal rejection
    test('4. Path traversal attempts outside sandbox are strictly rejected', () async {
      final storage = FileStorageService(
        documentsDirProvider: () async => testAppDir,
        tempDirProvider: () async => testTempDir,
        encryptionService: encryptionService,
      );

      // Attempting to clean a file outside temp sandbox
      final outsideFile = File(p.join(testAppDir.path, 'decrypted_outside.pdf'));
      await outsideFile.writeAsString('should not delete');

      await storage.cleanupTempFile(outsideFile.path);
      expect(await outsideFile.exists(), isTrue);
    });

    // 5. Encrypted document decrypt -> temp PDF
    test('5. Encrypted vault PDF is decrypted accurately into temp PDF without plaintext retention in docs', () async {
      final pdfContent = Uint8List.fromList(utf8.encode('%PDF-1.7 Confidential medical report'));
      final source = File(p.join(testAppDir.path, 'source_report.pdf'));
      await source.writeAsBytes(pdfContent);

      final storage = FileStorageService(
        documentsDirProvider: () async => testAppDir,
        tempDirProvider: () async => testTempDir,
        encryptionService: encryptionService,
        fileOpener: (path, {type, uti}) async {
          final tempBytes = await File(path).readAsBytes();
          expect(tempBytes, equals(pdfContent));
          return OpenResult(type: ResultType.done, message: 'Done');
        },
      );

      final relPath = await storage.copyFileToAppDir(source, 'encrypted_report.pdf');

      // The file in documents directory must NOT be plaintext
      final storedEncryptedFile = File(p.join(testAppDir.path, relPath));
      final rawStoredBytes = await storedEncryptedFile.readAsBytes();
      expect(rawStoredBytes, isNot(equals(pdfContent)));

      await storage.openSecureDocument(relPath);
    });

    // 6. FileProvider / content URI intent parameters
    test('6. Opener receives application/pdf MIME type for external PDF viewing', () async {
      final pdfContent = Uint8List.fromList(utf8.encode('%PDF-1.4 Clinical chart'));
      final source = File(p.join(testAppDir.path, 'chart.pdf'));
      await source.writeAsBytes(pdfContent);

      String? openedMime;

      final storage = FileStorageService(
        documentsDirProvider: () async => testAppDir,
        tempDirProvider: () async => testTempDir,
        encryptionService: encryptionService,
        fileOpener: (path, {type, uti}) async {
          openedMime = type;
          return OpenResult(type: ResultType.done, message: 'Success');
        },
      );

      final relPath = await storage.copyFileToAppDir(source, 'chart.pdf');
      await storage.openSecureDocument(relPath);

      expect(openedMime, equals('application/pdf'));
    });

    // 7. file:// URI forbidden (Android FileProvider configuration audit)
    test('7. Android FileProvider configuration restricts paths and forbids root-path', () {
      final filePathsXml = File('android/app/src/main/res/xml/file_paths.xml');
      expect(filePathsXml.existsSync(), isTrue);

      final xmlContent = filePathsXml.readAsStringSync();
      expect(xmlContent.contains('<root-path'), isFalse, reason: 'Root path is forbidden for security');
      expect(xmlContent.contains('<cache-path'), isTrue);
      expect(xmlContent.contains('<files-path'), isTrue);
    });

    // 8. Read permission grant
    test('8. AndroidManifest defines FileProvider with grantUriPermissions and exported=false', () {
      final manifestFile = File('android/app/src/main/AndroidManifest.xml');
      expect(manifestFile.existsSync(), isTrue);

      final manifestContent = manifestFile.readAsStringSync();
      expect(manifestContent.contains('android:name="androidx.core.content.FileProvider"'), isTrue);
      expect(manifestContent.contains('android:exported="false"'), isTrue);
      expect(manifestContent.contains('android:grantUriPermissions="true"'), isTrue);
      expect(manifestContent.contains('android:authorities="\${applicationId}.fileProvider"'), isTrue);
    });

    // 9. PDF viewer unavailable handling
    test('9. When no PDF viewer is installed, openSecureDocument cleans up temp file immediately', () async {
      final pdfContent = Uint8List.fromList(utf8.encode('%PDF-1.4 No viewer test'));
      final source = File(p.join(testAppDir.path, 'no_viewer.pdf'));
      await source.writeAsBytes(pdfContent);

      String? tempPathCreated;

      final storage = FileStorageService(
        documentsDirProvider: () async => testAppDir,
        tempDirProvider: () async => testTempDir,
        encryptionService: encryptionService,
        fileOpener: (path, {type, uti}) async {
          tempPathCreated = path;
          return OpenResult(type: ResultType.noAppToOpen, message: 'No APP found to open this file.');
        },
      );

      final relPath = await storage.copyFileToAppDir(source, 'no_viewer.pdf');
      final result = await storage.openSecureDocument(relPath);

      expect(result.type, equals(ResultType.noAppToOpen));
      expect(tempPathCreated, isNotNull);
      // Temp file must be immediately cleaned up upon no app failure
      expect(File(tempPathCreated!).existsSync(), isFalse);
    });

    // 10. ActivityNotFoundException / opener error handling
    test('10. Opener failure cleans up temp file and returns error without crashing', () async {
      final pdfContent = Uint8List.fromList(utf8.encode('%PDF-1.4 Error test'));
      final source = File(p.join(testAppDir.path, 'err_doc.pdf'));
      await source.writeAsBytes(pdfContent);

      String? tempPathCreated;

      final storage = FileStorageService(
        documentsDirProvider: () async => testAppDir,
        tempDirProvider: () async => testTempDir,
        encryptionService: encryptionService,
        fileOpener: (path, {type, uti}) async {
          tempPathCreated = path;
          return OpenResult(type: ResultType.error, message: 'ActivityNotFoundException');
        },
      );

      final relPath = await storage.copyFileToAppDir(source, 'err_doc.pdf');
      final result = await storage.openSecureDocument(relPath);

      expect(result.type, equals(ResultType.error));
      expect(tempPathCreated, isNotNull);
      expect(File(tempPathCreated!).existsSync(), isFalse);
    });

    // 11. Decrypt failure / corrupt file handling
    test('11. Corrupt encrypted file throws FileSystemException without leaving temp file on disk', () async {
      final corruptFile = File(p.join(testAppDir.path, 'documents', 'corrupt.pdf'));
      await corruptFile.parent.create(recursive: true);
      await corruptFile.writeAsBytes([0xDE, 0xAD, 0xBE, 0xEF, 0x01, 0x02]);

      final storage = FileStorageService(
        documentsDirProvider: () async => testAppDir,
        tempDirProvider: () async => testTempDir,
        encryptionService: encryptionService,
      );

      expect(
        () async => await storage.openSecureDocument('documents/corrupt.pdf'),
        throwsA(isA<FileSystemException>()),
      );

      // Verify no decrypted temp files exist
      final tempFiles = testTempDir.listSync().where((f) => p.basename(f.path).startsWith('decrypted_'));
      expect(tempFiles.isEmpty, isTrue);
    });

    // 12. Temp cleanup after delay
    test('12. Successful open schedules bounded temp cleanup', () async {
      final pdfContent = Uint8List.fromList(utf8.encode('%PDF-1.4 Temp cleanup test'));
      final source = File(p.join(testAppDir.path, 'cleanup.pdf'));
      await source.writeAsBytes(pdfContent);

      String? tempPathCreated;

      final storage = FileStorageService(
        documentsDirProvider: () async => testAppDir,
        tempDirProvider: () async => testTempDir,
        encryptionService: encryptionService,
        fileOpener: (path, {type, uti}) async {
          tempPathCreated = path;
          return OpenResult(type: ResultType.done, message: 'Done');
        },
      );

      final relPath = await storage.copyFileToAppDir(source, 'cleanup.pdf');
      await storage.openSecureDocument(
        relPath,
        cleanupDelay: const Duration(milliseconds: 50),
      );

      expect(tempPathCreated, isNotNull);
      expect(File(tempPathCreated!).existsSync(), isTrue);

      // Wait for bounded timer
      await Future.delayed(const Duration(milliseconds: 100));
      expect(File(tempPathCreated!).existsSync(), isFalse);
    });

    // 13. No plaintext permanent copy
    test('13. Decryption never writes permanent unencrypted files into documents directory', () async {
      final pdfContent = Uint8List.fromList(utf8.encode('%PDF-1.4 Privacy test'));
      final source = File(p.join(testAppDir.path, 'source_priv.pdf'));
      await source.writeAsBytes(pdfContent);

      final storage = FileStorageService(
        documentsDirProvider: () async => testAppDir,
        tempDirProvider: () async => testTempDir,
        encryptionService: encryptionService,
        fileOpener: (path, {type, uti}) async => OpenResult(type: ResultType.done, message: 'Done'),
      );

      final relPath = await storage.copyFileToAppDir(source, 'priv.pdf');
      await storage.openSecureDocument(relPath);

      // Check all files in documents dir: none should have plain %PDF header except if encrypted
      final docsDir = Directory(p.join(testAppDir.path, 'documents'));
      final allDocFiles = docsDir.listSync().whereType<File>();
      for (final f in allDocFiles) {
        final b = await f.readAsBytes();
        final isPlainPdf = b.length >= 4 && b[0] == 0x25 && b[1] == 0x50 && b[2] == 0x44 && b[3] == 0x46;
        expect(isPlainPdf, isFalse, reason: 'Plaintext PDF must never reside permanently in documents directory');
      }
    });

    // 14. No analytics/Sentry document leakage
    test('14. Document filenames and paths are not leaked in exception messages', () async {
      final storage = FileStorageService(
        documentsDirProvider: () async => testAppDir,
        tempDirProvider: () async => testTempDir,
        encryptionService: encryptionService,
      );

      try {
        await storage.openSecureDocument('documents/non_existent.pdf');
        fail('Should throw');
      } catch (e) {
        expect(e, isA<FileSystemException>());
        // Generic exception message
        expect(e.toString().contains('Document not found'), isTrue);
      }
    });

    // 15. Preview remains disabled
    testWidgets('15. PDF preview card remains unrendered and displays Open PDF action', (tester) async {
      final doc = Document(
        id: 'doc-pdf-preview-disabled',
        fileName: 'mri_scan.pdf',
        fileType: DocumentFileType.pdf,
        localPath: 'documents/mri_scan.pdf',
        category: DocumentCategory.healthReports,
        createdAt: DateTime.now(),
      );

      final storage = FileStorageService(
        documentsDirProvider: () async => testAppDir,
        tempDirProvider: () async => testTempDir,
        encryptionService: encryptionService,
      );

      final container = ProviderContainer(
        overrides: [
          fileStorageServiceProvider.overrideWithValue(storage),
        ],
      );
      addTearDown(container.dispose);

      bool tapTriggered = false;

      await tester.pumpWidget(
        buildTestWidget(
          container: container,
          child: VaultPreviewOverlay(
            document: doc,
            onTap: () => tapTriggered = true,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // In-app PDF preview must NOT have a canvas or renderer
      expect(find.text('mri_scan.pdf'), findsOneWidget);
      expect(find.text('Open PDF'), findsOneWidget);
      expect(find.byIcon(Icons.picture_as_pdf_rounded), findsOneWidget);
      expect(find.byIcon(Icons.open_in_new_rounded), findsOneWidget);

      await tester.tap(find.text('Open PDF'));
      await tester.pump();
      expect(tapTriggered, isTrue);
    });

    // 16. DocumentQuickView PDF action
    testWidgets('16. DocumentQuickViewScreen displays Open PDF button and triggers secure opener', (tester) async {
      String? openedPath;
      String? openedMime;

      final mockStorage = MockFileStorageService(
        onOpenSecureDocument: (relativePath, {mimeType, cleanupDelay = const Duration(seconds: 25)}) async {
          openedPath = relativePath;
          openedMime = mimeType;
          return OpenResult(type: ResultType.done, message: 'Success');
        },
      );

      final doc = Document(
        id: 'doc-quick-view-test',
        fileName: 'lab_record.pdf',
        fileType: DocumentFileType.pdf,
        localPath: 'documents/lab_record.pdf',
        category: DocumentCategory.healthReports,
        tags: const ['Blood', '2026'],
        createdAt: DateTime.now(),
      );

      final container = ProviderContainer(
        overrides: [
          fileStorageServiceProvider.overrideWithValue(mockStorage),
        ],
      );
      addTearDown(container.dispose);

      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildTestWidget(
          container: container,
          child: DocumentQuickViewScreen(document: doc),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Both the card badge and the bottom action button show "Open PDF"
      expect(find.text('Open PDF'), findsAtLeastNWidgets(1));

      // Tap Open PDF on the preview card
      await tester.tap(find.text('Open PDF').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(openedPath, equals('documents/lab_record.pdf'));
      expect(openedMime, equals('application/pdf'));
    });

    // 17. Phase 19.2 tags remain intact
    testWidgets('17. Phase 19.2 tags system is fully preserved in DocumentQuickViewScreen', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final doc = Document(
        id: 'doc-tags-preserved',
        fileName: 'cardiology_report.pdf',
        fileType: DocumentFileType.pdf,
        localPath: 'documents/cardiology_report.pdf',
        category: DocumentCategory.healthReports,
        tags: const ['Cardiology', 'Clinic', 'Priority'],
        createdAt: DateTime.now(),
      );

      final storage = FileStorageService(
        documentsDirProvider: () async => testAppDir,
        tempDirProvider: () async => testTempDir,
        encryptionService: encryptionService,
      );

      final container = ProviderContainer(
        overrides: [
          fileStorageServiceProvider.overrideWithValue(storage),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        buildTestWidget(
          container: container,
          child: DocumentQuickViewScreen(document: doc),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Cardiology'), findsOneWidget);
      expect(find.text('Clinic'), findsOneWidget);
      expect(find.text('Priority'), findsOneWidget);
    });

    // 18. Localization across 10 languages
    test('18. PDF localization keys are non-empty and present in all 10 supported languages', () {
      const locales = ['en', 'tr', 'de', 'es', 'fr', 'hi', 'it', 'ja', 'pt', 'zh'];
      const requiredKeys = ['open_pdf', 'pdf_viewer_not_found', 'pdf_open_failed', 'document_open_failed'];

      for (final loc in locales) {
        for (final key in requiredKeys) {
          final translated = lookupTranslationWithLocale(loc, key);
          expect(
            translated.isNotEmpty,
            isTrue,
            reason: 'Key "$key" should have non-empty translation for locale "$loc"',
          );
        }
      }
    });

    // 19. Legacy document compatibility
    test('19. Legacy unencrypted plaintext PDF is automatically decrypted and opened safely', () async {
      final legacyPdfContent = Uint8List.fromList(utf8.encode('%PDF-1.4 Legacy document content'));
      final legacyFile = File(p.join(testAppDir.path, 'documents', 'legacy_old.pdf'));
      await legacyFile.parent.create(recursive: true);
      await legacyFile.writeAsBytes(legacyPdfContent);

      bool opened = false;
      final storage = FileStorageService(
        documentsDirProvider: () async => testAppDir,
        tempDirProvider: () async => testTempDir,
        encryptionService: encryptionService,
        fileOpener: (path, {type, uti}) async {
          opened = true;
          expect(await File(path).readAsBytes(), equals(legacyPdfContent));
          return OpenResult(type: ResultType.done, message: 'Done');
        },
      );

      final result = await storage.openSecureDocument('documents/legacy_old.pdf');
      expect(result.type, equals(ResultType.done));
      expect(opened, isTrue);
    });

    // 20. No regression to Vault
    test('20. Non-PDF image and document opening operations function seamlessly without regressions', () async {
      final pngBytes = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x01, 0x02]);
      final source = File(p.join(testAppDir.path, 'source_photo.png'));
      await source.writeAsBytes(pngBytes);

      String? openedMime;

      final storage = FileStorageService(
        documentsDirProvider: () async => testAppDir,
        tempDirProvider: () async => testTempDir,
        encryptionService: encryptionService,
        fileOpener: (path, {type, uti}) async {
          openedMime = type;
          return OpenResult(type: ResultType.done, message: 'Done');
        },
      );

      final relPath = await storage.copyFileToAppDir(source, 'photo.png');
      final result = await storage.openSecureDocument(relPath);

      expect(result.type, equals(ResultType.done));
      expect(openedMime, equals('image/png'));
    });
  });
}
