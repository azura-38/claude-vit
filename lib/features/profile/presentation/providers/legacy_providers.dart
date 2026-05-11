import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/providers/shared_prefs_provider.dart';

import 'profile_provider.dart';
import '../../domain/models/user_profile.dart';

// LEGACY ALIAS PROVIDERS TO FIX COMPILATION ERRORS
final profileCreatedProvider = Provider<bool>(
  (ref) => ref.watch(profileProvider).fullName.trim().isNotEmpty,
);

final profileNameProvider = Provider<String?>(
  (ref) {
    final name = ref.watch(profileProvider).fullName.trim();
    return name.isEmpty ? null : name;
  },
);
final profileGenderProvider = Provider<String?>(
  (ref) {
    if (!ref.watch(profileCreatedProvider)) return null;
    return ref.watch(profileProvider).gender.name;
  },
);
final profileBirthDateProvider = Provider<String?>((ref) {
  final date = ref.watch(profileProvider).birthDate;
  if (date == null) return null;
  return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
});
final profileAgeProvider = Provider<int>((ref) {
  final birthDate = ref.watch(profileProvider).birthDate;
  if (birthDate == null) return 0;
  return DateTime.now().year - birthDate.year;
});
final profilePhotoProvider = Provider<String?>(
  (ref) => null,
); // TODO: Add photoPath field to UserProfile when photo persistence is implemented
final profileBloodTypeProvider = Provider<String>(
  (ref) {
    final bloodType = ref.watch(profileProvider).bloodType.trim();
    return bloodType.isEmpty ? 'not_added' : bloodType;
  },
);
final profileEmergencyContactProvider = Provider<String>(
  (ref) => ref.watch(profileProvider).emergencyName,
);
final profileEmergencyPhoneProvider = Provider<String>(
  (ref) => ref.watch(profileProvider).emergencyPhone,
);

final profileDataProvider = Provider<AsyncValue<UserProfile>>((ref) {
  return AsyncValue.data(ref.watch(profileProvider));
});

class LegalAcceptedNotifier extends StateNotifier<bool> {
  LegalAcceptedNotifier(this.ref) : super(false) {
    state = ref.read(sharedPreferencesProvider).getBool(_key) ?? false;
  }

  final Ref ref;
  static const _key = 'legal_accepted';

  Future<void> accept() async {
    await ref.read(sharedPreferencesProvider).setBool(_key, true);
    state = true;
  }
}

final legalAcceptedProvider =
    StateNotifierProvider<LegalAcceptedNotifier, bool>(
      (ref) => LegalAcceptedNotifier(ref),
    );

final stepGoalProvider = Provider<int>((ref) => 10000);
final waterGoalProvider = Provider<int>((ref) => 2500);
