/// Named route constants for the app following a hierarchical pathing strategy.
class AppRoutes {
  AppRoutes._();

  // Root flows
  static const String home = '/';
  static const String onboarding = '/onboarding';
  static const String profileCreate = '/profile-create';
  static const String lock = '/lock';
  static const String legalUpdate = '/legal-update';

  // Main features (Navigation Branches)
  static const String dashboard = '/dashboard';
  static const String documents = '/documents';
  static const String appointments = '/appointments';
  static const String doctors = '/doctors';
  static const String medicines = '/medicines';

  // Details
  static const String documentDetail = '/documents/:id';
  static const String doctorDetail = '/doctors/:id';

  // Adding/Editing
  static const String documentAdd = '/documents/add';
  static const String documentQuickView = '/documents/view';
  static const String appointmentAdd = '/appointments/add';
  static const String medicineAdd = '/medicines/add';
  static const String doctorAdd = '/doctors/add';
  static const String healthDataAdd = '/health/add';

  // Sub-pages (Profile/Settings)
  static const String profile = '/profile';
  static const String profileEdit = '/profile/edit';
  static const String personalInfo = '/profile/personal-info';
  static const String medicalInfo = '/profile/medical';
  static const String healthStats = '/profile/health-stats';

  static const String settings = '/settings';
  static const String settingsTheme = '/settings/theme';
  static const String settingsTermsAndPrivacy = '/settings/terms-and-privacy';
  static const String settingsTerms = '/settings/terms';
  static const String settingsPrivacy = '/settings/privacy';
  static const String settingsDisclaimer = '/settings/disclaimer';
  static const String settingsKvkk = '/settings/kvkk';
  static const String settingsDataDeletion = '/settings/data-deletion';
  static const String reminderTroubleshooting = '/settings/reminder-help';
  static const String diagnosticsPanel = '/settings/diagnostics';
}
