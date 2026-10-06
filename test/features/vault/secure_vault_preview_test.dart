import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:vitacase/features/vault/presentation/providers/secure_vault_preview_controller.dart';
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory testAppDir;
  late Directory testTempDir;
  late InMemoryKeyStorage keyStorage;
  late EncryptionService encryptionService;
  late FileStorageService storageService;

  setUp(() async {
    testAppDir = await Directory.systemTemp.createTemp('vitacase_preview_test_app_');
    testTempDir = await Directory.systemTemp.createTemp('vitacase_preview_test_temp_');
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

  Widget buildTestWidget({required Widget child, required ProviderContainer container}) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('tr')],
        locale: const Locale('en'),
        home: Scaffold(body: child),
      ),
    );
  }

  group('Item 1 — Secure Vault Preview Controller & Overlay', () {
    test('1. Image document loads decrypted bytes via secureVaultPreviewProvider', () async {
      // 1x1 transparent png bytes
      final samplePng = Uint8List.fromList([
        0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
        0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
        0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
        0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
        0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
        0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82
      ]);

      final sourceFile = File(p.join(testAppDir.path, 'source_img.png'));
      await sourceFile.writeAsBytes(samplePng);
      final relPath = await storageService.copyFileToAppDir(sourceFile, 'vault_image.png');

      final doc = Document(
        id: 'doc-1',
        fileName: 'vault_image.png',
        fileType: DocumentFileType.image,
        localPath: relPath,
        category: DocumentCategory.healthImages,
        createdAt: DateTime.now(),
      );

      final container = ProviderContainer(
        overrides: [
          fileStorageServiceProvider.overrideWithValue(storageService),
        ],
      );
      addTearDown(container.dispose);

      final previewData = await container.read(secureVaultPreviewProvider(doc).future);
      expect(previewData.isImage, isTrue);
      expect(previewData.isDecrypted, isTrue);
      expect(previewData.imageBytes, equals(samplePng));
    });

    test('2. PDF document resolves metadata preview securely without remote calls', () async {
      final doc = Document(
        id: 'doc-2',
        fileName: 'blood_test.pdf',
        fileType: DocumentFileType.pdf,
        localPath: 'documents/blood_test.pdf',
        category: DocumentCategory.healthReports,
        createdAt: DateTime.now(),
      );

      final container = ProviderContainer(
        overrides: [
          fileStorageServiceProvider.overrideWithValue(storageService),
        ],
      );
      addTearDown(container.dispose);

      final previewData = await container.read(secureVaultPreviewProvider(doc).future);
      expect(previewData.isImage, isFalse);
      expect(previewData.isDecrypted, isTrue);
      expect(previewData.fileType, equals(DocumentFileType.pdf));
      expect(previewData.fileName, equals('blood_test.pdf'));
    });

    testWidgets('3. VaultPreviewOverlay renders PDF card with Open PDF badge and triggers onTap', (tester) async {
      final doc = Document(
        id: 'doc-3',
        fileName: 'prescription.pdf',
        fileType: DocumentFileType.pdf,
        localPath: 'documents/prescription.pdf',
        category: DocumentCategory.healthPrescriptions,
        createdAt: DateTime.now(),
      );

      final container = ProviderContainer(
        overrides: [
          fileStorageServiceProvider.overrideWithValue(storageService),
        ],
      );
      addTearDown(container.dispose);

      bool tapped = false;

      await tester.pumpWidget(
        buildTestWidget(
          container: container,
          child: VaultPreviewOverlay(
            document: doc,
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('prescription.pdf'), findsOneWidget);
      expect(find.text('Open PDF'), findsOneWidget);
      expect(find.byIcon(Icons.picture_as_pdf_rounded), findsOneWidget);

      await tester.tap(find.text('Open PDF'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('4. VaultPreviewOverlay renders generic placeholder when document is null', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        buildTestWidget(
          container: container,
          child: const VaultPreviewOverlay(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Tap to preview'), findsOneWidget);
      expect(find.byIcon(Icons.visibility_rounded), findsOneWidget);
    });
  });
}
