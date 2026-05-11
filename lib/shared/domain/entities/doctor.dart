import 'package:flutter/material.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';
import '../enums/common_enums.dart';

/// Pure domain entity for a doctor record.
class Doctor {
  final String id;
  final String title;
  final String name;
  final String department;
  final String hospital;
  final String? phone;
  final String? email;
  final Gender gender;
  final String? subSpecialty;
  final String? notes;
  final bool isVerified;
  final DateTime createdAt;

  const Doctor({
    required this.id,
    required this.title,
    required this.name,
    required this.department,
    required this.hospital,
    this.phone,
    this.email,
    required this.gender,
    this.subSpecialty,
    this.notes,
    this.isVerified = false,
    required this.createdAt,
  });

  String localizedTitle(BuildContext context) {
    if (title.startsWith('doctor_title_')) {
      return context.l10n(title);
    }
    return title;
  }

  Doctor copyWith({
    String? id,
    String? title,
    String? name,
    String? department,
    String? hospital,
    String? phone,
    String? email,
    Gender? gender,
    String? subSpecialty,
    String? notes,
    bool? isVerified,
    DateTime? createdAt,
  }) {
    return Doctor(
      id: id ?? this.id,
      title: title ?? this.title,
      name: name ?? this.name,
      department: department ?? this.department,
      hospital: hospital ?? this.hospital,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      subSpecialty: subSpecialty ?? this.subSpecialty,
      notes: notes ?? this.notes,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
