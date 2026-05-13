import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/repository_providers.dart';
import '../domain/entities/user_preferences.dart';
import '../../../features/profile/domain/models/user_profile.dart';
import '../../core/theme/app_theme.dart';
import '../domain/entities/lock_timeout.dart';
import '../providers/notification_settings_provider.dart';

final userPreferencesControllerProvider = AsyncNotifierProvider<UserPreferencesController, UserPreferences>(
  UserPreferencesController.new,
);

class UserPreferencesController extends AsyncNotifier<UserPreferences> {
  @override
  Future<UserPreferences> build() async {
    final repo = ref.watch(userPreferencesRepositoryProvider);
    return repo.getPreferences();
  }

  Future<void> updateProfile(UserProfile profile) async {
    if (!state.hasValue) return;
    final updated = state.value!.copyWith(profile: profile);
    await _save(updated);
  }

  Future<void> updateTheme(AppThemeType theme) async {
    if (!state.hasValue) return;
    final updated = state.value!.copyWith(themeType: theme);
    await _save(updated);
  }

  Future<void> updateLocale(String locale) async {
    if (!state.hasValue) return;
    final updated = state.value!.copyWith(locale: locale);
    await _save(updated);
  }

  Future<void> updateSecurity({
    bool? appLockEnabled,
    LockTimeout? lockTimeout,
    bool? biometricEnabled,
  }) async {
    if (!state.hasValue) return;
    final updated = state.value!.copyWith(
      appLockEnabled: appLockEnabled,
      lockTimeout: lockTimeout,
      biometricEnabled: biometricEnabled,
    );
    await _save(updated);
  }

  Future<void> updateNotifications(NotificationSettings settings) async {
    if (!state.hasValue) return;
    final updated = state.value!.copyWith(notificationSettings: settings);
    await _save(updated);
  }

  Future<void> toggleQuickActions(bool enabled) async {
    if (!state.hasValue) return;
    final updated = state.value!.copyWith(quickActionsEnabled: enabled);
    await _save(updated);
  }

  Future<void> _save(UserPreferences preferences) async {
    state = AsyncData(preferences);
    final repo = ref.read(userPreferencesRepositoryProvider);
    await repo.savePreferences(preferences);
  }
}
