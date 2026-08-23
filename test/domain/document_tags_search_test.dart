import 'package:flutter_test/flutter_test.dart';
import 'package:vitacase/shared/data/models/document_model.dart';
import 'package:vitacase/shared/domain/entities/document.dart';
import 'package:vitacase/shared/domain/enums/document_category.dart';

void main() {
  group('Document & Tag Migration Tests', () {
    test('Legacy V1 document map without tags/category parses safely to defaults', () {
      final legacyMap = {
        'id': 'doc_101',
        'fileName': 'ECG_Report.pdf',
        'fileType': 'pdf',
        'localPath': '/storage/doc_101.pdf',
        'createdAt': '2026-08-23T10:00:00.000Z',
      };

      final model = DocumentModel.fromMap(legacyMap);
      final entity = model.toEntity();

      expect(entity.id, 'doc_101');
      expect(entity.category, DocumentCategory.other);
      expect(entity.tags, isEmpty);
    });

    test('Legacy document with tagLabel migrates into tags list', () {
      final legacyMap = {
        'id': 'doc_102',
        'fileName': 'Blood_Work.pdf',
        'fileType': 'pdf',
        'localPath': '/storage/doc_102.pdf',
        'tagLabel': 'Lab',
        'createdAt': '2026-08-23T10:00:00.000Z',
      };

      final model = DocumentModel.fromMap(legacyMap);
      final entity = model.toEntity();

      expect(entity.tags, contains('Lab'));
    });

    test('DocumentModel converts entity with tags and custom category toMap and back', () {
      final doc = Document(
        id: 'doc_201',
        fileName: 'Cardio_Test_2025.pdf',
        fileType: DocumentFileType.pdf,
        localPath: '/storage/doc_201.pdf',
        category: DocumentCategory.medicalReport,
        tags: const ['Cardiologist 2025', 'Important'],
        createdAt: DateTime.now(),
      );

      final model = DocumentModel.fromEntity(doc);
      final map = model.toMap();
      final roundtrip = DocumentModel.fromMap(map).toEntity();

      expect(roundtrip.id, 'doc_201');
      expect(roundtrip.category, DocumentCategory.medicalReport);
      expect(roundtrip.tags, containsAll(['Cardiologist 2025', 'Important']));
    });

    test('Case-insensitive tag and search matching logic', () {
      final doc = Document(
        id: 'doc_301',
        fileName: 'Heart_Scan.pdf',
        fileType: DocumentFileType.pdf,
        localPath: '/storage/doc_301.pdf',
        category: DocumentCategory.medicalReport,
        tags: const ['Cardiologist 2025', 'Annual Physical'],
        createdAt: DateTime.now(),
      );

      final query = 'cardiologist';
      final tagsStr = doc.tags.join(' ');
      final haystack = '${doc.fileName} ${doc.category.name} $tagsStr'.toLowerCase();

      expect(haystack.contains(query.toLowerCase()), isTrue);
    });
  });
}
