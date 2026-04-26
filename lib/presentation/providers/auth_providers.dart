import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'shared_prefs_provider.dart';
import '../../data/services/app_lock_service.dart';
import '../../data/services/pin_service.dart';
import '../../core/types/runtime_types.dart';
import '../../core/l10n/app_localizations.dart';

final appLockServiceProvider = Provider((ref) => AppLockService());
final pinServiceProvider = Provider((ref) => PinService());

final hasPinProvider = FutureProvider<bool>((ref) async {
  return ref.watch(pinServiceProvider).hasPin();
});

final appLockStateProvider =
    NotifierProvider<AppLockStateNotifier, AppLockState>(AppLockStateNotifier.new);

class AppLockStateNotifier extends Notifier<AppLockState> {
  @override
  AppLockState build() {
    final isEnabled = ref.watch(appLockEnabledProvider);
    return isEnabled ? AppLockState.locked : AppLockState.unlocked;
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

final appLockEnabledProvider = NotifierProvider<AppLockEnabledNotifier, bool>(AppLockEnabledNotifier.new);

class AppLockEnabledNotifier extends Notifier<bool> {
  static const _key = 'app_lock_enabled';

  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(_key) ?? false;
  }

  Future<void> setEnabled(bool enabled) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_key, enabled);
    state = enabled;
    final lockState = ref.read(appLockStateProvider.notifier);
    if (enabled) {
      lockState.setLocked();
    } else {
      lockState.setUnlocked();
    }
  }
}


enum LockTimeout {
  instant(Duration.zero, 'lock_timeout_instant'),
  oneMinute(Duration(minutes: 1), 'lock_timeout_1m'),
  fiveMinutes(Duration(minutes: 5), 'lock_timeout_5m'),
  fifteenMinutes(Duration(minutes: 15), 'lock_timeout_15m');

  final Duration duration;
  final String key;
  const LockTimeout(this.duration, this.key);

  String localizedLabel(BuildContext context) => context.l10n(key);
}

final lockTimeoutProvider = NotifierProvider<LockTimeoutNotifier, LockTimeout>(LockTimeoutNotifier.new);

class LockTimeoutNotifier extends Notifier<LockTimeout> {
  static const _key = 'app_lock_timeout';

  @override
  LockTimeout build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final index = prefs.getInt(_key) ?? 0;
    return LockTimeout.values[index.clamp(0, LockTimeout.values.length - 1)];
  }

  Future<void> setTimeout(LockTimeout mode) async {
    state = mode;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setInt(_key, mode.index);
  }
}

final quickActionsProvider = NotifierProvider<QuickActionsNotifier, bool>(QuickActionsNotifier.new);

class QuickActionsNotifier extends Notifier<bool> {
  static const _key = 'quick_actions_enabled';

  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(_key) ?? true;
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_key, enabled);
  }
}

final engagementRemindersProvider =
    NotifierProvider<EngagementRemindersNotifier, bool>(EngagementRemindersNotifier.new);

class EngagementRemindersNotifier extends Notifier<bool> {
  static const _key = 'engagement_reminders_enabled';

  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(_key) ?? false;
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_key, enabled);
  }
}
