enum AppointmentType {
  medical('Medical', 'General'),
  finance('Finance', 'Finance'),
  legal('Legal', 'Legal'),
  insurance('Insurance', 'Insurance'),
  meeting('Meeting', 'Meeting'),
  personal('Personal', 'Personal'),
  travel('Travel', 'Travel'),
  reminder('Reminder', 'Reminder'),
  other('Other', 'Other');

  const AppointmentType(this.label, this.department);

  final String label;
  final String department;
}

enum AppointmentReminder {
  tenMinutes('reminder_10m', '10 minutes before', Duration(minutes: 10)),
  oneHour('reminder_1h', '1 hour before', Duration(hours: 1)),
  oneDay('reminder_1d', '1 day before', Duration(days: 1)),
  sevenDays('reminder_7d', '7 days before', Duration(days: 7));

  const AppointmentReminder(this.key, this.label, this.offset);

  final String key;
  final String label;
  final Duration offset;
}

enum AppointmentPriority { low, normal, high }

class AppointmentFormModel {
  final String title;
  final AppointmentType type;
  final AppointmentPriority priority;
  final DateTime date;
  final String location;
  final AppointmentReminder reminder;
  final String notes;
  final bool isSubmitting;

  const AppointmentFormModel({
    this.title = '',
    this.type = AppointmentType.medical,
    this.priority = AppointmentPriority.normal,
    required this.date,
    this.location = '',
    this.reminder = AppointmentReminder.oneHour,
    this.notes = '',
    this.isSubmitting = false,
  });

  bool get isValid => title.trim().isNotEmpty && location.trim().isNotEmpty;

  AppointmentFormModel copyWith({
    String? title,
    AppointmentType? type,
    AppointmentPriority? priority,
    DateTime? date,
    String? location,
    AppointmentReminder? reminder,
    String? notes,
    bool? isSubmitting,
  }) {
    return AppointmentFormModel(
      title: title ?? this.title,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      date: date ?? this.date,
      location: location ?? this.location,
      reminder: reminder ?? this.reminder,
      notes: notes ?? this.notes,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}
