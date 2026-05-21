import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../gamification/presentation/providers/achievement_providers.dart';
import '../../../../shared/data/services/notification_engine.dart';
import '../../../../shared/providers/user_behavior_provider.dart';
import '../../../../shared/data/services/ad_controller.dart';
import '../../../../shared/providers/document_providers.dart';
import '../../../../shared/providers/shared_prefs_provider.dart';
import '../../../../core/security/session_lock_service.dart';

final appLifecycleProvider = NotifierProvider<AppLifecycleController, bool>(
  AppLifecycleController.new,
);

class AppLifecycleController extends Notifier<bool> {
  static const _lastLoginDayKey = 'achievement_last_login_day';
  static const _loginStreakKey = 'achievement_login_streak';
  static const _activeDaysKey = 'achievement_active_days';

  DateTime? _lastPausedTime;
  final _sessionLockService = SessionLockService();

  @override
  bool build() {
    return false;
  }

  void init() {
    final lockEnabled = ref.read(appLockEnabledProvider);
    if (lockEnabled) {
      ref.read(appLockStateProvider.notifier).setLocked();
    }

    unawaited(_trackDailyLoginAchievements());

    final user = ref.read(userBehaviorProvider);
    NotificationTriggers.onAppOpen(user);

    if (!lockEnabled) {
      unawaited(ref.read(adControllerProvider).onAppOpen());
    }
  }

  void handleLifecycleState(AppLifecycleState lifecycleState) {
    final lockEnabled = ref.read(appLockEnabledProvider);

    state = _sessionLockService.shouldObscure(
      lockEnabled: lockEnabled,
      state: lifecycleState,
    );

    if (lifecycleState == AppLifecycleState.paused) {
      _handlePaused();
    } else if (lifecycleState == AppLifecycleState.resumed) {
      _handleResumed(lockEnabled);
    }
  }

  void _handlePaused() {
    _lastPausedTime = DateTime.now();
    _sessionLockService.markPaused();
    NotificationTriggers.onAppClose();
  }

  void _handleResumed(bool lockEnabled) {
    ref.read(fileStorageServiceProvider).cleanupAllTempFiles();
    unawaited(_trackDailyLoginAchievements());

    if (lockEnabled && _lastPausedTime != null) {
      final timeout = ref.read(lockTimeoutProvider);
      if (_sessionLockService.shouldLockOnResume(timeout.duration)) {
        ref.read(appLockStateProvider.notifier).setLocked();
      } else {
        unawaited(ref.read(adControllerProvider).onAppOpen());
      }
    } else {
      unawaited(ref.read(adControllerProvider).onAppOpen());
    }
  }

  Future<void> _trackDailyLoginAchievements() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final today = _dayKey(DateTime.now());
    final lastDay = prefs.getString(_lastLoginDayKey);
    if (lastDay == today) return;

    final yesterday = _dayKey(DateTime.now().subtract(const Duration(days: 1)));
    final previousStreak = prefs.getInt(_loginStreakKey) ?? 0;
    final newStreak = lastDay == yesterday ? previousStreak + 1 : 1;
    final activeDays = (prefs.getInt(_activeDaysKey) ?? 0) + 1;

    await prefs.setString(_lastLoginDayKey, today);
    await prefs.setInt(_loginStreakKey, newStreak);
    await prefs.setInt(_activeDaysKey, activeDays);

    final achievement = ref.read(achievementProvider.notifier);
    await achievement.track('first_login', setAbsolute: 1);
    for (final id in const ['login_1', 'login_3', 'login_7', 'login_14', 'login_30', 'login_60', 'login_100', 'login_200', 'login_365']) {
      await achievement.track(id, setAbsolute: newStreak);
    }
    if (newStreak >= 30) {
      await achievement.track('streak_perfect_30', setAbsolute: newStreak);
    }
    for (final id in const ['active_3_days', 'active_7_days', 'active_30_days']) {
      await achievement.track(id, setAbsolute: activeDays);
    }
  }

  String _dayKey(DateTime value) {
    return '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
  }
}
