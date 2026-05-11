import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'shared_prefs_provider.dart';
import '../data/services/analytics_service.dart';

final adSkipProvider = NotifierProvider<AdSkipNotifier, int>(
  AdSkipNotifier.new,
);

class AdSkipNotifier extends Notifier<int> {
  static const String _tokenKey = 'ad_skip_tokens';

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
    return true;
  }
}
