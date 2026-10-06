import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/user_profile.dart';
import '../../../../shared/providers/user_preferences_controller.dart';

final profileProvider = NotifierProvider<ProfileNotifier, UserProfile>(() {
  return ProfileNotifier();
});

class ProfileNotifier extends Notifier<UserProfile> {
  @override
  UserProfile build() {
    final prefs = ref.watch(userPreferencesControllerProvider);
    return prefs.maybeWhen(
      data: (p) => p.profile,
      orElse: () => const UserProfile(),
    );
  }

  Future<void> saveToDatabase() async {
    final userPrefs = ref.read(userPreferencesControllerProvider.notifier);
    await userPrefs.updateProfile(state);
  }

  void updateName(String value) {
    state = state.copyWith(fullName: value);
  }

  void updateEmail(String value) {
    state = state.copyWith(email: value);
  }

  void updatePhone(String value) {
    state = state.copyWith(phone: value);
  }

  void updatePhotoPath(String? value) {
    state = state.copyWith(photoPath: value);
  }

  void updateHeight(double value) {
    state = state.copyWith(height: value);
  }

  void updateWeight(double value) {
    state = state.copyWith(weight: value);
  }

  void updateBlood(String value) {
    state = state.copyWith(bloodType: value);
  }

  void updateGender(Gender gender) {
    state = state.copyWith(gender: gender);
  }

  void updateEmergencyName(String value) {
    state = state.copyWith(emergencyName: value);
  }

  void updateEmergencyPhone(String value) {
    state = state.copyWith(emergencyPhone: value);
  }

  void updateEmergencyRelation(String value) {
    state = state.copyWith(emergencyRelation: value);
  }

  void updateBirthDate(DateTime value) {
    state = state.copyWith(birthDate: value);
  }

  void updateAllergies(List<String> values) {
    state = state.copyWith(allergies: _cleanList(values));
  }

  void updateMedications(List<String> values) {
    state = state.copyWith(medications: _cleanList(values));
  }

  List<String> _cleanList(List<String> values) {
    final seen = <String>{};
    final result = <String>[];
    for (final value in values) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) continue;
      final key = trimmed.toLowerCase();
      if (seen.add(key)) result.add(trimmed);
    }
    return result;
  }

  void toggleCondition(String value) {
    final list = [...state.conditions];

    if (list.contains(value)) {
      list.remove(value);
    } else {
      list.add(value);
    }

    state = state.copyWith(conditions: list);
  }

  void togglePrivacy(bool value) {
    state = state.copyWith(privacyMode: value);
  }

  void toggleBiometric(bool value) {
    state = state.copyWith(biometricLock: value);
  }

  void toggleSilent(bool value) {
    state = state.copyWith(silentNotifications: value);
  }
}
