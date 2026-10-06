import '../enums/document_category.dart';

/// Pure domain entity for a locally-stored document.
class Document {
  final String id;
  final String fileName;
  final DocumentFileType fileType;
  final String localPath;
  final String? hospitalName;
  final String? doctorName;
  final String? documentDate;
  final String? tagId;
  final String? tagLabel;
  final String? note;
  final DocumentCategory category;
  final DateTime createdAt;
  final bool pending;

  final List<String> tags;

  const Document({
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
    this.tags = const [],
  });

  Document copyWith({
    String? id,
    String? fileName,
    DocumentFileType? fileType,
    String? localPath,
    DocumentCategory? category,
    String? hospitalName,
    String? doctorName,
    String? documentDate,
    String? tagId,
    String? tagLabel,
    String? note,
    DateTime? createdAt,
    bool? pending,
    List<String>? tags,
  }) {
    return Document(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      fileType: fileType ?? this.fileType,
      localPath: localPath ?? this.localPath,
      category: category ?? this.category,
      hospitalName: hospitalName ?? this.hospitalName,
      doctorName: doctorName ?? this.doctorName,
      documentDate: documentDate ?? this.documentDate,
      tagId: tagId ?? this.tagId,
      tagLabel: tagLabel ?? this.tagLabel,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      pending: pending ?? this.pending,
      tags: tags ?? this.tags,
    );
  }
}
