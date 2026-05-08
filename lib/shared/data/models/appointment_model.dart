import 'package:vitacase/features/appointments/domain/entities/appointment.dart';
import 'package:vitacase/shared/domain/enums/appointment_status.dart';
import 'package:vitacase/shared/domain/enums/common_enums.dart';

class AppointmentModel {
  String id;
  String doctor;
  String department;
  String hospital;
  String date;
  String time;
  String status;
  String? type;
  String? location;
  String? meetingLink;
  String? notes;
  List<String> selectedReminders;
  List<int> notificationIds;
  String? title;
  String? person;
  String? repeat;
  String? reminderTime;
  String importance;
  DateTime createdAt;

  AppointmentModel({
    required this.id,
    this.title,
    required this.doctor,
    required this.department,
    required this.hospital,
    this.person,
    required this.date,
    required this.time,
    required this.status,
    this.type,
    this.location,
    this.meetingLink,
    this.notes,
    this.repeat,
    this.reminderTime,
    this.selectedReminders = const [],
    this.notificationIds = const [],
    required this.importance,
    required this.createdAt,
  });

  factory AppointmentModel.fromEntity(Appointment entity) {
    return AppointmentModel(
      id: entity.id,
      title: entity.title,
      doctor: entity.doctor,
      department: entity.department,
      hospital: entity.hospital,
      person: entity.person,
      date: entity.date,
      time: entity.time,
      status: entity.status.name,
      type: entity.type,
      location: entity.location,
      meetingLink: entity.meetingLink,
      notes: entity.notes,
      repeat: entity.repeat,
      reminderTime: entity.reminderTime,
      selectedReminders: entity.selectedReminders,
      notificationIds: entity.notificationIds,
      importance: entity.importance.name,
      createdAt: entity.createdAt,
    );
  }

  Appointment toEntity() {
    return Appointment(
      id: id,
      title: title,
      doctor: doctor,
      department: department,
      hospital: hospital,
      person: person,
      date: date,
      time: time,
      status: AppointmentStatus.values.firstWhere((e) => e.name == status, orElse: () => AppointmentStatus.upcoming),
      type: type,
      location: location,
      meetingLink: meetingLink,
      notes: notes,
      repeat: repeat,
      reminderTime: reminderTime,
      selectedReminders: selectedReminders,
      notificationIds: notificationIds,
      importance: ImportanceLevel.values.firstWhere((e) => e.name == importance, orElse: () => ImportanceLevel.medium),
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'doctor': doctor,
      'department': department,
      'hospital': hospital,
      'person': person,
      'date': date,
      'time': time,
      'status': status,
      'type': type,
      'location': location,
      'meetingLink': meetingLink,
      'notes': notes,
      'repeat': repeat,
      'reminderTime': reminderTime,
      'selectedReminders': selectedReminders,
      'notificationIds': notificationIds,
      'importance': importance,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AppointmentModel.fromMap(Map<String, dynamic> map) {
    return AppointmentModel(
      id: map['id'],
      title: map['title'],
      doctor: map['doctor'],
      department: map['department'],
      hospital: map['hospital'],
      person: map['person'],
      date: map['date'],
      time: map['time'],
      status: map['status'],
      type: map['type'],
      location: map['location'],
      meetingLink: map['meetingLink'],
      notes: map['notes'],
      repeat: map['repeat'],
      reminderTime: map['reminderTime'],
      selectedReminders: List<String>.from(map['selectedReminders'] ?? []),
      notificationIds: List<int>.from(map['notificationIds'] ?? []),
      importance: map['importance'] ?? ImportanceLevel.medium.name,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
