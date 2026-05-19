import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/user_profile.dart';
import '../../../../features/gamification/presentation/providers/achievement_providers.dart';
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
    await ref.read(userPreferencesControllerProvider.notifier).updateProfile(state);
    await _trackProfileAchievements(state);
  }

  Future<void> _trackProfileAchievements(UserProfile profile) async {
    final achievement = ref.read(achievementProvider.notifier);

    final hasName = profile.fullName.trim().isNotEmpty;
    final hasBirthDate = profile.birthDate != null;
    final hasPhoto = profile.photoPath?.trim().startsWith('data:image/') == true;
    final hasBlood = profile.bloodType.trim().isNotEmpty;
    final hasAllergies = profile.allergies.isNotEmpty;
    final hasMedications = profile.medications.isNotEmpty;
    final hasEmergencyName = profile.emergencyName.trim().isNotEmpty;
    final hasEmergencyPhone = profile.emergencyPhone.trim().isNotEmpty;
    final hasEmergencyRelation = profile.emergencyRelation.trim().isNotEmpty;
    final hasEmergencyAny = hasEmergencyName || hasEmergencyPhone || hasEmergencyRelation;
    final hasEmergencyCore = hasEmergencyName && hasEmergencyPhone;
    final hasEmergencyFull = hasEmergencyCore && hasEmergencyRelation;
    final hasMedicalContext = hasBlood || hasAllergies || hasMedications;

    if (hasName) await achievement.track('profile_created', setAbsolute: 1);
    if (hasName && hasBirthDate) await achievement.track('profile_completed', setAbsolute: 1);
    if (hasName) await achievement.track('profile_updated', setAbsolute: 1);
    if (hasPhoto) await achievement.track('profile_with_photo', setAbsolute: 1);
    if (hasName && hasBirthDate && hasPhoto && hasEmergencyFull) {
      await achievement.track('profile_master', setAbsolute: 1);
    }

    if (hasEmergencyAny) await achievement.track('emergency_added', setAbsolute: 1);
    if (hasEmergencyCore) await achievement.track('emergency_contact', setAbsolute: 1);
    if (hasEmergencyCore) await achievement.track('emergency_complete', setAbsolute: 1);
    if (hasEmergencyFull) await achievement.track('emergency_ready', setAbsolute: 1);
    if (hasEmergencyFull && hasMedicalContext) await achievement.track('emergency_master', setAbsolute: 1);
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
