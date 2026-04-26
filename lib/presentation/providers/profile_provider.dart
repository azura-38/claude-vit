import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'shared_prefs_provider.dart';
import 'onboarding_provider.dart';
import '../../core/di/service_providers.dart';
import 'achievement_providers.dart';
import '../../data/services/analytics_service.dart';

class ProfileData {
  final String? name;
  final String? gender;
  final String? birthDateIso;
  final String? emergencyContact;
  final String? emergencyContactPhone;
  final String? jobTitle;
  final String? idNumber;
  final String? email;
  final String? phone;
  final String? bloodType;
  final double? height;
  final double? weight;
  final String? photoPath;

  const ProfileData({
    this.name,
    this.gender,
    this.birthDateIso,
    this.emergencyContact,
    this.emergencyContactPhone,
    this.jobTitle,
    this.idNumber,
    this.email,
    this.phone,
    this.bloodType,
    this.height,
    this.weight,
    this.photoPath,
  });

  ProfileData copyWith({
    String? name,
    String? gender,
    String? birthDateIso,
    String? emergencyContact,
    String? emergencyContactPhone,
    String? jobTitle,
    String? idNumber,
    String? email,
    String? phone,
    String? bloodType,
    double? height,
    double? weight,
    String? photoPath,
  }) {
    return ProfileData(
      name: name ?? this.name,
      gender: gender ?? this.gender,
      birthDateIso: birthDateIso ?? this.birthDateIso,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
      jobTitle: jobTitle ?? this.jobTitle,
      idNumber: idNumber ?? this.idNumber,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      bloodType: bloodType ?? this.bloodType,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      photoPath: photoPath ?? this.photoPath,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'gender': gender,
    'birthDateIso': birthDateIso,
    'emergencyContact': emergencyContact,
    'emergencyContactPhone': emergencyContactPhone,
    'jobTitle': jobTitle,
    'idNumber': idNumber,
    'email': email,
    'phone': phone,
    'bloodType': bloodType,
    'height': height,
    'weight': weight,
    'photoPath': photoPath,
  };

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      name: json['name'] as String?,
      gender: json['gender'] as String?,
      birthDateIso: json['birthDateIso'] as String?,
      emergencyContact: json['emergencyContact'] as String?,
      emergencyContactPhone: json['emergencyContactPhone'] as String?,
      jobTitle: json['jobTitle'] as String?,
      idNumber: json['idNumber'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      bloodType: json['bloodType'] as String?,
      height: (json['height'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      photoPath: json['photoPath'] as String?,
    );
  }

  String get maskedId {
    if (idNumber == null || idNumber!.length < 4) return idNumber ?? '';
    return "${idNumber!.substring(0, 3)}******${idNumber!.substring(idNumber!.length - 2)}";
  }
}

final profileDataProvider = AsyncNotifierProvider<ProfileDataNotifier, ProfileData>(
  ProfileDataNotifier.new,
);

class ProfileDataNotifier extends AsyncNotifier<ProfileData> {
  static const _profileKey = 'profile_data_v2';

  Future<void> _save(ProfileData data) async {
    final prefs = ref.read(sharedPreferencesProvider);
    final encryptionService = ref.read(encryptionServiceProvider);
    final encrypted = await encryptionService.encryptString(jsonEncode(data.toJson()));
    await prefs.setString(_profileKey, encrypted);
  }

  Future<ProfileData> _migrateFromLegacy(SharedPreferences prefs) async {
    final legacy = ProfileData(
      name: prefs.getString('profile_name'),
      gender: prefs.getString('profile_gender'),
      birthDateIso: prefs.getString('profile_birthDate'),
      emergencyContact: prefs.getString('profile_emergencyContact'),
      jobTitle: prefs.getString('profile_job'),
      idNumber: prefs.getString('profile_idNumber'),
      email: prefs.getString('profile_email'),
      phone: prefs.getString('profile_phone'),
      height: prefs.getDouble('profile_height'),
      weight: prefs.getDouble('profile_weight'),
      photoPath: prefs.getString('user_image'),
    );

    final hasLegacy = legacy.name != null ||
        legacy.gender != null ||
        legacy.birthDateIso != null ||
        legacy.emergencyContact != null ||
        legacy.jobTitle != null ||
        legacy.idNumber != null ||
        legacy.email != null ||
        legacy.phone != null ||
        legacy.height != null ||
        legacy.weight != null ||
        legacy.photoPath != null;

    if (hasLegacy) {
      await _save(legacy);
      await prefs.remove('profile_name');
      await prefs.remove('profile_gender');
      await prefs.remove('profile_birthDate');
      await prefs.remove('profile_emergencyContact');
      await prefs.remove('profile_job');
      await prefs.remove('profile_idNumber');
      await prefs.remove('profile_email');
      await prefs.remove('profile_phone');
      await prefs.remove('profile_height');
      await prefs.remove('profile_weight');
      await prefs.remove('user_image');
    }

    return legacy;
  }

  @override
  Future<ProfileData> build() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final encrypted = prefs.getString(_profileKey);
    if (encrypted == null || encrypted.isEmpty) {
      return _migrateFromLegacy(prefs);
    }

    final encryptionService = ref.read(encryptionServiceProvider);
    final decrypted = await encryptionService.decryptString(encrypted);
    if (decrypted == null || decrypted.isEmpty) {
      return _migrateFromLegacy(prefs);
    }

    try {
      final jsonMap = jsonDecode(decrypted) as Map<String, dynamic>;
      return ProfileData.fromJson(jsonMap);
    } catch (_) {
      return _migrateFromLegacy(prefs);
    }
  }

   Future<void> saveProfile(ProfileData data) async {
    state = AsyncValue.data(data);
    await _save(data);

    // Achievement: Complete Profile
    if (data.name != null && data.name!.isNotEmpty &&
        data.gender != null && data.gender!.isNotEmpty &&
        data.birthDateIso != null && data.birthDateIso!.isNotEmpty) {
      ref.read(achievementProvider.notifier).track("profile_completed", value: 1);
      AnalyticsService.log(AnalyticsService.profileCompleted);
    }

    // Achievement: Add Emergency Info
    if ((data.emergencyContact != null && data.emergencyContact!.isNotEmpty) ||
        (data.bloodType != null && data.bloodType!.isNotEmpty)) {
      ref.read(achievementProvider.notifier).track("emergency_added", value: 1);
    }
  }

}

ProfileData? _profileOrNull(AsyncValue<ProfileData> value) {
  return value.maybeWhen(data: (d) => d, orElse: () => null);
}

final profileNameProvider = Provider<String?>((ref) {
  return _profileOrNull(ref.watch(profileDataProvider))?.name;
});

final profileGenderProvider = Provider<String?>((ref) {
  return _profileOrNull(ref.watch(profileDataProvider))?.gender;
});

final profileBirthDateProvider = Provider<String?>((ref) {
  return _profileOrNull(ref.watch(profileDataProvider))?.birthDateIso;
});

final profileEmergencyContactProvider = Provider<String?>((ref) {
  return _profileOrNull(ref.watch(profileDataProvider))?.emergencyContact;
});

final profileEmergencyPhoneProvider = Provider<String?>((ref) {
  return _profileOrNull(ref.watch(profileDataProvider))?.emergencyContactPhone;
});

final stepGoalProvider = NotifierProvider<StepGoalNotifier, int>(StepGoalNotifier.new);

class StepGoalNotifier extends Notifier<int> {
  @override
  int build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getInt('goal_steps') ?? 10000;
  }

