import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import '../data/services/analytics_service.dart';
import 'shared_prefs_provider.dart';

final adSkipProvider = NotifierProvider<AdSkipNotifier, int>(AdSkipNotifier.new);

class AdSkipNotifier extends Notifier<int> {
  static const String _tokenKey = 'ad_skip_tokens';

  @override
  int build() {
    if (!AppConfig.adSkipRewardsEnabled) return 0;
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getInt(_tokenKey) ?? 0;
  }

  Future<void> addTokens(int amount, {String source = 'reward'}) async {
    if (!AppConfig.adSkipRewardsEnabled) return;
    if (amount <= 0) return;

    final prefs = ref.read(sharedPreferencesProvider);
    final newVal = state + amount;
    state = newVal;
    if (source != 'xp_milestone') {
      AnalyticsService.log(AnalyticsService.rewardedAdForLimit, {'source': source});
    }
    await prefs.setInt(_tokenKey, newVal);
  }

  Future<bool> useToken({String reason = 'limit_unlock'}) async {
    if (!AppConfig.adSkipRewardsEnabled) return false;
    if (state <= 0) return false;

    final prefs = ref.read(sharedPreferencesProvider);
    final newVal = state - 1;
    state = newVal;
    await prefs.setInt(_tokenKey, newVal);

    AnalyticsService.log('ad_skip_token_used', {'reason': reason});

    return true;
  }
}
