import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/data/services/ad_service.dart';
import '../../shared/providers/shared_prefs_provider.dart';
import '../../core/config/app_config.dart';
import '../types/runtime_types.dart';

final themeUnlockProvider = NotifierProvider<ThemeUnlockNotifier, DateTime?>(
  ThemeUnlockNotifier.new,
);

class ThemeUnlockNotifier extends Notifier<DateTime?> {
  static const _unlockUntilKey = 'rewarded_theme_unlock_until';

  Timer? _expiryTimer;

  @override
  DateTime? build() {
    ref.onDispose(() => _expiryTimer?.cancel());

    final prefs = ref.watch(sharedPreferencesProvider);
    final raw = prefs.getString(_unlockUntilKey);
    final until = raw == null ? null : DateTime.tryParse(raw);
    if (until == null || DateTime.now().isAfter(until)) return null;

    _scheduleExpiry(until);
    return until;
  }

  bool get isUnlocked {
    final until = state;
    return until != null && DateTime.now().isBefore(until);
  }

  Duration get remainingDuration {
    final until = state;
    if (until == null) return Duration.zero;
    final diff = until.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  int get remainingDays {
    final diff = remainingDuration;
    if (diff == Duration.zero) return 0;
    return diff.inDays + 1;
  }

  Future<bool> watchAdToUnlockOrExtend() async {
    final result = await AdService.showRewardedForResult();

    final isSuccess = result == RewardAdResult.shownRewarded;
    if (!isSuccess) {
      if (kDebugMode || AppConfig.closedTestFallbackEnabled) {
        debugPrint('[ThemeUnlock] Rewarded ad not shown or unavailable: $result. Fallback enabled (kDebugMode or closedTestFallbackEnabled is true). Temporarily unlocking theme for free.');
      } else {
        return false;
      }
    }

    final prefs = ref.read(sharedPreferencesProvider);
    final now = DateTime.now();
    final isNewUnlock = state == null || state!.isBefore(now);
    final base = isNewUnlock ? now : state!;
    final next = base.add(Duration(days: isNewUnlock ? 3 : 1));

    await prefs.setString(_unlockUntilKey, next.toIso8601String());
    state = next;
    _scheduleExpiry(next);
    return true;
  }

  void _scheduleExpiry(DateTime until) {
    _expiryTimer?.cancel();
    final delay = until.difference(DateTime.now());
    if (delay.isNegative || delay == Duration.zero) {
      state = null;
      return;
    }

    _expiryTimer = Timer(delay, () async {
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.remove(_unlockUntilKey);
      state = null;
    });
  }
}
