import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/domain/entities/lock_timeout.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/providers/notification_settings_provider.dart';
import '../../../../shared/providers/user_preferences_controller.dart';

class SettingsState {
  final AppThemeType themeMode;
  final String locale;
  final bool isLockEnabled;
  final LockTimeout lockTimeout;
  final bool biometricEnabled;
  final bool quickActionsEnabled;
  final NotificationSettings notificationSettings;

  SettingsState({
    required this.themeMode,
    required this.locale,
    required this.isLockEnabled,
    required this.lockTimeout,
    required this.biometricEnabled,
    required this.quickActionsEnabled,
    required this.notificationSettings,
  });
}

final settingsControllerProvider = NotifierProvider<SettingsController, SettingsState>(
  SettingsController.new,
);

class SettingsController extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    final prefsAsync = ref.watch(userPreferencesControllerProvider);
    
    return prefsAsync.maybeWhen(
      data: (p) => SettingsState(
        themeMode: p.themeType,
        locale: p.locale,
        isLockEnabled: p.appLockEnabled,
        lockTimeout: p.lockTimeout,
        biometricEnabled: p.biometricEnabled,
        quickActionsEnabled: p.quickActionsEnabled,
        notificationSettings: p.notificationSettings,
      ),
      orElse: () => SettingsState(
        themeMode: AppThemeType.system,
        locale: 'en',
        isLockEnabled: false,
        lockTimeout: LockTimeout.instant,
        biometricEnabled: false,
        quickActionsEnabled: false,
        notificationSettings: const NotificationSettings(),
      ),
    );
  }

  // --- Theme ---
  void setTheme(AppThemeType theme) => ref.read(userPreferencesControllerProvider.notifier).updateTheme(theme);

  // --- Locale ---
  void setLocale(String languageCode) => ref.read(userPreferencesControllerProvider.notifier).updateLocale(languageCode);

  // --- Lock ---
  Future<void> toggleLock(bool enabled) => ref.read(userPreferencesControllerProvider.notifier).updateSecurity(appLockEnabled: enabled);
  Future<void> setTimeout(LockTimeout timeout) => ref.read(userPreferencesControllerProvider.notifier).updateSecurity(lockTimeout: timeout);
  Future<void> toggleBiometric(bool enabled) => ref.read(userPreferencesControllerProvider.notifier).updateSecurity(biometricEnabled: enabled);

  // --- Quick Actions ---
  Future<void> toggleQuickActions(bool enabled) => ref.read(userPreferencesControllerProvider.notifier).toggleQuickActions(enabled);

  // --- Notifications ---
  Future<void> updateNotificationSettings(NotificationSettings settings) => 
      ref.read(userPreferencesControllerProvider.notifier).updateNotifications(settings);
}
