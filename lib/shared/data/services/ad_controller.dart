import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/ads/ad_visibility_policy.dart';
import '../../../features/gamification/presentation/providers/achievement_providers.dart';
import '../../providers/ad_skip_provider.dart';
import '../../providers/shared_prefs_provider.dart';
import 'ad_service.dart';

final adControllerProvider = Provider((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final policy = ref.watch(adVisibilityPolicyProvider);
  return AdController(ref, prefs, policy);
});

class AdController {
  final Ref _ref;
  final SharedPreferences _prefs;
  final AdVisibilityPolicy _policy;
  static const String _countKey = 'ad_action_count';
  static const String _shownCountKey = 'ad_shown_count';
  static const String _timeKey = 'ad_last_time';
  static const String _firstOpenKey = 'ad_first_open_time';
  static const String _onboardingKey = 'onboarding_completed';

  AdController(this._ref, this._prefs, this._policy);

  int get _actionCount => _prefs.getInt(_countKey) ?? 0;
  int get _shownCount => _prefs.getInt(_shownCountKey) ?? 0;
  DateTime? get _lastAdTime {
    final millis = _prefs.getInt(_timeKey);
    return millis != null ? DateTime.fromMillisecondsSinceEpoch(millis) : null;
  }

  Future<void> onActionTriggered() async {
    final newCount = _actionCount + 1;
    await _prefs.setInt(_countKey, newCount);

    if (_policy.canShowInterstitial && newCount % 5 == 0) {
      await _tryShowAd();
    }
  }

  Future<void> _tryShowAd() async {
    final now = DateTime.now();
    final lastTime = _lastAdTime;

    if (lastTime != null && now.difference(lastTime).inMinutes < 10) return;

    final skipped = await _ref.read(adSkipProvider.notifier).useToken();
    if (skipped) {
      await _prefs.setInt(_timeKey, now.millisecondsSinceEpoch);
      return;
    }

    await AdService.showInterstitial();
    await _prefs.setInt(_timeKey, now.millisecondsSinceEpoch);
    await _trackAdAchievements();
  }

  Future<void> _trackAdAchievements() async {
    final nextCount = _shownCount + 1;
    await _prefs.setInt(_shownCountKey, nextCount);
    final achievement = _ref.read(achievementProvider.notifier);
    await achievement.track('first_ad', setAbsolute: 1);
    for (final id in const ['ads_1', 'ads_5', 'ads_15', 'ads_30', 'ads_50', 'ads_100', 'ads_250', 'ads_500']) {
      await achievement.track(id, setAbsolute: nextCount);
    }
  }

  Future<void> onAppOpen() async {
    if (!(_prefs.getBool(_onboardingKey) ?? false)) return;
    if (!_policy.canShowAppOpen) return;

    final now = DateTime.now();
    final firstOpenMillis = _prefs.getInt(_firstOpenKey);
    if (firstOpenMillis == null) {
      await _prefs.setInt(_firstOpenKey, now.millisecondsSinceEpoch);
      return;
    }

    final firstOpen = DateTime.fromMillisecondsSinceEpoch(firstOpenMillis);
    if (now.difference(firstOpen).inDays < 7) return;

    await AdService.showAppOpenAd();
  }
}
