import 'package:vitacase/shared/domain/entities/document.dart';
import 'package:vitacase/shared/domain/enums/document_category.dart';

class DocumentModel {
  String id;
  String fileName;
  String fileType;
  String localPath;
  String category;
  String? hospitalName;
  String? doctorName;
  String? documentDate;
  String? tagId;
  String? tagLabel;
  String? note;
  DateTime createdAt;
  bool pending;

  DocumentModel({
    required this.id,
    required this.fileName,
    required this.fileType,
    required this.localPath,
    required this.category,
    this.hospitalName,
    this.doctorName,
    this.documentDate,
    this.tagId,
    this.tagLabel,
    this.note,
    required this.createdAt,
    this.pending = false,
  });

  factory DocumentModel.fromEntity(Document entity) {
    return DocumentModel(
      id: entity.id,
      fileName: entity.fileName,
      fileType: entity.fileType.name,
      localPath: entity.localPath,
      category: entity.category.name,
      hospitalName: entity.hospitalName,
      doctorName: entity.doctorName,
      documentDate: entity.documentDate,
      tagId: entity.tagId,
      tagLabel: entity.tagLabel,
      note: entity.note,
      createdAt: entity.createdAt,
      pending: entity.pending,
    );
  }

  Document toEntity() {
    return Document(
      id: id,
      fileName: fileName,
      fileType: DocumentFileType.values.firstWhere(
        (e) => e.name == fileType,
        orElse: () => DocumentFileType.image,
      ),
      localPath: localPath,
      category: DocumentCategory.values.firstWhere(
        (e) => e.name == category,
        orElse: () => DocumentCategory.other,
      ),
      hospitalName: hospitalName,
      doctorName: doctorName,
      documentDate: documentDate,
      tagId: tagId,
      tagLabel: tagLabel,
      note: note,
      createdAt: createdAt,
      pending: pending,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fileName': fileName,
      'fileType': fileType,
      'localPath': localPath,
      'category': category,
      'hospitalName': hospitalName,
      'doctorName': doctorName,
      'documentDate': documentDate,
      'tagId': tagId,
      'tagLabel': tagLabel,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
      'pending': pending,
    };
  }

  factory DocumentModel.fromMap(Map<String, dynamic> map) {
    return DocumentModel(
      id: map['id'],
      fileName: map['fileName'],
      fileType: map['fileType'],
      localPath: map['localPath'],
      category: map['category'] ?? DocumentCategory.other.name,
      hospitalName: map['hospitalName'],
      doctorName: map['doctorName'],
      documentDate: map['documentDate'],
      tagId: map['tagId'],
      tagLabel: map['tagLabel'],
      note: map['note'],
      createdAt: DateTime.parse(map['createdAt']),
      pending: map['pending'] ?? false,
    );
  }
}
