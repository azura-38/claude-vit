import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/config/app_config.dart';
import '../../../core/types/runtime_types.dart';
import 'analytics_service.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  AppOpenAd? _appOpenAd;

  DateTime? lastInterstitialShown;
  DateTime? lastAppOpenShown;
  SharedPreferences? _prefs;
  Completer<void>? _initCompleter;

  static const _lastInterstitialKey = 'lastInterstitialShown';
  static const _lastAppOpenKey = 'lastAppOpenShown';
  static const _appOpenDayKey = 'app_open_ad_day';
  static const _appOpenCountKey = 'app_open_ad_count';
  static const int maxAppOpenAdsPerDay = 2;

  Future<void> init() async {
    if (_initCompleter != null) return _initCompleter!.future;
    _initCompleter = Completer<void>();

    try {
      _prefs = await SharedPreferences.getInstance();
      final dateStr = _prefs!.getString(_lastInterstitialKey);
      if (dateStr != null) lastInterstitialShown = DateTime.tryParse(dateStr);

      final openDateStr = _prefs!.getString(_lastAppOpenKey);
      if (openDateStr != null) lastAppOpenShown = DateTime.tryParse(openDateStr);

      if (!kIsWeb && AppConfig.hasAdConfig) {
        await MobileAds.instance.initialize();
        loadInterstitial();
        loadRewarded();
        loadAppOpen();
      }

      _initCompleter!.complete();
    } catch (e, st) {
      debugPrint('[AdService] init failed: $e');
      debugPrintStack(stackTrace: st);
      _initCompleter!.complete();
    }
  }

  bool get _adsAvailable => !kIsWeb && AppConfig.hasAdConfig;

  void loadInterstitial() {
    if (!_adsAvailable || AppConfig.interstitialAdId.isEmpty) return;
    InterstitialAd.load(
      adUnitId: AppConfig.interstitialAdId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (error) => _interstitialAd = null,
      ),
    );
  }

  void loadRewarded() {
    if (!_adsAvailable || AppConfig.rewardedAdId.isEmpty) return;
    RewardedAd.load(
      adUnitId: AppConfig.rewardedAdId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _rewardedAd = ad,
        onAdFailedToLoad: (error) => _rewardedAd = null,
      ),
    );
  }

  void loadAppOpen() {
    if (!_adsAvailable || AppConfig.appOpenAdId.isEmpty) return;
    AppOpenAd.load(
      adUnitId: AppConfig.appOpenAdId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) => _appOpenAd = ad,
        onAdFailedToLoad: (error) => _appOpenAd = null,
      ),
    );
  }

  int _todayKey() {
    final now = DateTime.now();
    return int.parse('${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}');
  }

  int _todayAppOpenCount() {
    final prefs = _prefs;
    if (prefs == null) return 0;
    final today = _todayKey();
    final storedDay = prefs.getInt(_appOpenDayKey);
    if (storedDay != today) {
      prefs.setInt(_appOpenDayKey, today);
      prefs.setInt(_appOpenCountKey, 0);
      return 0;
    }
    return prefs.getInt(_appOpenCountKey) ?? 0;
  }

  Future<void> _incrementTodayAppOpenCount() async {
    final prefs = _prefs;
    if (prefs == null) return;
    final today = _todayKey();
    final count = _todayAppOpenCount() + 1;
    await prefs.setInt(_appOpenDayKey, today);
    await prefs.setInt(_appOpenCountKey, count);
  }

  static Future<void> showAppOpenAd() async {
    final service = AdService();
    await service.init();
    if (!service._adsAvailable) return;

    if (service._todayAppOpenCount() >= maxAppOpenAdsPerDay) return;

    if (service.lastAppOpenShown != null) {
      final elapsed = DateTime.now().difference(service.lastAppOpenShown!);
      if (elapsed.inHours < 6) return;
    }

    if (service._appOpenAd == null) {
      service.loadAppOpen();
      return;
    }

    service._appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        service._appOpenAd = null;
        service.loadAppOpen();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        service._appOpenAd = null;
        service.loadAppOpen();
      },
    );

    service._appOpenAd!.show();
    AnalyticsService.log(AnalyticsService.appOpenAdShown);
    service.lastAppOpenShown = DateTime.now();
    await service._prefs?.setString(_lastAppOpenKey, service.lastAppOpenShown!.toIso8601String());
    await service._incrementTodayAppOpenCount();
  }

  void _innerShowInterstitial() {
    if (!_adsAvailable) return;

    if (lastInterstitialShown != null) {
      final elapsed = DateTime.now().difference(lastInterstitialShown!);
      if (elapsed.inSeconds < 90) return;
    }

    if (_interstitialAd == null) {
      loadInterstitial();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        loadInterstitial();
      },
    );

    _interstitialAd!.show();
    AnalyticsService.log(AnalyticsService.interstitialShown);
    lastInterstitialShown = DateTime.now();
    _prefs?.setString(_lastInterstitialKey, lastInterstitialShown!.toIso8601String());
  }

  static Future<RewardAdResult> showRewardedForResult() async {
    final service = AdService();
    await service.init();

    if (!service._adsAvailable) return RewardAdResult.unavailable;
    if (service._rewardedAd == null) {
      AnalyticsService.log(AnalyticsService.rewardAdUnavailable);
      service.loadRewarded();
      return RewardAdResult.unavailable;
    }

    final completer = Completer<RewardAdResult>();
    var rewardEarned = false;
    service._rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        AnalyticsService.log(AnalyticsService.rewardAdShown);
      },
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        service._rewardedAd = null;
        service.loadRewarded();
        if (!completer.isCompleted) {
          completer.complete(rewardEarned ? RewardAdResult.shownRewarded : RewardAdResult.shownNoReward);
        }
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        ad.dispose();
        service._rewardedAd = null;
        service.loadRewarded();
        AnalyticsService.log(AnalyticsService.rewardAdFailed, {'code': err.code});
        if (!completer.isCompleted) completer.complete(RewardAdResult.failed);
      },
    );

    try {
      await service._rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          rewardEarned = true;
          AnalyticsService.log(AnalyticsService.rewardAdRewarded, {
            'amount': reward.amount,
            'type': reward.type,
          });
        },
      );
      return completer.future;
    } catch (_) {
      if (!completer.isCompleted) completer.complete(RewardAdResult.failed);
      AnalyticsService.log(AnalyticsService.rewardAdFailed);
      return RewardAdResult.failed;
    }
  }

  static Future<void> showInterstitial() async {
    final service = AdService();
    await service.init();
    service._innerShowInterstitial();
  }

  static Future<bool> showRewardedAd() async {
    final result = await showRewardedForResult();
    return result == RewardAdResult.shownRewarded;
  }
}
