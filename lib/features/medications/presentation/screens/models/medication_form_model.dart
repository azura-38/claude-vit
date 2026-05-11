enum MedicationFrequency { daily, weekly, custom }

class MedicationFormModel {
  final String medicineName;
  final MedicationFrequency frequency;
  final int quantity;
  final String unit;
  final List<String> reminderTimes;

  const MedicationFormModel({
    this.medicineName = '',
    this.frequency = MedicationFrequency.daily,
    this.quantity = 24,
    this.unit = 'tablet',
    this.reminderTimes = const ['08:00', '20:00'],
  });

  MedicationFormModel copyWith({
    String? medicineName,
    MedicationFrequency? frequency,
    int? quantity,
    String? unit,
    List<String>? reminderTimes,
  }) {
    return MedicationFormModel(
      medicineName: medicineName ?? this.medicineName,
      frequency: frequency ?? this.frequency,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      reminderTimes: reminderTimes ?? this.reminderTimes,
    );
  }
}
