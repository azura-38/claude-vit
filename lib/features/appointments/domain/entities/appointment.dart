import '../../../../shared/domain/enums/appointment_status.dart';
import '../../../../shared/domain/enums/common_enums.dart';

/// Pure domain entity for an appointment.
class Appointment {
  final String id;
  final String doctor;
  final String department;
  final String hospital;
  final String date; // YYYY-MM-DD
  final String time; // HH:mm
  final AppointmentStatus status;
  final String? type;
  final String? location;
  final String? meetingLink;
  final String? notes;
  final List<String> selectedReminders;
  final List<int> notificationIds;
  final String? title;
  final String? person;
  final String? repeat;
  final String? reminderTime;
  final ImportanceLevel importance;
  final DateTime createdAt;

  const Appointment({
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
    this.importance = ImportanceLevel.medium,
    required this.createdAt,
  });

  DateTime get fullDateTime {
    try {
      return DateTime.parse('$date $time');
    } catch (e) {
      return DateTime.now().add(const Duration(days: 365));
    }
  }

  Appointment copyWith({
    String? id,
    String? title,
    String? doctor,
    String? department,
    String? hospital,
    String? person,
    String? date,
    String? time,
    AppointmentStatus? status,
    String? type,
    String? location,
    String? meetingLink,
    String? notes,
    String? repeat,
    String? reminderTime,
    List<String>? selectedReminders,
    List<int>? notificationIds,
    ImportanceLevel? importance,
    DateTime? createdAt,
  }) {
    return Appointment(
      id: id ?? this.id,
      title: title ?? this.title,
      doctor: doctor ?? this.doctor,
      department: department ?? this.department,
      hospital: hospital ?? this.hospital,
      person: person ?? this.person,
      date: date ?? this.date,
      time: time ?? this.time,
      status: status ?? this.status,
      type: type ?? this.type,
      location: location ?? this.location,
      meetingLink: meetingLink ?? this.meetingLink,
      notes: notes ?? this.notes,
      repeat: repeat ?? this.repeat,
      reminderTime: reminderTime ?? this.reminderTime,
      selectedReminders: selectedReminders ?? this.selectedReminders,
      notificationIds: notificationIds ?? this.notificationIds,
      importance: importance ?? this.importance,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
