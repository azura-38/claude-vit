import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/repository_providers.dart';
import '../../core/theme/app_theme.dart';
import '../../features/profile/domain/models/user_profile.dart';
import '../domain/entities/lock_timeout.dart';
import '../domain/entities/user_preferences.dart';
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

  Future<UserPreferences> _currentOrLoad() async {
    final current = state.valueOrNull;
    if (current != null) return current;

    try {
      return await future;
    } catch (_) {
      final repo = ref.read(userPreferencesRepositoryProvider);
      return repo.getPreferences();
    }
  }

  Future<void> updateProfile(UserProfile profile) async {
    final current = await _currentOrLoad();
    final updated = current.copyWith(profile: profile);
    await _save(updated);
  }

  Future<void> updateTheme(AppThemeType theme) async {
    final current = await _currentOrLoad();
    final updated = current.copyWith(themeType: theme);
    await _save(updated);
  }

  Future<void> updateLocale(String locale) async {
    final current = await _currentOrLoad();
    final updated = current.copyWith(locale: locale);
    await _save(updated);
  }

  Future<void> updateSecurity({
    bool? appLockEnabled,
    LockTimeout? lockTimeout,
    bool? biometricEnabled,
  }) async {
    final current = await _currentOrLoad();
    final updated = current.copyWith(
      appLockEnabled: appLockEnabled ?? current.appLockEnabled,
      lockTimeout: lockTimeout ?? current.lockTimeout,
      biometricEnabled: biometricEnabled ?? current.biometricEnabled,
    );
    await _save(updated);
  }

  Future<void> updateNotifications(NotificationSettings settings) async {
    final current = await _currentOrLoad();
    final updated = current.copyWith(notificationSettings: settings);
    await _save(updated);
  }

  Future<void> toggleQuickActions(bool enabled) async {
    final current = await _currentOrLoad();
    final updated = current.copyWith(quickActionsEnabled: enabled);
    await _save(updated);
  }

  Future<void> _save(UserPreferences preferences) async {
    state = AsyncData(preferences);
    final repo = ref.read(userPreferencesRepositoryProvider);
    await repo.savePreferences(preferences);
  }
}
