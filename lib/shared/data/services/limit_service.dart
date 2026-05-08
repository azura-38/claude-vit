class LimitService {
  // Base limits as per model request
  static const int documentLimit = 25;
  static const int medicineLimit = 15;
  static const int appointmentLimit = 10;

  static bool canAdd({
    required int current,
    required int baseLimit,
    required int extra,
    required bool isPremium,
  }) {
    if (isPremium) return true;

    return current < (baseLimit + extra);
  }
}
