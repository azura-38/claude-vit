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
  RewardedInterstitialAd? _rewardedInterstitialAd;
  RewardedAd? _rewardedAd;
  AppOpenAd? _appOpenAd;

  DateTime? lastInterstitialShown;
  DateTime? lastAppOpenShown;
  SharedPreferences? _prefs;
  Completer<void>? _initCompleter;
  Completer<RewardedAd?>? _rewardedLoadCompleter;

  static const _lastInterstitialKey = 'lastInterstitialShown';
  static const _lastAppOpenKey = 'lastAppOpenShown';

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
    if (!_adsAvailable || AppConfig.rewardedInterstitialAdId.isEmpty) return;
    _loadRewardedInterstitial();
  }

  void _loadRewardedInterstitial() {
    if (!_adsAvailable || AppConfig.rewardedInterstitialAdId.isEmpty) return;
    RewardedInterstitialAd.load(
      adUnitId: AppConfig.rewardedInterstitialAdId,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) => _rewardedInterstitialAd = ad,
        onAdFailedToLoad: (error) {
          debugPrint('[AdService] RewardedInterstitial failed to load: ${error.message}');
          _rewardedInterstitialAd = null;
        },
      ),
    );
  }

  Future<RewardedAd?> loadRewarded() {
    if (!_adsAvailable || AppConfig.rewardedAdId.isEmpty) return Future.value(null);
    if (_rewardedAd != null) return Future.value(_rewardedAd);
    if (_rewardedLoadCompleter != null) return _rewardedLoadCompleter!.future;

    _rewardedLoadCompleter = Completer<RewardedAd?>();

    RewardedAd.load(
      adUnitId: AppConfig.rewardedAdId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          final c = _rewardedLoadCompleter;
          _rewardedLoadCompleter = null;
          if (c != null && !c.isCompleted) c.complete(ad);
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          final c = _rewardedLoadCompleter;
          _rewardedLoadCompleter = null;
          if (c != null && !c.isCompleted) c.complete(null);
        },
      ),
    );

    return _rewardedLoadCompleter!.future;
  }

  void loadAppOpen() {
    if (!_adsAvailable || AppConfig.appOpenAdId.isEmpty) return;
    AppOpenAd.load(
      adUnitId: AppConfig.appOpenAdId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) => _appOpenAd = ad,
        onAdFailedToLoad: (error) {
          debugPrint('[AdService] AppOpen failed to load: ${error.message}');
          _appOpenAd = null;
        },
      ),
    );
  }

  static Future<bool> showAppOpenAd() async {
    final service = AdService();
    await service.init();
    if (!service._adsAvailable) return false;

    if (service._appOpenAd == null) {
      service.loadAppOpen();
      return false;
    }

    final completer = Completer<bool>();
    service._appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        AnalyticsService.log(AnalyticsService.appOpenAdShown);
      },
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        service._appOpenAd = null;
        service.loadAppOpen();
        if (!completer.isCompleted) completer.complete(true);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        service._appOpenAd = null;
        service.loadAppOpen();
        if (!completer.isCompleted) completer.complete(false);
      },
    );

    try {
      service._appOpenAd!.show();
      final shown = await completer.future;
      if (shown) {
        service.lastAppOpenShown = DateTime.now();
        await service._prefs?.setString(_lastAppOpenKey, service.lastAppOpenShown!.toIso8601String());
      }
      return shown;
    } catch (e) {
      debugPrint('[AdService] AppOpen show failed: $e');
      if (!completer.isCompleted) completer.complete(false);
      return false;
    }
  }

  Future<bool> _innerShowInterstitial() async {
    if (!_adsAvailable) return false;

    if (lastInterstitialShown != null) {
      final elapsed = DateTime.now().difference(lastInterstitialShown!);
      if (elapsed.inSeconds < 90) return false;
    }

    if (_rewardedInterstitialAd != null) {
      final completer = Completer<bool>();
      _rewardedInterstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          AnalyticsService.log(AnalyticsService.interstitialShown);
        },
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _rewardedInterstitialAd = null;
          _loadRewardedInterstitial();
          if (!completer.isCompleted) completer.complete(true);
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _rewardedInterstitialAd = null;
          _loadRewardedInterstitial();
          if (!completer.isCompleted) completer.complete(false);
        },
      );

      try {
        await _rewardedInterstitialAd!.show(
          onUserEarnedReward: (ad, reward) {
            debugPrint('[AdService] Rewarded interstitial reward: ${reward.amount} ${reward.type}');
          },
        );
        final shown = await completer.future;
        if (shown) {
          lastInterstitialShown = DateTime.now();
          _prefs?.setString(_lastInterstitialKey, lastInterstitialShown!.toIso8601String());
        }
        return shown;
      } catch (_) {
        if (!completer.isCompleted) completer.complete(false);
        return false;
      }
    }

    if (_interstitialAd != null) {
      final completer = Completer<bool>();
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          AnalyticsService.log(AnalyticsService.interstitialShown);
        },
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _interstitialAd = null;
          loadInterstitial();
          if (!completer.isCompleted) completer.complete(true);
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _interstitialAd = null;
          loadInterstitial();
          if (!completer.isCompleted) completer.complete(false);
        },
      );

      try {
        _interstitialAd!.show();
        final shown = await completer.future;
        if (shown) {
          lastInterstitialShown = DateTime.now();
          _prefs?.setString(_lastInterstitialKey, lastInterstitialShown!.toIso8601String());
        }
        return shown;
      } catch (_) {
        if (!completer.isCompleted) completer.complete(false);
        return false;
      }
    }

    loadInterstitial();
    return false;
  }

  static Future<RewardAdResult> showRewardedForResult() async {
    final service = AdService();
    await service.init();

    if (!service._adsAvailable) return RewardAdResult.unavailable;

    RewardedAd? ad = service._rewardedAd;
    if (ad == null) {
      try {
        ad = await service.loadRewarded().timeout(const Duration(seconds: 5));
      } catch (e) {
        debugPrint('[AdService] Timeout/error waiting for rewarded ad: $e');
      }
    }

    if (ad == null) {
      AnalyticsService.log(AnalyticsService.rewardAdUnavailable);
      service.loadRewarded();
      return RewardAdResult.unavailable;
    }

    final completer = Completer<RewardAdResult>();
    var rewardEarned = false;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (shownAd) {
        AnalyticsService.log(AnalyticsService.rewardAdShown);
      },
      onAdDismissedFullScreenContent: (shownAd) {
        shownAd.dispose();
        service._rewardedAd = null;
        service.loadRewarded();
        if (!completer.isCompleted) {
          completer.complete(rewardEarned ? RewardAdResult.shownRewarded : RewardAdResult.shownNoReward);
        }
      },
      onAdFailedToShowFullScreenContent: (shownAd, err) {
        shownAd.dispose();
        service._rewardedAd = null;
        service.loadRewarded();
        AnalyticsService.log(AnalyticsService.rewardAdFailed, {'code': err.code});
        if (!completer.isCompleted) completer.complete(RewardAdResult.failed);
      },
    );

    try {
      await ad.show(
        onUserEarnedReward: (shownAd, reward) {
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

  static Future<bool> showInterstitial() async {
    final service = AdService();
    await service.init();
    return service._innerShowInterstitial();
  }

  static Future<bool> showRewardedAd() async {
    final result = await showRewardedForResult();
    return result == RewardAdResult.shownRewarded;
  }
}