  void update(int value) => state = value;
}

final waterGoalProvider = NotifierProvider<WaterGoalNotifier, int>(WaterGoalNotifier.new);

class WaterGoalNotifier extends Notifier<int> {
  @override
  int build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getInt('goal_water') ?? 2500;
  }

  void update(int value) => state = value;
}

final profileJobProvider = Provider<String?>((ref) {
  return _profileOrNull(ref.watch(profileDataProvider))?.jobTitle;
});

final profileHeightProvider = Provider<double?>((ref) {
  return _profileOrNull(ref.watch(profileDataProvider))?.height;
});

final profileWeightProvider = Provider<double?>((ref) {
  return _profileOrNull(ref.watch(profileDataProvider))?.weight;
});

final profileIdNumberProvider = Provider<String?>((ref) {
  return _profileOrNull(ref.watch(profileDataProvider))?.idNumber;
});

final profileEmailProvider = Provider<String?>((ref) {
  return _profileOrNull(ref.watch(profileDataProvider))?.email;
});

final profilePhoneProvider = Provider<String?>((ref) {
  return _profileOrNull(ref.watch(profileDataProvider))?.phone;
});

final profileBloodTypeProvider = Provider<String?>((ref) {
  return _profileOrNull(ref.watch(profileDataProvider))?.bloodType;
});

final profilePhotoProvider = Provider<String?>((ref) {
  return _profileOrNull(ref.watch(profileDataProvider))?.photoPath;
});

