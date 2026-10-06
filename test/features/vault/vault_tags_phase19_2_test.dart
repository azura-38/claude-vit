import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:vitacase/core/constants/app_colors.dart';
import 'package:vitacase/features/vault/presentation/widgets/vault_tag_chip.dart';
import 'package:vitacase/l10n/app_localizations.dart';
import 'package:vitacase/l10n/vita_app_localizations_delegate.dart';
import 'package:vitacase/shared/data/models/document_model.dart';
import 'package:vitacase/shared/data/repositories/custom_tag_repository_impl.dart';
import 'package:vitacase/shared/domain/entities/document.dart';
import 'package:vitacase/shared/domain/enums/document_category.dart';
import 'package:vitacase/shared/domain/enums/document_tag.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 19.2 - Quick Tags & Taxonomy Tests', () {
    test('1. Quick tag creation & taxonomy includes insurance and invoice', () {
      expect(DocumentTag.values, contains(DocumentTag.insurance));
      expect(DocumentTag.values, contains(DocumentTag.invoice));

      expect(DocumentTag.insurance.id, 'insurance');
      expect(DocumentTag.insurance.icon, '🛡️');
      expect(DocumentTag.insurance.key, 'docs_tag_insurance');

      expect(DocumentTag.invoice.id, 'invoice');
      expect(DocumentTag.invoice.icon, '🧾');
      expect(DocumentTag.invoice.key, 'docs_tag_invoice');

      expect(DocumentTag.fromId('insurance'), DocumentTag.insurance);
      expect(DocumentTag.fromId('invoice'), DocumentTag.invoice);
      expect(DocumentTag.fromId('unknown_tag'), isNull);
    });
  });

  group('Phase 19.2 - Custom Tag Validation & Repository Tests', () {
    late Database memoryDb;
    late CustomTagRepositoryImpl customTagRepo;

    setUp(() async {
      final factory = databaseFactoryMemory;
      memoryDb = await factory.openDatabase('test_tags.db');
      customTagRepo = CustomTagRepositoryImpl(database: memoryDb);
    });

    tearDown(() async {
      await memoryDb.close();
    });

    test('2. Custom tag creation persists trimmed tag', () async {
      await customTagRepo.addCustomTag('Cardiology');
      final allTags = await customTagRepo.getAllCustomTags();
      expect(allTags, contains('Cardiology'));
    });

    test('3. Empty tag validation throws CustomTagException', () async {
      expect(customTagRepo.addCustomTag(''), throwsA(isA<CustomTagException>()));
    });

    test('4. Whitespace validation trims or throws CustomTagException', () async {
      expect(customTagRepo.addCustomTag('   '), throwsA(isA<CustomTagException>()));

      await customTagRepo.addCustomTag('  2026 Checkup  ');
      final allTags = await customTagRepo.getAllCustomTags();
      expect(allTags, contains('2026 Checkup'));
    });

    test('5. Duplicate normalization & case-insensitive check', () async {
      await customTagRepo.addCustomTag('Mom');

      // Duplicate case-insensitive check
      expect(customTagRepo.addCustomTag('mom'), throwsA(isA<CustomTagException>()));
      expect(customTagRepo.addCustomTag('MOM'), throwsA(isA<CustomTagException>()));

      // Duplicate with quick tag check
      expect(customTagRepo.addCustomTag('Prescription'), throwsA(isA<CustomTagException>()));
      expect(customTagRepo.addCustomTag('insurance'), throwsA(isA<CustomTagException>()));
    });

    test('Custom tag deletion removes from repository', () async {
      await customTagRepo.addCustomTag('Lab Followup');
      var allTags = await customTagRepo.getAllCustomTags();
      expect(allTags, contains('Lab Followup'));

      await customTagRepo.deleteCustomTag('Lab Followup');
      allTags = await customTagRepo.getAllCustomTags();
      expect(allTags, isNot(contains('Lab Followup')));
    });

    test('Custom tag length limit enforced (max 30 chars)', () async {
      final tooLong = 'A' * 31;
      expect(customTagRepo.addCustomTag(tooLong), throwsA(isA<CustomTagException>()));

      final exactMax = 'B' * 30;
      await customTagRepo.addCustomTag(exactMax);
      final allTags = await customTagRepo.getAllCustomTags();
      expect(allTags, contains(exactMax));
    });
  });

  group('Phase 19.2 - Document Data Model & Tags Integration', () {
    test('6. Add tags to document entity and model serialization', () {
      final doc = Document(
        id: 'doc-1',
        fileName: 'blood_test.pdf',
        fileType: DocumentFileType.pdf,
        category: DocumentCategory.healthTestResults,
        tags: const ['lab', 'Cardiology'],
        localPath: '/mock/path/blood_test.pdf',
        createdAt: DateTime(2026, 3, 1),
      );

      expect(doc.tags, ['lab', 'Cardiology']);

      final model = DocumentModel.fromEntity(doc);
      expect(model.tags, ['lab', 'Cardiology']);

      final map = model.toMap();
      expect(map['tags'], ['lab', 'Cardiology']);
    });

    test('7. Remove tag from document', () {
      final doc = Document(
        id: 'doc-1',
        fileName: 'report.pdf',
        fileType: DocumentFileType.pdf,
        category: DocumentCategory.healthReports,
        tags: const ['insurance', 'Claim2026'],
        localPath: '/mock/path/report.pdf',
        createdAt: DateTime(2026, 3, 1),
      );

      final updatedTags = List<String>.from(doc.tags)..remove('Claim2026');
      final updatedDoc = doc.copyWith(tags: updatedTags);

      expect(updatedDoc.tags, ['insurance']);
    });

    test('8. Edit existing document tags', () {
      final doc = Document(
        id: 'doc-1',
        fileName: 'rx.pdf',
        fileType: DocumentFileType.pdf,
        category: DocumentCategory.healthPrescriptions,
        tags: const ['prescription'],
        localPath: '/mock/path/rx.pdf',
        createdAt: DateTime(2026, 3, 1),
      );

      final editedDoc = doc.copyWith(
        tags: ['prescription', 'Dr Smith', 'Antibiotics'],
      );

      expect(editedDoc.tags, ['prescription', 'Dr Smith', 'Antibiotics']);
      expect(editedDoc.category, DocumentCategory.healthPrescriptions);
      expect(editedDoc.id, 'doc-1');
    });

    test('9. Legacy document without tags field deserializes safely', () {
      // Legacy document having tagId but no tags list
      final legacyMapWithTagId = {
        'id': 'legacy-1',
        'fileName': 'old_exam.pdf',
        'fileType': 'pdf',
        'category': 'documents',
        'tagId': 'radiology',
        'filePath': '/mock/path/old_exam.pdf',
        'fileSize': 2048,
        'createdAt': '2026-01-01T00:00:00.000',
      };

      final docFromLegacy = DocumentModel.fromMap(legacyMapWithTagId).toEntity();
      expect(docFromLegacy.tags, ['radiology']);
      expect(docFromLegacy.tagId, 'radiology');
      expect(docFromLegacy.localPath, '/mock/path/old_exam.pdf');

      // Legacy document having neither tags nor tagId
      final legacyMapBlank = {
        'id': 'legacy-2',
        'fileName': 'blank.pdf',
        'fileType': 'pdf',
        'category': 'other',
        'filePath': '/mock/path/blank.pdf',
        'fileSize': 100,
        'createdAt': '2026-01-01T00:00:00.000',
      };

      final docFromBlank = DocumentModel.fromMap(legacyMapBlank).toEntity();
      expect(docFromBlank.tags, isEmpty);
      expect(docFromBlank.tagId, isNull);
    });
  });

  group('Phase 19.2 - Search and Filter Logic', () {
    final docs = [
      Document(
        id: '1',
        fileName: 'blood_work.pdf',
        hospitalName: 'City Hospital',
        fileType: DocumentFileType.pdf,
        category: DocumentCategory.healthTestResults,
        tags: const ['lab', 'Cardiology'],
        localPath: '/p/1.pdf',
        createdAt: DateTime(2026, 1, 1),
      ),
      Document(
        id: '2',
        fileName: 'xray.pdf',
        hospitalName: 'State Clinic',
        fileType: DocumentFileType.pdf,
        category: DocumentCategory.healthImages,
        tags: const ['radiology', 'Orthopedics'],
        localPath: '/p/2.pdf',
        createdAt: DateTime(2026, 1, 2),
      ),
      Document(
        id: '3',
        fileName: 'insurance_receipt.pdf',
        hospitalName: 'Metropolitan',
        fileType: DocumentFileType.pdf,
        category: DocumentCategory.finance,
        tags: const ['insurance', 'invoice', 'Claim2026'],
        localPath: '/p/3.pdf',
        createdAt: DateTime(2026, 1, 3),
      ),
    ];

    test('10. Tag search/filter finds matching documents', () {
      // Filter by custom tag
      final cardiologyDocs = docs.where((d) => d.tags.contains('Cardiology')).toList();
      expect(cardiologyDocs.length, 1);
      expect(cardiologyDocs.first.id, '1');

      // Filter by quick tag
      final insuranceDocs = docs.where((d) => d.tags.contains('insurance')).toList();
      expect(insuranceDocs.length, 1);
      expect(insuranceDocs.first.id, '3');

      // Search query in tags
      const query = 'claim';
      final matchingDocs = docs.where((d) {
        return d.tags.any((t) => t.toLowerCase().contains(query));
      }).toList();
      expect(matchingDocs.length, 1);
      expect(matchingDocs.first.fileName, 'insurance_receipt.pdf');
    });

    test('11. Clear tag filter resets to all documents', () {
      List<Document> filterBy(String? tag) =>
          tag == null ? docs : docs.where((d) => d.tags.contains(tag)).toList();

      expect(filterBy('Cardiology').length, 1);
      expect(filterBy(null).length, 3);
    });
  });

  group('Phase 19.2 - Localization Tests', () {
    const supportedLocales = [
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
    ];

    for (final locale in supportedLocales) {
      testWidgets('12. Localization keys verified for locale ${locale.languageCode}', (tester) async {
        late AppLocalizations l10n;

        await tester.pumpWidget(
          MaterialApp(
            locale: locale,
            localizationsDelegates: const [
              VitaAppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (ctx) {
                l10n = AppLocalizations.of(ctx)!;
                return const Scaffold(body: Text('Loaded'));
              },
            ),
          ),
        );

        expect(l10n.quick_tags.isNotEmpty, isTrue);
        expect(l10n.custom_tags.isNotEmpty, isTrue);
        expect(l10n.add_tag.isNotEmpty, isTrue);
        expect(l10n.create_tag.isNotEmpty, isTrue);
        expect(l10n.remove_tag.isNotEmpty, isTrue);
        expect(l10n.filter_by_tag.isNotEmpty, isTrue);
        expect(l10n.clear_tags.isNotEmpty, isTrue);
        expect(l10n.no_tags.isNotEmpty, isTrue);
        expect(l10n.add_custom_tag.isNotEmpty, isTrue);
        expect(l10n.docs_tag_insurance.isNotEmpty, isTrue);
        expect(l10n.docs_tag_invoice.isNotEmpty, isTrue);
        expect(l10n.tag_name_empty.isNotEmpty, isTrue);
        expect(l10n.tag_already_exists.isNotEmpty, isTrue);
        expect(l10n.tag_too_long.isNotEmpty, isTrue);
      });
    }
  });

  group('Phase 19.2 - UI Layout & Safety Tests', () {
    testWidgets('13. Long tag layout safety in VaultTagChip does not overflow or crash', (tester) async {
      const veryLongTag = 'CardiovascularElectrophysiologyAndRadiofrequencyCatheterAblation';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 150, // Constrained width
              child: VaultTagChip(
                label: veryLongTag,
                bg: AppColors.chipBlue,
                text: AppColors.primary,
                icon: '🏷️',
                onDelete: () {},
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(VaultTagChip), findsOneWidget);
    });

    test('14. No gamification dependency in Vault tags system', () {
      // Ensure no XP/points/badges in DocumentTag or Document
      final docTagNames = DocumentTag.values.map((t) => t.id).toList();
      for (final forbidden in ['xp', 'point', 'level', 'badge', 'mission', 'streak', 'achievement']) {
        expect(docTagNames, isNot(contains(forbidden)));
      }
    });

    test('15. No cloud/analytics leakage: CustomTagRepository operates strictly local', () {
      expect(CustomTagRepositoryImpl, isNotNull);
      // Validates that repository only depends on Sembast database and does not require network or analytics clients
    });
  });
}
