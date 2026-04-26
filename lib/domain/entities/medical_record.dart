enum MedicalCategory { critical, important, general }

class MedicalRecord {
  final String id;
  final String title;
  final String description;
  final MedicalCategory category;
  final String iconName; // Icon name from MaterialIcons
  final DateTime createdAt;

  MedicalRecord({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.iconName,
    required this.createdAt,
  });

  MedicalRecord copyWith({
    String? id,
    String? title,
    String? description,
    MedicalCategory? category,
    String? iconName,
    DateTime? createdAt,
  }) {
    return MedicalRecord(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      iconName: iconName ?? this.iconName,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
