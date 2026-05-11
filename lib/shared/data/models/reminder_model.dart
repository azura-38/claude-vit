import 'package:vitacase/shared/domain/entities/reminder.dart';
import 'package:vitacase/shared/domain/enums/reminder_type.dart';

class ReminderModel {
  String id;
  String title;
  String type;
  DateTime remindAt;
  bool sent;
  DateTime createdAt;

  ReminderModel({
    required this.id,
    required this.title,
    required this.type,
    required this.remindAt,
    required this.sent,
    required this.createdAt,
  });

  factory ReminderModel.fromEntity(Reminder entity) {
    return ReminderModel(
      id: entity.id,
      title: entity.title,
      type: entity.type.name,
      remindAt: entity.remindAt,
      sent: entity.sent,
      createdAt: entity.createdAt,
    );
  }

  Reminder toEntity() {
    return Reminder(
      id: id,
      title: title,
      type: ReminderType.values.firstWhere(
        (e) => e.name == type,
        orElse: () => ReminderType.medicine,
      ),
      remindAt: remindAt,
      sent: sent,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'remindAt': remindAt.toIso8601String(),
      'sent': sent,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    return ReminderModel(
      id: map['id'],
      title: map['title'],
      type: map['type'],
      remindAt: DateTime.parse(map['remindAt']),
      sent: map['sent'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
