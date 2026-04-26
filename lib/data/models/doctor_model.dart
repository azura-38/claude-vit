import '../../../domain/entities/doctor.dart';
import '../../../domain/enums/common_enums.dart';

class DoctorModel {
  String id;
  String title;
  String name;
  String department;
  String hospital;
  String? phone;
  String? email;
  String gender;
  String? notes;
  DateTime createdAt;
  bool isVerified;

  DoctorModel({
    required this.id,
    required this.title,
    required this.name,
    required this.department,
    required this.hospital,
    this.phone,
    this.email,
    required this.gender,
    this.notes,
    required this.createdAt,
    this.isVerified = false,
  });

  factory DoctorModel.fromEntity(Doctor entity) {
    return DoctorModel(
      id: entity.id,
      title: entity.title,
      name: entity.name,
      department: entity.department,
      hospital: entity.hospital,
      phone: entity.phone,
      email: entity.email,
      gender: entity.gender.name,
      notes: entity.notes,
      createdAt: entity.createdAt,
      isVerified: entity.isVerified,
    );
  }

  Doctor toEntity() {
    return Doctor(
      id: id,
      title: title,
      name: name,
      department: department,
      hospital: hospital,
      phone: phone,
      email: email,
      gender: Gender.values.firstWhere((e) => e.name == gender, orElse: () => Gender.male),
      notes: notes,
      createdAt: createdAt,
      isVerified: isVerified,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'name': name,
      'department': department,
      'hospital': hospital,
      'phone': phone,
      'email': email,
      'gender': gender,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'isVerified': isVerified,
    };
  }

  factory DoctorModel.fromMap(Map<String, dynamic> map) {
    return DoctorModel(
      id: map['id'],
      title: map['title'],
      name: map['name'],
      department: map['department'],
      hospital: map['hospital'],
      phone: map['phone'],
      email: map['email'],
      gender: map['gender'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
      isVerified: map['isVerified'] ?? false,
    );
  }
}
