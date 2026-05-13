import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/user_profile.dart';
import 'profile_provider.dart';

final profileControllerProvider = NotifierProvider<ProfileController, UserProfile>(
  ProfileController.new,
);

class ProfileController extends Notifier<UserProfile> {
  @override
  UserProfile build() {
    return ref.watch(profileProvider);
  }

  // --- Actions ---
  void updateName(String value) => ref.read(profileProvider.notifier).updateName(value);
  void updateEmail(String value) => ref.read(profileProvider.notifier).updateEmail(value);
  void updatePhone(String value) => ref.read(profileProvider.notifier).updatePhone(value);
  void updatePhotoPath(String? value) => ref.read(profileProvider.notifier).updatePhotoPath(value);
  void updateHeight(double value) => ref.read(profileProvider.notifier).updateHeight(value);
  void updateWeight(double value) => ref.read(profileProvider.notifier).updateWeight(value);
  void updateBlood(String value) => ref.read(profileProvider.notifier).updateBlood(value);
  void updateGender(Gender gender) => ref.read(profileProvider.notifier).updateGender(gender);
  void updateEmergencyName(String value) => ref.read(profileProvider.notifier).updateEmergencyName(value);
  void updateEmergencyPhone(String value) => ref.read(profileProvider.notifier).updateEmergencyPhone(value);
  void updateBirthDate(DateTime value) => ref.read(profileProvider.notifier).updateBirthDate(value);
  void toggleCondition(String value) => ref.read(profileProvider.notifier).toggleCondition(value);
  
  Future<void> save() => ref.read(profileProvider.notifier).saveToDatabase();

  // --- Derived State Getters ---
  bool get isCreated => state.fullName.trim().isNotEmpty;
  
  String get displayName => isCreated ? state.fullName.trim() : '';

  String? get genderLabel => isCreated ? state.gender.name : null;

  int get age {
    final birthDate = state.birthDate;
    if (birthDate == null) return 0;
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  String? get photoPath => state.photoPath;

  String get bloodType => state.bloodType.trim().isEmpty ? 'not_added' : state.bloodType.trim();

  String get emergencyName => state.emergencyName;
  String get emergencyPhone => state.emergencyPhone;

  String? get formattedBirthDate {
    final date = state.birthDate;
    if (date == null) return null;
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}
