import '../../../domain/entities/medical_record.dart';

class MedicalRecordModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String iconName;
  final DateTime createdAt;

  MedicalRecordModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.iconName,
    required this.createdAt,
  });

  factory MedicalRecordModel.fromEntity(MedicalRecord entity) {
    return MedicalRecordModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      category: entity.category.name,
      iconName: entity.iconName,
      createdAt: entity.createdAt,
    );
  }

  MedicalRecord toEntity() {
    return MedicalRecord(
      id: id,
      title: title,
      description: description,
      category: MedicalCategory.values.firstWhere((e) => e.name == category),
      iconName: iconName,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'iconName': iconName,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MedicalRecordModel.fromMap(Map<String, dynamic> map) {
    return MedicalRecordModel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      category: map['category'],
      iconName: map['iconName'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
