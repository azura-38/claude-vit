enum AppointmentType { doctor, test, personal, meeting }

enum AppointmentPriority { low, normal, high }

class AppointmentFormModel {
  final String title;
  final AppointmentType type;
  final AppointmentPriority priority;
  final DateTime date;
  final String location;
  final String reminder;
  final String notes;

  const AppointmentFormModel({
    this.title = '',
    this.type = AppointmentType.doctor,
    this.priority = AppointmentPriority.normal,
    required this.date,
    this.location = '',
    this.reminder = '1 hour before',
    this.notes = '',
  });

  AppointmentFormModel copyWith({
    String? title,
    AppointmentType? type,
    AppointmentPriority? priority,
    DateTime? date,
    String? location,
    String? reminder,
    String? notes,
  }) {
    return AppointmentFormModel(
      title: title ?? this.title,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      date: date ?? this.date,
      location: location ?? this.location,
      reminder: reminder ?? this.reminder,
      notes: notes ?? this.notes,
    );
  }
}
