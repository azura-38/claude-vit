import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/config/app_config.dart';
import '../../../core/types/runtime_types.dart';
import 'analytics_service.dart';

class AdService {
  // Singleton Pattern
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  AppOpenAd? _appOpenAd;

  DateTime? lastInterstitialShown;
  DateTime? lastAppOpenShown;
  SharedPreferences? _prefs;
  final Completer<void> _initCompleter = Completer<void>();

  /// INIT
  Future<void> init() async {
    if (_initCompleter.isCompleted) return;
    
    _prefs = await SharedPreferences.getInstance();
    final dateStr = _prefs!.getString('lastInterstitialShown');
    if (dateStr != null) {
      lastInterstitialShown = DateTime.tryParse(dateStr);
    }
    final openDateStr = _prefs!.getString('lastAppOpenShown');
    if (openDateStr != null) {
      lastAppOpenShown = DateTime.tryParse(openDateStr);
    }
    
    _initCompleter.complete();

    if (!AppConfig.hasAdConfig) {
      return;
    }
    await MobileAds.instance.initialize();
    loadBanner();
    loadInterstitial();
    loadRewarded();
    loadAppOpen();
  }

  /// BANNER
  void loadBanner() {
    if (!AppConfig.hasAdConfig) return;
    BannerAd(
      adUnitId: AppConfig.bannerAdId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(),
    ).load();
  }

  /// INTERSTITIAL
  void loadInterstitial() {
    if (!AppConfig.hasAdConfig || AppConfig.interstitialAdId.isEmpty) return;
    InterstitialAd.load(
      adUnitId: AppConfig.interstitialAdId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
        },
      ),
    );
  }

  /// REWARDED (Hafıza limit artırımı için)
  void loadRewarded() {
    if (!AppConfig.hasAdConfig) return;
    RewardedAd.load(
      adUnitId: AppConfig.rewardedAdId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
        },
      ),
    );
  }

  /// APP OPEN
  void loadAppOpen() {
    if (!AppConfig.hasAdConfig || AppConfig.appOpenAdId.isEmpty) return;
    AppOpenAd.load(
      adUnitId: AppConfig.appOpenAdId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
        },
        onAdFailedToLoad: (error) {
          _appOpenAd = null;
        },
      ),
    );
  }

  /// SHOW APP OPEN
  static void showAppOpenAd() {
    final service = AdService();
    
    // NEW: 1-hour Cooldown
    if (service.lastAppOpenShown != null) {
      final elapsed = DateTime.now().difference(service.lastAppOpenShown!);
      if (elapsed.inHours < 1) return;
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
    if (service._prefs != null) {
      service._prefs!.setString('lastAppOpenShown', service.lastAppOpenShown!.toIso8601String());
    }
  }

  /// SHOW INTERSTITIAL
  void _innerShowInterstitial() {
    // Check for ad-skip tokens first
    final tokens = _prefs?.getInt('ad_skip_tokens') ?? 0;
    if (tokens > 0) {
      _prefs?.setInt('ad_skip_tokens', tokens - 1);
      AnalyticsService.log('ad_skip_token_used');
      return;
    }
    
    // NEW: 90s Minimum Cooldown
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
    _prefs?.setString('lastInterstitialShown', lastInterstitialShown!.toIso8601String());
  }

  static Future<RewardAdResult> showRewardedForResult() async {
    final service = AdService();
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
          completer.complete(
            rewardEarned
                ? RewardAdResult.shownRewarded
                : RewardAdResult.shownNoReward,
          );
        }
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        ad.dispose();
        service._rewardedAd = null;
        service.loadRewarded();
        AnalyticsService.log(AnalyticsService.rewardAdFailed, {
          'code': err.code,
        });
        if (!completer.isCompleted) {
          completer.complete(RewardAdResult.failed);
        }
      },
    );

    try {
      await service._rewardedAd!.show(onUserEarnedReward: (ad, reward) {
        rewardEarned = true;
        AnalyticsService.log(AnalyticsService.rewardAdRewarded, {
          'amount': reward.amount,
          'type': reward.type,
        });
      });
      return completer.future;
    } catch (_) {
      if (!completer.isCompleted) {
        completer.complete(RewardAdResult.failed);
      }
      AnalyticsService.log(AnalyticsService.rewardAdFailed);
      return RewardAdResult.failed;
    }
  }

  static void showInterstitial() {
    AdService()._innerShowInterstitial();
  }

  static Future<bool> showRewardedAd() async {
    final result = await showRewardedForResult();
    return result == RewardAdResult.shownRewarded;
  }
}
