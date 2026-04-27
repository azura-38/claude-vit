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
  static const String _firstOpenKey = 'ad_first_open_time';
  static const String _onboardingKey = 'onboarding_completed';

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
    
    if (lastTime == null || now.difference(lastTime).inMinutes >= 10) {
      AdService.showInterstitial();
      await _prefs.setInt(_timeKey, now.millisecondsSinceEpoch);
    }
  }

  Future<void> onAppOpen() async {
    if (!(_prefs.getBool(_onboardingKey) ?? false)) return;

    final now = DateTime.now();
    final firstOpenMillis = _prefs.getInt(_firstOpenKey);
    if (firstOpenMillis == null) {
      await _prefs.setInt(_firstOpenKey, now.millisecondsSinceEpoch);
      return;
    }

    final firstOpen = DateTime.fromMillisecondsSinceEpoch(firstOpenMillis);
    if (now.difference(firstOpen).inDays < 7) return;

    AdService.showAppOpenAd();
  }
}
