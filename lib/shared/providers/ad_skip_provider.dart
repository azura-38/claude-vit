import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/gamification/presentation/providers/achievement_providers.dart';
import '../data/services/analytics_service.dart';
import 'shared_prefs_provider.dart';

final adSkipProvider = NotifierProvider<AdSkipNotifier, int>(AdSkipNotifier.new);

class AdSkipNotifier extends Notifier<int> {
  static const String _tokenKey = 'ad_skip_tokens';
  static const String _usedCountKey = 'achievement_ad_skip_used_count';

  @override
  int build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getInt(_tokenKey) ?? 0;
  }

  Future<void> addTokens(int amount) async {
    final prefs = ref.read(sharedPreferencesProvider);
    final newVal = state + amount;
    state = newVal;
    AnalyticsService.log(AnalyticsService.rewardedAdForLimit);
    await prefs.setInt(_tokenKey, newVal);
  }

  Future<bool> useToken() async {
    if (state <= 0) return false;

    final prefs = ref.read(sharedPreferencesProvider);
    final newVal = state - 1;
    state = newVal;
    await prefs.setInt(_tokenKey, newVal);

    final usedCount = (prefs.getInt(_usedCountKey) ?? 0) + 1;
    await prefs.setInt(_usedCountKey, usedCount);
    await ref.read(achievementProvider.notifier).track('ad_skip_used', setAbsolute: usedCount);

    return true;
  }
}
