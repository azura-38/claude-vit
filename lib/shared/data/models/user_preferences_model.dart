import 'package:vitacase/shared/domain/entities/user_preferences.dart';
import 'package:vitacase/features/profile/domain/models/user_profile.dart';
import 'package:vitacase/core/theme/app_theme.dart';
import 'package:vitacase/shared/domain/entities/lock_timeout.dart';
import 'package:vitacase/shared/providers/notification_settings_provider.dart';

class UserPreferencesModel {
  static Map<String, dynamic> profileToMap(UserProfile p) {
    return {
      'fullName': p.fullName,
      'email': p.email,
      'phone': p.phone,
      'photoPath': p.photoPath,
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

  static UserProfile profileFromMap(Map<String, dynamic> m) {
    return UserProfile(
      fullName: m['fullName'] as String? ?? '',
      email: m['email'] as String? ?? '',
      phone: m['phone'] as String? ?? '',
      photoPath: m['photoPath'] as String?,
      height: (m['height'] as num?)?.toDouble() ?? 0,
      weight: (m['weight'] as num?)?.toDouble() ?? 0,
      bloodType: m['bloodType'] as String? ?? '',
      gender: Gender.values.firstWhere(
        (g) => g.name == (m['gender'] as String?),
        orElse: () => Gender.other,
      ),
      birthDate: m['birthDate'] != null ? DateTime.tryParse(m['birthDate'] as String) : null,
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

  static Map<String, dynamic> notificationToMap(NotificationSettings s) {
    return {
      'smartNotificationsEnabled': s.smartNotificationsEnabled,
      'quietHoursEnabled': s.quietHoursEnabled,
      'quietHoursStart': s.quietHoursStart,
      'quietHoursStartMinute': s.quietHoursStartMinute,
      'quietHoursEnd': s.quietHoursEnd,
      'quietHoursEndMinute': s.quietHoursEndMinute,
      'showSensitiveDetails': s.showSensitiveDetails,
      'fullScreenRemindersEnabled': s.fullScreenRemindersEnabled,
      'engagementNotificationsEnabled': s.engagementNotificationsEnabled,
    };
  }

  static NotificationSettings notificationFromMap(Map<String, dynamic> m) {
    return NotificationSettings(
      smartNotificationsEnabled: m['smartNotificationsEnabled'] as bool? ?? true,
      quietHoursEnabled: m['quietHoursEnabled'] as bool? ?? false,
      quietHoursStart: m['quietHoursStart'] as int? ?? 22,
      quietHoursStartMinute: m['quietHoursStartMinute'] as int? ?? 0,
      quietHoursEnd: m['quietHoursEnd'] as int? ?? 8,
      quietHoursEndMinute: m['quietHoursEndMinute'] as int? ?? 0,
      showSensitiveDetails: m['showSensitiveDetails'] as bool? ?? false,
      fullScreenRemindersEnabled: m['fullScreenRemindersEnabled'] as bool? ?? false,
      engagementNotificationsEnabled: m['engagementNotificationsEnabled'] as bool? ?? true,
    );
  }

  static Map<String, dynamic> toMap(UserPreferences prefs) {
    return {
      'profile': profileToMap(prefs.profile),
      'themeType': prefs.themeType.name,
      'locale': prefs.locale,
      'appLockEnabled': prefs.appLockEnabled,
      'lockTimeout': prefs.lockTimeout.name,
      'biometricEnabled': prefs.biometricEnabled,
      'quickActionsEnabled': prefs.quickActionsEnabled,
      'notificationSettings': notificationToMap(prefs.notificationSettings),
    };
  }

  static UserPreferences fromMap(Map<String, dynamic> m) {
    return UserPreferences(
      profile: profileFromMap(Map<String, dynamic>.from(m['profile'] ?? {})),
      themeType: AppThemeType.values.firstWhere(
        (e) => e.name == m['themeType'],
        orElse: () => AppThemeType.system,
      ),
      locale: m['locale'] as String? ?? 'en',
      appLockEnabled: m['appLockEnabled'] as bool? ?? false,
      lockTimeout: LockTimeout.values.firstWhere(
        (e) => e.name == m['lockTimeout'],
        orElse: () => LockTimeout.instant,
      ),
      biometricEnabled: m['biometricEnabled'] as bool? ?? false,
      quickActionsEnabled: m['quickActionsEnabled'] as bool? ?? false,
      notificationSettings: notificationFromMap(Map<String, dynamic>.from(m['notificationSettings'] ?? {})),
    );
  }
}