final bmiResultProvider = Provider<Map<String, dynamic>?>((ref) {
  final height = ref.watch(profileHeightProvider);
  final weight = ref.watch(profileWeightProvider);
  
  if (height == null || weight == null || height == 0) return null;
  
  final bmi = weight / ((height / 100) * (height / 100));
  String category;
  double idealMin = 18.5 * (height / 100) * (height / 100);
  double idealMax = 24.9 * (height / 100) * (height / 100);
  
  if (bmi < 18.5) {
    category = "bmi_underweight";
  } else if (bmi < 25) {
    category = "bmi_normal";
  } else if (bmi < 30) {
    category = "bmi_overweight";
  } else {
    category = "bmi_obese";
  }
  
  return {
    'score': bmi,
    'category': category,
    'idealMin': idealMin,
    'idealMax': idealMax,
  };
});

final profileAgeProvider = Provider<int?>((ref) {
  final birthDateStr = ref.watch(profileBirthDateProvider);
  if (birthDateStr == null) return null;
  try {
    DateTime? birthDate;
    if (birthDateStr.contains('-')) {
      birthDate = DateTime.tryParse(birthDateStr);
    } else if (birthDateStr.contains('.')) {
      final parts = birthDateStr.split('.');
      if (parts.length == 3) {
        final day = int.tryParse(parts[0]);
        final month = int.tryParse(parts[1]);
        final year = int.tryParse(parts[2]);
        if (day != null && month != null && year != null) {
          birthDate = DateTime(year, month, day);
        }
      }
    }
    if (birthDate == null) return null;
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  } catch (_) {
    return null;
  }
});

class ProfileService {
  final Ref ref;
  ProfileService(this.ref);

  Future<void> saveProfile({
    required String name,
    required String gender,
    String? birthDate,
    String? emergencyContact,
    String? emergencyContactPhone,
    String? jobTitle,
    String? idNumber,
    String? email,
    String? phone,
    double? height,
    double? weight,
    String? photoPath,
  }) async {
    final current = _profileOrNull(ref.read(profileDataProvider)) ?? const ProfileData();
    final updated = current.copyWith(
      name: name,
      gender: gender,
      birthDateIso: birthDate ?? current.birthDateIso,
      emergencyContact: emergencyContact ?? current.emergencyContact,
      emergencyContactPhone: emergencyContactPhone ?? current.emergencyContactPhone,
      jobTitle: jobTitle ?? current.jobTitle,
      idNumber: idNumber ?? current.idNumber,
      email: email ?? current.email,
      phone: phone ?? current.phone,
      height: height ?? current.height,
      weight: weight ?? current.weight,
      photoPath: photoPath ?? current.photoPath,
    );
    await ref.read(profileDataProvider.notifier).saveProfile(updated);
    
    // Also mark onboarding as fully complete
    await ref.read(onboardingCompletedProvider.notifier).completeOnboarding();
  }

  Future<void> updatePersonalStats({required double height, required double weight}) async {
    final current = _profileOrNull(ref.read(profileDataProvider)) ?? const ProfileData();
    final updated = current.copyWith(height: height, weight: weight);
    await ref.read(profileDataProvider.notifier).saveProfile(updated);
  }

  Future<void> updateGoals({required int steps, required int water}) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setInt('goal_steps', steps);
    await prefs.setInt('goal_water', water);
    ref.read(stepGoalProvider.notifier).update(steps);
    ref.read(waterGoalProvider.notifier).update(water);
  }

  Future<void> updateEmergencyContact(String contact) async {
    final current = _profileOrNull(ref.read(profileDataProvider)) ?? const ProfileData();
    final updated = current.copyWith(emergencyContact: contact);
    await ref.read(profileDataProvider.notifier).saveProfile(updated);
  }

  Future<void> updateProfilePhoto(String photoPath) async {
    final current = _profileOrNull(ref.read(profileDataProvider)) ?? const ProfileData();
    final updated = current.copyWith(photoPath: photoPath);
    await ref.read(profileDataProvider.notifier).saveProfile(updated);
  }
}

final profileServiceProvider = Provider((ref) => ProfileService(ref));

/// Mandatory Legal Acceptance Tracking
/// Required for 100% Production Readiness / Play Store Compliance
final legalAcceptedProvider = NotifierProvider<LegalAcceptedNotifier, bool>(LegalAcceptedNotifier.new);

class LegalAcceptedNotifier extends Notifier<bool> {
  static const _key = 'legal_accepted_v1';

  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(_key) ?? false;
  }

  Future<void> accept() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_key, true);
    state = true;
  }
}
