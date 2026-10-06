import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/legal_version.dart';
import '../../../../shared/providers/shared_prefs_provider.dart';

import 'profile_provider.dart';
import '../../domain/models/user_profile.dart';

// LEGACY ALIAS PROVIDERS TO FIX COMPILATION ERRORS
class ProfileCreatedNotifier extends StateNotifier<bool> {
  ProfileCreatedNotifier(this.ref) : super(false) {
    ref.listen<UserProfile>(profileProvider, (prev, next) {
      if (next.fullName.trim().isNotEmpty) {
        state = true;
      }
    });
    _init();
  }

  final Ref ref;
  static const _key = 'profile_creation_skipped';

  void _init() {
    final nameCreated = ref.read(profileProvider).fullName.trim().isNotEmpty;
    if (nameCreated) {
      state = true;
      return;
    }
    state = ref.read(sharedPreferencesProvider).getBool(_key) ?? false;
  }

  Future<void> markCompleted() async {
    await ref.read(sharedPreferencesProvider).setBool(_key, true);
    state = true;
  }
}

final profileCreatedProvider = StateNotifierProvider<ProfileCreatedNotifier, bool>(
  (ref) => ProfileCreatedNotifier(ref),
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
  (ref) => ref.watch(profileProvider).photoPath,
);
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
    final prefs = ref.read(sharedPreferencesProvider);
    final accepted = prefs.getBool(_key) ?? false;
    final version = prefs.getString(_versionKey) ?? '';
    // Only truly accepted if version matches current
    state = accepted && version == LegalVersion.current;
  }

  final Ref ref;
  static const _key = 'legal_accepted';
  static const _versionKey = 'legal_accepted_version';
  static const _acceptedAtKey = 'legal_accepted_at';

  /// True when the user previously accepted legal but on an older version.
  bool get needsUpdate {
    final prefs = ref.read(sharedPreferencesProvider);
    final accepted = prefs.getBool(_key) ?? false;
    final version = prefs.getString(_versionKey) ?? '';
    return accepted && version != LegalVersion.current;
  }

  /// ISO 8601 timestamp of when the user accepted the legal agreement.
  String? get acceptedAt {
    return ref.read(sharedPreferencesProvider).getString(_acceptedAtKey);
  }

  /// Stored legal version that was accepted.
  String? get acceptedVersion {
    return ref.read(sharedPreferencesProvider).getString(_versionKey);
  }

  Future<void> accept() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_key, true);
    await prefs.setString(_versionKey, LegalVersion.current);
    await prefs.setString(_acceptedAtKey, DateTime.now().toUtc().toIso8601String());
    state = true;
  }
}

final legalAcceptedProvider =
    StateNotifierProvider<LegalAcceptedNotifier, bool>(
      (ref) => LegalAcceptedNotifier(ref),
    );

final legalAcceptedAtProvider = Provider<String?>((ref) {
  ref.watch(legalAcceptedProvider);
  return ref.watch(legalAcceptedProvider.notifier).acceptedAt;
});

/// True when the user previously accepted legal but on an older version.
/// Used by route guards to distinguish "needs update" from "never accepted".
final legalNeedsUpdateProvider = Provider<bool>((ref) {
  // Watch the main provider to stay reactive
  ref.watch(legalAcceptedProvider);
  return ref.watch(legalAcceptedProvider.notifier).needsUpdate;
});

final stepGoalProvider = Provider<int>((ref) => 10000);
final waterGoalProvider = Provider<int>((ref) => 2500);

