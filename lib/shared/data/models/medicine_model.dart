import 'package:vitacase/features/medications/domain/entities/medicine.dart';
import 'package:vitacase/shared/domain/enums/common_enums.dart';

class MedicineModel {
  String id;
  String name;
  String dosage;
  String startDate;
  String? endDate;
  String frequency;
  String hungerStatus;
  int? totalStock;
  int? currentStock;
  List<String> reminderTimes;
  List<int>? daysOfWeek;
  int? interval;
  DateTime createdAt;
  bool isTaken;

  MedicineModel({
    required this.id,
    required this.name,
    required this.dosage,
    required this.startDate,
    this.endDate,
    required this.frequency,
    required this.hungerStatus,
    this.totalStock,
    this.currentStock,
    this.reminderTimes = const [],
    this.daysOfWeek,
    this.interval,
    required this.createdAt,
    this.isTaken = false,
  });

  factory MedicineModel.fromEntity(Medicine entity) {
    return MedicineModel(
      id: entity.id,
      name: entity.name,
      dosage: entity.dosage,
      startDate: entity.startDate,
      endDate: entity.endDate,
      frequency: entity.frequency,
      hungerStatus: entity.hungerStatus.name,
      totalStock: entity.totalStock,
      currentStock: entity.currentStock,
      reminderTimes: entity.reminderTimes,
      daysOfWeek: entity.daysOfWeek,
      interval: entity.interval,
      createdAt: entity.createdAt,
      isTaken: entity.isTaken,
    );
  }

  Medicine toEntity() {
    return Medicine(
      id: id,
      name: name,
      dosage: dosage,
      startDate: startDate,
      endDate: endDate,
      frequency: frequency,
      hungerStatus: HungerStatus.values.firstWhere(
        (e) => e.name == hungerStatus,
        orElse: () => HungerStatus.farketmez,
      ),
      totalStock: totalStock,
      currentStock: currentStock,
      reminderTimes: reminderTimes,
      daysOfWeek: daysOfWeek,
      interval: interval,
      createdAt: createdAt,
      isTaken: isTaken,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'startDate': startDate,
      'endDate': endDate,
      'frequency': frequency,
      'hungerStatus': hungerStatus,
      'totalStock': totalStock,
      'currentStock': currentStock,
      'reminderTimes': reminderTimes,
      'daysOfWeek': daysOfWeek,
      'interval': interval,
      'createdAt': createdAt.toIso8601String(),
      'isTaken': isTaken,
    };
  }

  factory MedicineModel.fromMap(Map<String, dynamic> map) {
    return MedicineModel(
      id: map['id'],
      name: map['name'],
      dosage: map['dosage'],
      startDate: map['startDate'],
      endDate: map['endDate'],
      frequency: map['frequency'],
      hungerStatus: map['hungerStatus'],
      totalStock: map['totalStock'],
      currentStock: map['currentStock'],
      reminderTimes: List<String>.from(map['reminderTimes'] ?? []),
      daysOfWeek:
          map['daysOfWeek'] != null ? List<int>.from(map['daysOfWeek']) : null,
      interval: map['interval'],
      createdAt: DateTime.parse(map['createdAt']),
      isTaken: map['isTaken'] ?? false,
    );
  }
}
