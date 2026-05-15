import 'package:vitacase/features/profile/domain/models/user_profile.dart';
import 'package:vitacase/core/theme/app_theme.dart';
import 'package:vitacase/shared/providers/notification_settings_provider.dart';
import 'lock_timeout.dart';

class UserPreferences {
  final UserProfile profile;
  final AppThemeType themeType;
  final String locale;
  final bool appLockEnabled;
  final LockTimeout lockTimeout;
  final bool biometricEnabled;
  final bool quickActionsEnabled;
  final NotificationSettings notificationSettings;

  const UserPreferences({
    this.profile = const UserProfile(),
    this.themeType = AppThemeType.light,
    this.locale = 'en',
    this.appLockEnabled = false,
    this.lockTimeout = LockTimeout.instant,
    this.biometricEnabled = false,
    this.quickActionsEnabled = true,
    this.notificationSettings = const NotificationSettings(),
  });

  UserPreferences copyWith({
    UserProfile? profile,
    AppThemeType? themeType,
    String? locale,
    bool? appLockEnabled,
    LockTimeout? lockTimeout,
    bool? biometricEnabled,
    bool? quickActionsEnabled,
    NotificationSettings? notificationSettings,
  }) {
    return UserPreferences(
      profile: profile ?? this.profile,
      themeType: themeType ?? this.themeType,
      locale: locale ?? this.locale,
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
      lockTimeout: lockTimeout ?? this.lockTimeout,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      quickActionsEnabled: quickActionsEnabled ?? this.quickActionsEnabled,
      notificationSettings: notificationSettings ?? this.notificationSettings,
    );
  }
}
