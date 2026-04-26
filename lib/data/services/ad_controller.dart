import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ad_service.dart';
import '../../presentation/providers/shared_prefs_provider.dart';

final adControllerProvider = Provider((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AdController(prefs);
});

class AdController {
  final SharedPreferences _prefs;
  static const String _countKey = 'ad_action_count';
  static const String _timeKey = 'ad_last_time';

  AdController(this._prefs);

  int get _actionCount => _prefs.getInt(_countKey) ?? 0;
  DateTime? get _lastAdTime {
    final millis = _prefs.getInt(_timeKey);
    return millis != null ? DateTime.fromMillisecondsSinceEpoch(millis) : null;
  }

  Future<void> onActionTriggered() async {
    final newCount = _actionCount + 1;
    await _prefs.setInt(_countKey, newCount);
    
    // Show interstitial every 5 significant actions
    if (newCount % 5 == 0) {
      _tryShowAd();
    }
  }

  Future<void> _tryShowAd() async {
    final now = DateTime.now();
    final lastTime = _lastAdTime;
    
    // 2-minute cooldown between interstitials
    if (lastTime == null || now.difference(lastTime).inMinutes >= 2) {
      AdService.showInterstitial();
      await _prefs.setInt(_timeKey, now.millisecondsSinceEpoch);
    }
  }

  void onAppOpen() {
    AdService.showAppOpenAd();
  }
}
