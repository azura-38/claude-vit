import '../enums/reminder_type.dart';

/// Pure domain entity for a reminder.
class Reminder {
  final String id;
  final String title;
  final ReminderType type;
  final DateTime remindAt;
  final bool sent;
  final DateTime createdAt;

  const Reminder({
    required this.id,
    required this.title,
    required this.type,
    required this.remindAt,
    this.sent = false,
    required this.createdAt,
  });
}
