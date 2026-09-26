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
  bool _initialized = false;
  AppLockState _current = AppLockState.unknown;

  @override
  AppLockState build() {
    final prefsAsync = ref.watch(userPreferencesControllerProvider);

    return prefsAsync.maybeWhen(
      data: (prefs) {
        if (!_initialized) {
          _initialized = true;
          _current = prefs.appLockEnabled ? AppLockState.locked : AppLockState.unlocked;
          return _current;
        }
        return _current;
      },
      orElse: () {
        if (_initialized) return _current;
        _current = AppLockState.unknown;
        return _current;
      },
    );
  }

  void setLocked() {
    _current = AppLockState.locked;
    state = AppLockState.locked;
  }

  void setUnlocked() {
    _current = AppLockState.unlocked;
    state = AppLockState.unlocked;
  }

  void setUnknown() {
    _current = AppLockState.unknown;
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
    final prefsNotifier = ref.read(userPreferencesControllerProvider.notifier);
    final lockState = ref.read(appLockStateProvider.notifier);
    await prefsNotifier.updateSecurity(appLockEnabled: enabled);
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
