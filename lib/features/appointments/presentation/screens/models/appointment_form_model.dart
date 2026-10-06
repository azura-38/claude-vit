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

enum AppointmentSubcategory {
  general,
  doctorVisit,
  labTest,
  dental,
  therapy,
  payment,
  banking,
  tax,
  contract,
  consultation,
  policy,
  claim,
  workMeeting,
  family,
  travelPlan,
  task,
  other;

  String get label {
    switch (this) {
      case AppointmentSubcategory.general:
        return 'General';
      case AppointmentSubcategory.doctorVisit:
        return 'Doctor Visit';
      case AppointmentSubcategory.labTest:
        return 'Lab Test';
      case AppointmentSubcategory.dental:
        return 'Dental';
      case AppointmentSubcategory.therapy:
        return 'Therapy';
      case AppointmentSubcategory.payment:
        return 'Payment';
      case AppointmentSubcategory.banking:
        return 'Banking';
      case AppointmentSubcategory.tax:
        return 'Tax';
      case AppointmentSubcategory.contract:
        return 'Contract';
      case AppointmentSubcategory.consultation:
        return 'Consultation';
      case AppointmentSubcategory.policy:
        return 'Policy';
      case AppointmentSubcategory.claim:
        return 'Claim';
      case AppointmentSubcategory.workMeeting:
        return 'Work Meeting';
      case AppointmentSubcategory.family:
        return 'Family';
      case AppointmentSubcategory.travelPlan:
        return 'Travel Plan';
      case AppointmentSubcategory.task:
        return 'Task';
      case AppointmentSubcategory.other:
        return 'Other';
    }
  }
}

List<AppointmentSubcategory> subcategoriesForAppointmentType(
  AppointmentType type,
) {
  switch (type) {
    case AppointmentType.medical:
      return const [
        AppointmentSubcategory.doctorVisit,
        AppointmentSubcategory.labTest,
        AppointmentSubcategory.dental,
        AppointmentSubcategory.therapy,
        AppointmentSubcategory.other,
      ];
    case AppointmentType.finance:
      return const [
        AppointmentSubcategory.payment,
        AppointmentSubcategory.banking,
        AppointmentSubcategory.tax,
        AppointmentSubcategory.other,
      ];
    case AppointmentType.legal:
      return const [
        AppointmentSubcategory.contract,
        AppointmentSubcategory.consultation,
        AppointmentSubcategory.other,
      ];
    case AppointmentType.insurance:
      return const [
        AppointmentSubcategory.policy,
        AppointmentSubcategory.claim,
        AppointmentSubcategory.consultation,
        AppointmentSubcategory.other,
      ];
    case AppointmentType.meeting:
      return const [
        AppointmentSubcategory.workMeeting,
        AppointmentSubcategory.consultation,
        AppointmentSubcategory.other,
      ];
    case AppointmentType.personal:
      return const [
        AppointmentSubcategory.family,
        AppointmentSubcategory.general,
        AppointmentSubcategory.other,
      ];
    case AppointmentType.travel:
      return const [
        AppointmentSubcategory.travelPlan,
        AppointmentSubcategory.general,
        AppointmentSubcategory.other,
      ];
    case AppointmentType.reminder:
      return const [
        AppointmentSubcategory.task,
        AppointmentSubcategory.general,
        AppointmentSubcategory.other,
      ];
    case AppointmentType.other:
      return const [AppointmentSubcategory.other];
  }
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
  final String? editingId;
  final String title;
  final AppointmentType type;
  final AppointmentSubcategory subcategory;
  final AppointmentPriority priority;
  final DateTime date;
  final String location;
  final AppointmentReminder reminder;
  final String notes;
  final bool isSubmitting;

  const AppointmentFormModel({
    this.editingId,
    this.title = '',
    this.type = AppointmentType.medical,
    this.subcategory = AppointmentSubcategory.doctorVisit,
    this.priority = AppointmentPriority.normal,
    required this.date,
    this.location = '',
    this.reminder = AppointmentReminder.oneHour,
    this.notes = '',
    this.isSubmitting = false,
  });

  bool get isEditing => editingId != null;

  bool get isValid => title.trim().isNotEmpty && location.trim().isNotEmpty;

  AppointmentFormModel copyWith({
    String? editingId,
    bool clearEditingId = false,
    String? title,
    AppointmentType? type,
    AppointmentSubcategory? subcategory,
    AppointmentPriority? priority,
    DateTime? date,
    String? location,
    AppointmentReminder? reminder,
    String? notes,
    bool? isSubmitting,
  }) {
    return AppointmentFormModel(
      editingId: clearEditingId ? null : (editingId ?? this.editingId),
      title: title ?? this.title,
      type: type ?? this.type,
      subcategory: subcategory ?? this.subcategory,
      priority: priority ?? this.priority,
      date: date ?? this.date,
      location: location ?? this.location,
      reminder: reminder ?? this.reminder,
      notes: notes ?? this.notes,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}
