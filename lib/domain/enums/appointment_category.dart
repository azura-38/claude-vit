/// Stable enum for appointment categories.
/// Store [key] in the database; localize only at the UI layer.
enum AppointmentCategory {
  doctor,
  meeting,
  reminder,
  other;

  /// Stable database/storage key (never translated).
  String get key => name;

  /// Parse from a stored key. Returns [other] for unknown values.
  static AppointmentCategory fromKey(String? key) {
    return AppointmentCategory.values.firstWhere(
      (e) => e.name == key,
      orElse: () => AppointmentCategory.other,
    );
  }
}
