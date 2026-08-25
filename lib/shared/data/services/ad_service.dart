import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/config/app_config.dart';
import '../../../core/types/runtime_types.dart';
import 'analytics_service.dart';

enum AdLoadStatus { idle, loading, loaded, failed }

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  BannerAd? _preloadedBannerAd;
  RewardedAd? _preloadedRewardedAd;
  AppOpenAd? _preloadedAppOpenAd;
  RewardedInterstitialAd? _rewardedInterstitialAd;

  AdLoadStatus bannerStatus = AdLoadStatus.idle;
  final ValueNotifier<AdLoadStatus> bannerStatusNotifier = ValueNotifier<AdLoadStatus>(AdLoadStatus.idle);
  AdLoadStatus rewardedStatus = AdLoadStatus.idle;
  AdLoadStatus appOpenStatus = AdLoadStatus.idle;

  int? bannerLoadTimeMs;
  int? rewardedLoadTimeMs;
  int? appOpenLoadTimeMs;

  String? lastBannerError;
  String? lastRewardedError;
  String? lastAppOpenError;

  bool _isBannerLoading = false;
  bool _isRewardedLoading = false;
  bool _isAppOpenLoading = false;

  int _bannerRetryCount = 0;
  int _rewardedRetryCount = 0;
  int _appOpenRetryCount = 0;

  DateTime? lastInterstitialShown;
  DateTime? lastAppOpenShown;
  SharedPreferences? _prefs;
  Completer<void>? _initCompleter;
  Completer<RewardedAd?>? _rewardedLoadCompleter;

  static const _lastInterstitialKey = 'lastInterstitialShown';
  static const _lastAppOpenKey = 'lastAppOpenShown';

  bool get _adsAvailable => !kIsWeb && AppConfig.hasAdConfig;

  Future<void> init() async {
    if (_initCompleter != null) return _initCompleter!.future;
    _initCompleter = Completer<void>();

    try {
      _prefs ??= await SharedPreferences.getInstance();
      final dateStr = _prefs!.getString(_lastInterstitialKey);
      if (dateStr != null) lastInterstitialShown = DateTime.tryParse(dateStr);

      final openDateStr = _prefs!.getString(_lastAppOpenKey);
      if (openDateStr != null) lastAppOpenShown = DateTime.tryParse(openDateStr);

      if (_adsAvailable) {
        await MobileAds.instance.initialize();
        preloadAll();
      }

      _initCompleter!.complete();
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[AdService] init failed: $e');
        debugPrintStack(stackTrace: st);
      }
      _initCompleter!.complete();
    }
  }

  void preloadAll() {
    preloadBannerAd();
    preloadRewardedAd();
    preloadAppOpenAd();
    loadInterstitial();
  }

  // ── BANNER PRELOAD & CLAIM ────────────────────────────────────────────────
  void preloadBannerAd() {
    if (!_adsAvailable || AppConfig.bannerAdId.isEmpty) return;
    if (_isBannerLoading || bannerStatus == AdLoadStatus.loaded) return;

    _isBannerLoading = true;
    bannerStatus = AdLoadStatus.loading;
    bannerStatusNotifier.value = AdLoadStatus.loading;
    final stopwatch = Stopwatch()..start();

    final ad = BannerAd(
      adUnitId: AppConfig.bannerAdId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          stopwatch.stop();
          bannerLoadTimeMs = stopwatch.elapsedMilliseconds;
          bannerStatus = AdLoadStatus.loaded;
          bannerStatusNotifier.value = AdLoadStatus.loaded;
          lastBannerError = null;
          _isBannerLoading = false;
          _bannerRetryCount = 0;
          _preloadedBannerAd = ad as BannerAd;
          if (kDebugMode) {
            debugPrint('[AdService] Banner loaded in ${bannerLoadTimeMs}ms ✅');
          }
        },
        onAdFailedToLoad: (ad, error) {
          stopwatch.stop();
          ad.dispose();
          _preloadedBannerAd = null;
          _isBannerLoading = false;
          bannerStatus = AdLoadStatus.failed;
          bannerStatusNotifier.value = AdLoadStatus.failed;
          lastBannerError = '${error.code}: ${error.message}';
          if (kDebugMode) {
            debugPrint('[AdService] Banner load failed after ${stopwatch.elapsedMilliseconds}ms: $lastBannerError');
          }

          if (_bannerRetryCount < 5) {
            _bannerRetryCount++;
            final delaySeconds = (1 << _bannerRetryCount).clamp(2, 10);
            Future.delayed(Duration(seconds: delaySeconds), () {
              preloadBannerAd();
            });
          }
        },
      ),
    );

    ad.load();
  }

  BannerAd? claimPreloadedBanner() {
    if (_preloadedBannerAd != null && bannerStatus == AdLoadStatus.loaded) {
      final claimedAd = _preloadedBannerAd;
      _preloadedBannerAd = null;
      bannerStatus = AdLoadStatus.idle;
      bannerStatusNotifier.value = AdLoadStatus.idle;
      Future.microtask(() => preloadBannerAd());
      return claimedAd;
    }
    return null;
  }

  // ── REWARDED PRELOAD & SHOW ──────────────────────────────────────────────
  Future<RewardedAd?> preloadRewardedAd() {
    if (!_adsAvailable || AppConfig.rewardedAdId.isEmpty) return Future.value(null);
    if (_preloadedRewardedAd != null && rewardedStatus == AdLoadStatus.loaded) {
      return Future.value(_preloadedRewardedAd);
    }
    if (_isRewardedLoading) {
      if (_rewardedLoadCompleter != null) return _rewardedLoadCompleter!.future;
    }

    _isRewardedLoading = true;
    rewardedStatus = AdLoadStatus.loading;
    _rewardedLoadCompleter = Completer<RewardedAd?>();
    final stopwatch = Stopwatch()..start();

    RewardedAd.load(
      adUnitId: AppConfig.rewardedAdId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          stopwatch.stop();
          rewardedLoadTimeMs = stopwatch.elapsedMilliseconds;
          rewardedStatus = AdLoadStatus.loaded;
          lastRewardedError = null;
          _isRewardedLoading = false;
          _rewardedRetryCount = 0;
          _preloadedRewardedAd = ad;
          if (kDebugMode) {
            debugPrint('[AdService] Rewarded loaded in ${rewardedLoadTimeMs}ms ✅');
          }
          if (_rewardedLoadCompleter != null && !_rewardedLoadCompleter!.isCompleted) {
            _rewardedLoadCompleter!.complete(ad);
          }
        },
        onAdFailedToLoad: (error) {
          stopwatch.stop();
          _preloadedRewardedAd = null;
          _isRewardedLoading = false;
          rewardedStatus = AdLoadStatus.failed;
          lastRewardedError = '${error.code}: ${error.message}';
          if (kDebugMode) {
            debugPrint('[AdService] Rewarded load failed after ${stopwatch.elapsedMilliseconds}ms: $lastRewardedError');
          }
          if (_rewardedLoadCompleter != null && !_rewardedLoadCompleter!.isCompleted) {
            _rewardedLoadCompleter!.complete(null);
          }

          if (_rewardedRetryCount < 5) {
            _rewardedRetryCount++;
            final delaySeconds = (1 << _rewardedRetryCount).clamp(2, 10);
            Future.delayed(Duration(seconds: delaySeconds), () {
              preloadRewardedAd();
            });
          }
        },
      ),
    );

    return _rewardedLoadCompleter!.future;
  }

  // ── APP OPEN AD ──────────────────────────────────────────────────────────
  void preloadAppOpenAd() {
    if (!_adsAvailable || AppConfig.appOpenAdId.isEmpty) return;
    if (_isAppOpenLoading || appOpenStatus == AdLoadStatus.loaded) return;

    _isAppOpenLoading = true;
    appOpenStatus = AdLoadStatus.loading;
    final stopwatch = Stopwatch()..start();

    AppOpenAd.load(
      adUnitId: AppConfig.appOpenAdId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          stopwatch.stop();
          appOpenLoadTimeMs = stopwatch.elapsedMilliseconds;
          appOpenStatus = AdLoadStatus.loaded;
          lastAppOpenError = null;
          _isAppOpenLoading = false;
          _appOpenRetryCount = 0;
          _preloadedAppOpenAd = ad;
          if (kDebugMode) {
            debugPrint('[AdService] AppOpen loaded in ${appOpenLoadTimeMs}ms ✅');
          }
        },
        onAdFailedToLoad: (error) {
          stopwatch.stop();
          _preloadedAppOpenAd = null;
          _isAppOpenLoading = false;
          appOpenStatus = AdLoadStatus.failed;
          lastAppOpenError = '${error.code}: ${error.message}';
          if (kDebugMode) {
            debugPrint('[AdService] AppOpen load failed after ${stopwatch.elapsedMilliseconds}ms: $lastAppOpenError');
          }

          if (_appOpenRetryCount < 5) {
            _appOpenRetryCount++;
            final delaySeconds = (1 << _appOpenRetryCount).clamp(2, 10);
            Future.delayed(Duration(seconds: delaySeconds), () {
              preloadAppOpenAd();
            });
          }
        },
      ),
    );
  }

  void loadAppOpen() => preloadAppOpenAd();

  static Future<bool> showAppOpenAd() async {
    final service = AdService();
    await service.init();
    if (!service._adsAvailable) return false;

    if (service._preloadedAppOpenAd == null) {
      service.preloadAppOpenAd();
      return false;
    }

    final completer = Completer<bool>();
    final adToShow = service._preloadedAppOpenAd!;
    service._preloadedAppOpenAd = null;
    service.appOpenStatus = AdLoadStatus.idle;

    adToShow.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        AnalyticsService.log(AnalyticsService.appOpenAdShown);
      },
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        service.preloadAppOpenAd();
        if (!completer.isCompleted) completer.complete(true);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        service.preloadAppOpenAd();
        if (!completer.isCompleted) completer.complete(false);
      },
    );

    try {
      adToShow.show();
      final shown = await completer.future;
      if (shown) {
        service.lastAppOpenShown = DateTime.now();
        await service._prefs?.setString(_lastAppOpenKey, service.lastAppOpenShown!.toIso8601String());
      }
      return shown;
    } catch (e) {
      if (kDebugMode) debugPrint('[AdService] AppOpen show failed: $e');
      if (!completer.isCompleted) completer.complete(false);
      return false;
    }
  }

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
          if (kDebugMode) debugPrint('[AdService] RewardedInterstitial failed to load: ${error.message}');
          _rewardedInterstitialAd = null;
        },
      ),
    );
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
            if (kDebugMode) debugPrint('[AdService] Rewarded interstitial reward: ${reward.amount} ${reward.type}');
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

    loadInterstitial();
    return false;
  }

  static Future<RewardAdResult> showRewardedForResult() async {
    final service = AdService();
    await service.init();

    if (!service._adsAvailable) return RewardAdResult.unavailable;

    RewardedAd? ad = service._preloadedRewardedAd;
    if (ad == null) {
      try {
        ad = await service.preloadRewardedAd().timeout(const Duration(seconds: 5));
      } catch (e) {
        if (kDebugMode) debugPrint('[AdService] Timeout/error waiting for rewarded ad: $e');
      }
    }

    if (ad == null) {
      AnalyticsService.log(AnalyticsService.rewardAdUnavailable);
      service.preloadRewardedAd();
      return RewardAdResult.unavailable;
    }

    service._preloadedRewardedAd = null;
    service.rewardedStatus = AdLoadStatus.idle;

    final completer = Completer<RewardAdResult>();
    var rewardEarned = false;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (shownAd) {
        AnalyticsService.log(AnalyticsService.rewardAdShown);
      },
      onAdDismissedFullScreenContent: (shownAd) {
        shownAd.dispose();
        service.preloadRewardedAd();
        if (!completer.isCompleted) {
          completer.complete(rewardEarned ? RewardAdResult.shownRewarded : RewardAdResult.shownNoReward);
        }
      },
      onAdFailedToShowFullScreenContent: (shownAd, err) {
        shownAd.dispose();
        service.preloadRewardedAd();
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
