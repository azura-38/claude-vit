import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sembast/sembast.dart';
import '../../domain/models/user_profile.dart';
import '../../../../shared/data/datasources/sembast_database.dart';

final profileProvider = StateNotifierProvider<ProfileNotifier, UserProfile>((
  ref,
) {
  return ProfileNotifier(SembastDatabase());
});

class ProfileNotifier extends StateNotifier<UserProfile> {
  final SembastDatabase _db;
  static final _store = StoreRef<String, Map<String, Object?>>('profile');
  static const _key = 'user_profile';

  ProfileNotifier(this._db) : super(const UserProfile()) {
    _loadFromDb();
  }

  Future<void> _loadFromDb() async {
    try {
      final record = await _store.record(_key).get(_db.db);
      if (record != null) {
        state = _fromMap(record);
      }
    } catch (e) {
      // First run or DB not ready — keep defaults
    }
  }

  Future<void> saveToDatabase() async {
    await _store.record(_key).put(_db.db, _toMap(state));
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

  void updateBirthDate(DateTime value) {
    state = state.copyWith(birthDate: value);
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

  // --- Serialization ---

  Map<String, Object?> _toMap(UserProfile p) {
    return {
      'fullName': p.fullName,
      'email': p.email,
      'phone': p.phone,
      'height': p.height,
      'weight': p.weight,
      'bloodType': p.bloodType,
      'gender': p.gender.name,
      'birthDate': p.birthDate?.toIso8601String(),
      'emergencyName': p.emergencyName,
      'emergencyPhone': p.emergencyPhone,
      'emergencyRelation': p.emergencyRelation,
      'conditions': p.conditions,
      'allergies': p.allergies,
      'medications': p.medications,
      'privacyMode': p.privacyMode,
      'biometricLock': p.biometricLock,
      'silentNotifications': p.silentNotifications,
    };
  }

  UserProfile _fromMap(Map<String, Object?> m) {
    return UserProfile(
      fullName: m['fullName'] as String? ?? '',
      email: m['email'] as String? ?? '',
      phone: m['phone'] as String? ?? '',
      height: (m['height'] as num?)?.toDouble() ?? 0,
      weight: (m['weight'] as num?)?.toDouble() ?? 0,
      bloodType: m['bloodType'] as String? ?? '',
      gender: Gender.values.firstWhere(
        (g) => g.name == (m['gender'] as String?),
        orElse: () => Gender.other,
      ),
      birthDate:
          m['birthDate'] != null
              ? DateTime.tryParse(m['birthDate'] as String)
              : null,
      emergencyName: m['emergencyName'] as String? ?? '',
      emergencyPhone: m['emergencyPhone'] as String? ?? '',
      emergencyRelation: m['emergencyRelation'] as String? ?? '',
      conditions: (m['conditions'] as List?)?.cast<String>() ?? [],
      allergies: (m['allergies'] as List?)?.cast<String>() ?? [],
      medications: (m['medications'] as List?)?.cast<String>() ?? [],
      privacyMode: m['privacyMode'] as bool? ?? false,
      biometricLock: m['biometricLock'] as bool? ?? false,
      silentNotifications: m['silentNotifications'] as bool? ?? false,
    );
  }
}
