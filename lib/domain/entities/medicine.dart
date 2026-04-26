import '../enums/common_enums.dart';

/// Pure domain entity for a medicine record.
class Medicine {
  final String id;
  final String name;
  final String dosage;
  final String startDate;
  final String frequency;
  final HungerStatus hungerStatus;
  final int? totalStock;
  final int? currentStock;
  final List<String> reminderTimes;
  final List<int>? daysOfWeek;
  final int? interval;
  final DateTime createdAt;
  final bool isTaken;

  const Medicine({
    required this.id,
    required this.name,
    required this.dosage,
    required this.startDate,
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

  DateTime get nextReminderTime {
    if (reminderTimes.isEmpty) return DateTime.now().add(const Duration(days: 365));
    
    final now = DateTime.now();
    DateTime? soonest;

    for (final timeStr in reminderTimes) {
      final parts = timeStr.split(':');
      if (parts.length != 2) continue;
      
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      
      var scheduled = DateTime(now.year, now.month, now.day, hour, minute);
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
      
      if (soonest == null || scheduled.isBefore(soonest)) {
        soonest = scheduled;
      }
    }
    
    return soonest ?? now.add(const Duration(days: 1));
  }

  Medicine copyWith({
    String? id,
    String? name,
    String? dosage,
    String? startDate,
    String? frequency,
    HungerStatus? hungerStatus,
    int? totalStock,
    int? currentStock,
    List<String>? reminderTimes,
    List<int>? daysOfWeek,
    int? interval,
    DateTime? createdAt,
    bool? isTaken,
  }) {
    return Medicine(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      startDate: startDate ?? this.startDate,
      frequency: frequency ?? this.frequency,
      hungerStatus: hungerStatus ?? this.hungerStatus,
      totalStock: totalStock ?? this.totalStock,
      currentStock: currentStock ?? this.currentStock,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      interval: interval ?? this.interval,
      createdAt: createdAt ?? this.createdAt,
      isTaken: isTaken ?? this.isTaken,
    );
  }
}
