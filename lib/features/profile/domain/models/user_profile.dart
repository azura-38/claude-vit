enum Gender { female, male, other }

class UserProfile {
  final String fullName;
  final String email;
  final String phone;
  final String? photoPath;
  final double height;
  final double weight;
  final String bloodType;
  final Gender gender;
  final DateTime? birthDate;

  final String emergencyName;
  final String emergencyPhone;
  final String emergencyRelation;

  final List<String> conditions;
  final List<String> allergies;
  final List<String> medications;

  final bool privacyMode;
  final bool biometricLock;
  final bool silentNotifications;

  const UserProfile({
    this.fullName = '',
    this.email = '',
    this.phone = '',
    this.photoPath,
    this.height = 0,
    this.weight = 0,
    this.bloodType = '',
    this.gender = Gender.other,
    this.birthDate,
    this.emergencyName = '',
    this.emergencyPhone = '',
    this.emergencyRelation = '',
    this.conditions = const [],
    this.allergies = const [],
    this.medications = const [],
    this.privacyMode = false,
    this.biometricLock = false,
    this.silentNotifications = false,
  });

  String get name => fullName;

  double get bmi {
    if (height <= 0 || weight <= 0) return 0;
    return weight / ((height / 100) * (height / 100));
  }

  String get bmiStatus {
    if (bmi < 18.5) return 'bmi_underweight';
    if (bmi < 25) return 'bmi_normal';
    if (bmi < 30) return 'bmi_overweight';
    return 'bmi_obese';
  }

  double get completion {
    int completed = 0;

    if (fullName.isNotEmpty) completed++;
    if (email.isNotEmpty) completed++;
    if (phone.isNotEmpty) completed++;
    if (height > 0) completed++;
    if (weight > 0) completed++;
    if (bloodType.isNotEmpty) completed++;
    if (birthDate != null) completed++;
    if (emergencyName.isNotEmpty) completed++;
    if (emergencyPhone.isNotEmpty) completed++;

    return completed / 9;
  }

  UserProfile copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? photoPath,
    double? height,
    double? weight,
    String? bloodType,
    Gender? gender,
    DateTime? birthDate,
    String? emergencyName,
    String? emergencyPhone,
    String? emergencyRelation,
    List<String>? conditions,
    List<String>? allergies,
    List<String>? medications,
    bool? privacyMode,
    bool? biometricLock,
    bool? silentNotifications,
  }) {
    return UserProfile(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoPath: photoPath ?? this.photoPath,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      bloodType: bloodType ?? this.bloodType,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      emergencyName: emergencyName ?? this.emergencyName,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
      emergencyRelation: emergencyRelation ?? this.emergencyRelation,
      conditions: conditions ?? this.conditions,
      allergies: allergies ?? this.allergies,
      medications: medications ?? this.medications,
      privacyMode: privacyMode ?? this.privacyMode,
      biometricLock: biometricLock ?? this.biometricLock,
      silentNotifications: silentNotifications ?? this.silentNotifications,
    );
  }
}
