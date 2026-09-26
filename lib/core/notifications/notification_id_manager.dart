import 'app_notification_payload.dart';

/// Manages deterministic, collision-free notification IDs across distinct namespaces.
///
/// Designed to support 32-bit signed integers for Android notification IDs
/// (0 to 2,147,483,647 / 0x7FFFFFFF) with strictly non-overlapping partitions.
class NotificationIdManager {
  // System namespace: 1 .. 99,999 (e.g. streaks, daily missions, storage limits, engagement)
  static const int systemMin = 1;
  static const int systemMax = 99999;

  // Medication namespace: 100,000,000 .. 899,999,999
  static const int medicationMin = 100000000;
  static const int medicationRange = 800000000;

  // Appointment namespace: 1,000,000,000 .. 1,699,999,999
  static const int appointmentMin = 1000000000;
  static const int appointmentRange = 700000000;

  // General / fallback namespace: 1,700,000,000 .. 2,147,483,647
  static const int generalMin = 1700000000;
  static const int generalRange = 447483647;

  /// Deterministic 32-bit FNV-1a hash of [input].
  static int hashString(String input) {
    int hash = 0x811c9dc5;
    for (int i = 0; i < input.length; i++) {
      hash ^= input.codeUnitAt(i);
      hash *= 0x01000193;
      hash &= 0xFFFFFFFF;
    }
    return hash.abs();
  }

  /// Builds a deterministic occurrence key from an entity [id] and [date].
  static String buildKey(String id, DateTime date) {
    return '${id}_${date.millisecondsSinceEpoch}';
  }

  /// Returns a deterministic notification ID within the non-colliding namespace for [type].
  static int getId({
    required String key,
    NotificationType type = NotificationType.unknown,
    int? explicitId,
  }) {
    if (explicitId != null) {
      return explicitId & 0x7FFFFFFF;
    }

    final hash = hashString(key);
    switch (type) {
      case NotificationType.engagement:
        return (hash % (systemMax - systemMin)) + systemMin;
      case NotificationType.medication:
      case NotificationType.refill:
        return medicationMin + (hash % medicationRange);
      case NotificationType.appointment:
        return appointmentMin + (hash % appointmentRange);
      case NotificationType.emergency:
      case NotificationType.unknown:
        return generalMin + (hash % generalRange);
    }
  }

  /// Returns a deterministic notification ID for a medicine reminder.
  static int getMedicineReminderId({
    required String medicineId,
    required String reminderTime,
    int? dayOfWeek,
    int? intervalIndex,
  }) {
    final buffer = StringBuffer('med_${medicineId}_$reminderTime');
    if (dayOfWeek != null) {
      buffer.write('_d$dayOfWeek');
    }
    if (intervalIndex != null) {
      buffer.write('_i$intervalIndex');
    }
    return getId(key: buffer.toString(), type: NotificationType.medication);
  }

  /// Returns all deterministic notification IDs for all reminders configured on a medicine.
  static List<int> getMedicineNotificationIds({
    required String medicineId,
    required List<String> reminderTimes,
    String? frequency,
    List<int>? daysOfWeek,
    int? interval,
  }) {
    final ids = <int>[];
    for (final time in reminderTimes) {
      final trimmedTime = time.trim();
      if (trimmedTime.isEmpty) continue;

      if (frequency == 'weekly' && daysOfWeek != null && daysOfWeek.isNotEmpty) {
        for (final day in daysOfWeek) {
          ids.add(getMedicineReminderId(
            medicineId: medicineId,
            reminderTime: trimmedTime,
            dayOfWeek: day,
          ));
        }
      } else if (frequency == 'custom' && interval != null) {
        for (int i = 0; i < 10; i++) {
          ids.add(getMedicineReminderId(
            medicineId: medicineId,
            reminderTime: trimmedTime,
            intervalIndex: i,
          ));
        }
      } else {
        ids.add(getMedicineReminderId(
          medicineId: medicineId,
          reminderTime: trimmedTime,
        ));
      }
    }
    return ids;
  }

  /// Returns a deterministic notification ID for an appointment reminder.
  static int getAppointmentReminderId({
    required String appointmentId,
    required String reminderKey,
  }) {
    final key = 'appt_${appointmentId}_$reminderKey';
    return getId(key: key, type: NotificationType.appointment);
  }

  /// Returns all deterministic notification IDs for all reminders configured on an appointment.
  static List<int> getAppointmentNotificationIds({
    required String appointmentId,
    required List<String> reminderKeys,
  }) {
    final ids = <int>[];
    for (final reminderKey in reminderKeys) {
      final trimmed = reminderKey.trim();
      if (trimmed.isEmpty || trimmed == 'none') continue;
      ids.add(getAppointmentReminderId(
        appointmentId: appointmentId,
        reminderKey: trimmed,
      ));
    }
    return ids;
  }

  /// Legacy stable ID calculation preserved for backwards compatibility.
  static int getStableIdLegacy(String uuid, [int offset = 0]) {
    int hash = 0x811c9dc5;
    for (int i = 0; i < uuid.length; i++) {
      hash ^= uuid.codeUnitAt(i);
      hash *= 0x01000193;
      hash &= 0xFFFFFFFF;
    }
    return ((hash.abs() ^ (offset * 0x01000193)) & 0x7FFFFFFF);
  }

  /// Checks whether [id] falls within the medication notification namespace.
  static bool isMedicineId(int id) {
    return id >= medicationMin && id < (medicationMin + medicationRange);
  }

  /// Checks whether [id] falls within the appointment notification namespace.
  static bool isAppointmentId(int id) {
    return id >= appointmentMin && id < (appointmentMin + appointmentRange);
  }
}
