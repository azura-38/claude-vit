enum MedicationFrequency { daily, weekly, custom }

class MedicationFormModel {
  final String medicineName;
  final MedicationFrequency frequency;
  final int quantity;
  final String unit;
  final List<String> reminderTimes;
  final List<int> daysOfWeek; // 1=Pzt … 7=Paz (weekly için)
  final int interval; // gün aralığı (custom için)
  final int totalStock; // kaç adet stok

  const MedicationFormModel({
    this.medicineName = '',
    this.frequency = MedicationFrequency.daily,
    this.quantity = 24,
    this.unit = 'tablet',
    this.reminderTimes = const ['08:00', '20:00'],
    this.daysOfWeek = const [],
    this.interval = 2,
    this.totalStock = 30,
  });

  MedicationFormModel copyWith({
    String? medicineName,
    MedicationFrequency? frequency,
    int? quantity,
    String? unit,
    List<String>? reminderTimes,
    List<int>? daysOfWeek,
    int? interval,
    int? totalStock,
  }) {
    return MedicationFormModel(
      medicineName: medicineName ?? this.medicineName,
      frequency: frequency ?? this.frequency,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      interval: interval ?? this.interval,
      totalStock: totalStock ?? this.totalStock,
    );
  }
}
