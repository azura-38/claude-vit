import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/data/services/ad_service.dart';
import '../../shared/providers/shared_prefs_provider.dart';

final themeUnlockProvider = NotifierProvider<ThemeUnlockNotifier, DateTime?>(
  ThemeUnlockNotifier.new,
);

class ThemeUnlockNotifier extends Notifier<DateTime?> {
  static const _unlockUntilKey = 'rewarded_theme_unlock_until';

  @override
  DateTime? build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final raw = prefs.getString(_unlockUntilKey);
    final until = raw == null ? null : DateTime.tryParse(raw);
    if (until == null || DateTime.now().isAfter(until)) return null;
    return until;
  }

  bool get isUnlocked {
    final until = state;
    return until != null && DateTime.now().isBefore(until);
  }

  int get remainingDays {
    final until = state;
    if (until == null) return 0;
    final diff = until.difference(DateTime.now());
    if (diff.isNegative) return 0;
    return diff.inDays + 1;
  }

  Future<bool> watchAdToUnlockOrExtend() async {
    final result = await AdService.showRewardedForResult();

    // During development, emulator/device fill can be unavailable even with a
    // valid AdMob setup. Keep the theme flow testable instead of blocking UX.
    if (result.name != 'shownRewarded' && kReleaseMode) return false;

    final prefs = ref.read(sharedPreferencesProvider);
    final now = DateTime.now();
    final base = state != null && state!.isAfter(now)
        ? state!
        : now.add(const Duration(days: 2));
    final next = base.add(const Duration(days: 1));

    await prefs.setString(_unlockUntilKey, next.toIso8601String());
    state = next;
    return true;
  }
}
