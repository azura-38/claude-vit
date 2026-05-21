import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/data/services/pin_service.dart';
import '../../../../core/types/runtime_types.dart';
import '../../../../shared/domain/entities/lock_timeout.dart';
import '../../../../shared/providers/notification_settings_provider.dart';
import '../../../../shared/providers/user_preferences_controller.dart';

// Note: appLockServiceProvider is defined in core/di/service_providers.dart
// and must NOT be duplicated here. Import it from there when needed.
export '../../../../core/di/service_providers.dart' show appLockServiceProvider;

final pinServiceProvider = Provider((ref) => PinService());

final hasPinProvider = FutureProvider<bool>((ref) async {
  return ref.watch(pinServiceProvider).hasPin();
});

final appLockStateProvider =
    NotifierProvider<AppLockStateNotifier, AppLockState>(
      AppLockStateNotifier.new,
    );

class AppLockStateNotifier extends Notifier<AppLockState> {
  @override
  AppLockState build() {
    final prefsAsync = ref.watch(userPreferencesControllerProvider);

    // While preferences are still loading, we cannot know the lock state.
    // Return [AppLockState.unknown] so the router shows the lock screen as
    // a safe default (better than showing home to an unauthenticated user).
    // Once prefs load, the provider rebuilds with the correct state.
    return prefsAsync.maybeWhen(
      data: (prefs) =>
          prefs.appLockEnabled ? AppLockState.locked : AppLockState.unlocked,
      orElse: () => AppLockState.unknown,
    );
  }

  void setLocked() {
    state = AppLockState.locked;
  }

  void setUnlocked() {
    state = AppLockState.unlocked;
  }

  void setUnknown() {
    state = AppLockState.unknown;
  }
}

final appLockEnabledProvider = NotifierProvider<AppLockEnabledNotifier, bool>(
  AppLockEnabledNotifier.new,
);

class AppLockEnabledNotifier extends Notifier<bool> {
  @override
  bool build() {
    final prefs = ref.watch(userPreferencesControllerProvider);
    return prefs.maybeWhen(
      data: (p) => p.appLockEnabled,
      orElse: () => false,
    );
  }

  Future<void> setEnabled(bool enabled) async {
    await ref
        .read(userPreferencesControllerProvider.notifier)
        .updateSecurity(appLockEnabled: enabled);
    final lockState = ref.read(appLockStateProvider.notifier);
    if (enabled) {
      lockState.setLocked();
    } else {
      lockState.setUnlocked();
    }
  }
}

final biometricEnabledProvider =
    NotifierProvider<BiometricEnabledNotifier, bool>(
      BiometricEnabledNotifier.new,
    );

class BiometricEnabledNotifier extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  Future<void> setEnabled(bool enabled) async {}
}

final lockTimeoutProvider = NotifierProvider<LockTimeoutNotifier, LockTimeout>(
  LockTimeoutNotifier.new,
);

class LockTimeoutNotifier extends Notifier<LockTimeout> {
  @override
  LockTimeout build() {
    final prefs = ref.watch(userPreferencesControllerProvider);
    return prefs.maybeWhen(
      data: (p) => p.lockTimeout,
      orElse: () => LockTimeout.instant,
    );
  }

  Future<void> setTimeout(LockTimeout mode) async {
    await ref
        .read(userPreferencesControllerProvider.notifier)
        .updateSecurity(lockTimeout: mode);
  }
}

final quickActionsProvider = NotifierProvider<QuickActionsNotifier, bool>(
  QuickActionsNotifier.new,
);

class QuickActionsNotifier extends Notifier<bool> {
  @override
  bool build() {
    final prefs = ref.watch(userPreferencesControllerProvider);
    return prefs.maybeWhen(
      data: (p) => p.quickActionsEnabled,
      orElse: () => true,
    );
  }

  Future<void> setEnabled(bool enabled) async {
    await ref
        .read(userPreferencesControllerProvider.notifier)
        .toggleQuickActions(enabled);
  }
}

final engagementRemindersProvider =
    NotifierProvider<EngagementRemindersNotifier, bool>(
      EngagementRemindersNotifier.new,
    );

class EngagementRemindersNotifier extends Notifier<bool> {
  @override
  bool build() {
    final prefs = ref.watch(userPreferencesControllerProvider);
    return prefs.maybeWhen(
      data: (p) => p.notificationSettings.smartNotificationsEnabled,
      orElse: () => false,
    );
  }

  Future<void> setEnabled(bool enabled) async {
    final current = ref
            .read(userPreferencesControllerProvider)
            .value
            ?.notificationSettings ??
        const NotificationSettings();
    await ref
        .read(userPreferencesControllerProvider.notifier)
        .updateNotifications(
          current.copyWith(smartNotificationsEnabled: enabled),
        );
  }
}
