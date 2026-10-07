import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/config/app_config.dart';
import '../../../core/constants/legal_version.dart';
import '../../../core/types/runtime_types.dart';
import 'analytics_service.dart';
import 'consent_service.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  InterstitialAdHandle? _interstitialHandle;
  Completer<InterstitialAdHandle?>? _interstitialLoadCompleter;
  InterstitialAdDelegate _interstitialDelegate = DefaultInterstitialAdDelegate();
  bool _isShowingInterstitial = false;
  bool _isLoadingInterstitial = false;
  InterstitialAdState _interstitialState = InterstitialAdState.idle;

  RewardedAdHandle? _rewardedHandle;
  Completer<RewardedAdHandle?>? _rewardedLoadCompleter;
  RewardedAdDelegate _rewardedDelegate = DefaultRewardedAdDelegate();
  bool _isShowingRewarded = false;
  bool _isLoadingRewarded = false;
  RewardedAdState _rewardedState = RewardedAdState.idle;

  AppOpenAdHandle? _appOpenHandle;
  Completer<AppOpenAdHandle?>? _appOpenLoadCompleter;
  AppOpenAdDelegate _appOpenDelegate = DefaultAppOpenAdDelegate();
  bool _isShowingAppOpen = false;
  bool _isLoadingAppOpen = false;
  AppOpenAdState _appOpenState = AppOpenAdState.idle;

  DateTime? lastInterstitialShown;
  DateTime? lastAppOpenShown;
  SharedPreferences? _prefs;
  Completer<void>? _initCompleter;

  static InterstitialAdState get interstitialState => _instance._interstitialState;
  static bool get isInterstitialAdAvailable => _instance._interstitialHandle != null;
  static bool get isInterstitialAdShowing => _instance._isShowingInterstitial;
  static bool get isInterstitialAdLoading => _instance._isLoadingInterstitial;

  static RewardedAdState get rewardedState => _instance._rewardedState;
  static bool get isRewardedAdAvailable => _instance._rewardedHandle != null;
  static bool get isRewardedAdShowing => _instance._isShowingRewarded;
  static bool get isRewardedAdLoading => _instance._isLoadingRewarded;

  static AppOpenAdState get appOpenState => _instance._appOpenState;
  static bool get isAppOpenAdAvailable => _instance._appOpenHandle != null;
  static bool get isAppOpenAdShowing => _instance._isShowingAppOpen;
  static bool get isAppOpenAdLoading => _instance._isLoadingAppOpen;

  static bool get isAnyFullscreenAdShowing =>
      _instance._isShowingRewarded ||
      _instance._isShowingInterstitial ||
      _instance._isShowingAppOpen;

  @visibleForTesting
  static void setInterstitialDelegateForTesting(InterstitialAdDelegate delegate) {
    _instance._interstitialDelegate = delegate;
  }

  @visibleForTesting
  static void setRewardedDelegateForTesting(RewardedAdDelegate delegate) {
    _instance._rewardedDelegate = delegate;
  }

  @visibleForTesting
  static void setAppOpenDelegateForTesting(AppOpenAdDelegate delegate) {
    _instance._appOpenDelegate = delegate;
  }

  @visibleForTesting
  static void resetForTesting() {
    _instance._rewardedHandle?.dispose();
    _instance._rewardedHandle = null;
    _instance._rewardedLoadCompleter = null;
    _instance._isShowingRewarded = false;
    _instance._isLoadingRewarded = false;
    _instance._rewardedState = RewardedAdState.idle;
    _instance._rewardedDelegate = DefaultRewardedAdDelegate();

    _instance._interstitialHandle?.dispose();
    _instance._interstitialHandle = null;
    _instance._interstitialLoadCompleter = null;
    _instance._isShowingInterstitial = false;
    _instance._isLoadingInterstitial = false;
    _instance._interstitialState = InterstitialAdState.idle;
    _instance._interstitialDelegate = DefaultInterstitialAdDelegate();
    _instance.lastInterstitialShown = null;

    _instance._appOpenHandle?.dispose();
    _instance._appOpenHandle = null;
    _instance._appOpenLoadCompleter = null;
    _instance._isShowingAppOpen = false;
    _instance._isLoadingAppOpen = false;
    _instance._appOpenState = AppOpenAdState.idle;
    _instance._appOpenDelegate = DefaultAppOpenAdDelegate();
    _instance.lastAppOpenShown = null;

    legalAcceptedOverrideForTesting = null;
    ConsentService.canRequestAdsOverrideForTesting = null;
    _instance._initCompleter = null;
    _instance._prefs = null;
  }

  @visibleForTesting
  static bool? legalAcceptedOverrideForTesting;

  bool get _isLegalAccepted {
    if (legalAcceptedOverrideForTesting != null) {
      return legalAcceptedOverrideForTesting!;
    }
    if (_prefs == null) return false;
    if (_prefs!.containsKey('legal_accepted')) {
      final accepted = _prefs!.getBool('legal_accepted') ?? false;
      final version = _prefs!.getString('legal_accepted_version') ?? '';
      return accepted && version == LegalVersion.current;
    }
    return !kReleaseMode;
  }

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
        try {
          await MobileAds.instance.initialize();
          // NOTE (Phase 12, 13 & 14): Fullscreen ads (Rewarded, Interstitial, App Open)
          // are NOT loaded prematurely on startup. They are loaded strictly on demand.
        } catch (e) {
          debugPrint('[AdService] MobileAds initialize skipped in test/env: $e');
        }
      }

      _initCompleter!.complete();
    } catch (e) {
      debugPrint('[AdService] init failed: $e');
      _initCompleter!.complete();
    }
  }

  bool get _adsAvailable => !kIsWeb && AppConfig.hasAdConfig;

  Future<InterstitialAdHandle?> loadInterstitial() async {
    if (!_adsAvailable || AppConfig.interstitialAdId.isEmpty) {
      _interstitialState = InterstitialAdState.idle;
      return null;
    }

    // UMP Consent Check: Ad requests cannot be sent before UMP consent is verified.
    // In unit tests with mock delegates, bypass unless explicitly overridden.
    final isMockDelegate = _interstitialDelegate is! DefaultInterstitialAdDelegate;
    final canRequest = isMockDelegate
        ? (ConsentService.canRequestAdsOverrideForTesting ?? true)
        : await ConsentService.canRequestAds();

    if (!canRequest) {
      debugPrint('[AdService] Interstitial ad request suppressed: UMP consent not granted.');
      _interstitialState = InterstitialAdState.idle;
      return null;
    }

    if (_interstitialHandle != null) {
      _interstitialState = InterstitialAdState.loaded;
      return _interstitialHandle;
    }
    if (_interstitialLoadCompleter != null) {
      return _interstitialLoadCompleter!.future;
    }

    _isLoadingInterstitial = true;
    _interstitialState = InterstitialAdState.loading;
    _interstitialLoadCompleter = Completer<InterstitialAdHandle?>();

    try {
      final handle = await _interstitialDelegate.loadInterstitial(AppConfig.interstitialAdId);
      _interstitialHandle = handle;
      _interstitialState = handle != null ? InterstitialAdState.loaded : InterstitialAdState.failed;
      final c = _interstitialLoadCompleter;
      _interstitialLoadCompleter = null;
      _isLoadingInterstitial = false;
      if (c != null && !c.isCompleted) c.complete(handle);
      return handle;
    } catch (e) {
      debugPrint('[AdService] Error loading interstitial ad: $e');
      _interstitialHandle = null;
      _interstitialState = InterstitialAdState.failed;
      final c = _interstitialLoadCompleter;
      _interstitialLoadCompleter = null;
      _isLoadingInterstitial = false;
      if (c != null && !c.isCompleted) c.complete(null);
      return null;
    }
  }

  static Future<InterstitialAdHandle?> loadInterstitialAd() => _instance.loadInterstitial();

  Future<RewardedAdHandle?> loadRewarded() async {
    if (!_adsAvailable || AppConfig.rewardedAdId.isEmpty) {
      _rewardedState = RewardedAdState.idle;
      return null;
    }

    // UMP Consent Check: Ad requests cannot be sent before UMP consent is verified.
    final isMockDelegate = _rewardedDelegate is! DefaultRewardedAdDelegate;
    final canRequest = isMockDelegate
        ? (ConsentService.canRequestAdsOverrideForTesting ?? true)
        : await ConsentService.canRequestAds();

    if (!canRequest) {
      debugPrint('[AdService] Rewarded ad request suppressed: UMP consent not granted.');
      _rewardedState = RewardedAdState.idle;
      return null;
    }

    if (_rewardedHandle != null) {
      _rewardedState = RewardedAdState.loaded;
      return _rewardedHandle;
    }
    if (_rewardedLoadCompleter != null) {
      return _rewardedLoadCompleter!.future;
    }

    _isLoadingRewarded = true;
    _rewardedState = RewardedAdState.loading;
    _rewardedLoadCompleter = Completer<RewardedAdHandle?>();

    try {
      final handle = await _rewardedDelegate.loadRewarded(AppConfig.rewardedAdId);
      _rewardedHandle = handle;
      _rewardedState = handle != null ? RewardedAdState.loaded : RewardedAdState.failed;
      final c = _rewardedLoadCompleter;
      _rewardedLoadCompleter = null;
      _isLoadingRewarded = false;
      if (c != null && !c.isCompleted) c.complete(handle);
      return handle;
    } catch (e) {
      debugPrint('[AdService] Error loading rewarded ad: $e');
      _rewardedHandle = null;
      _rewardedState = RewardedAdState.failed;
      final c = _rewardedLoadCompleter;
      _rewardedLoadCompleter = null;
      _isLoadingRewarded = false;
      if (c != null && !c.isCompleted) c.complete(null);
      return null;
    }
  }

  Future<AppOpenAdHandle?> loadAppOpen() async {
    if (!_adsAvailable || AppConfig.appOpenAdId.isEmpty) {
      _appOpenState = AppOpenAdState.idle;
      return null;
    }

    // UMP Consent Check: Ad requests cannot be sent before UMP consent is verified.
    final isMockDelegate = _appOpenDelegate is! DefaultAppOpenAdDelegate;
    final canRequest = isMockDelegate
        ? (ConsentService.canRequestAdsOverrideForTesting ?? true)
        : await ConsentService.canRequestAds();

    if (!canRequest) {
      debugPrint('[AdService] AppOpen ad request suppressed: UMP consent not granted.');
      _appOpenState = AppOpenAdState.idle;
      return null;
    }

    if (_appOpenHandle != null) {
      _appOpenState = AppOpenAdState.loaded;
      return _appOpenHandle;
    }
    if (_appOpenLoadCompleter != null) {
      return _appOpenLoadCompleter!.future;
    }

    _isLoadingAppOpen = true;
    _appOpenState = AppOpenAdState.loading;
    _appOpenLoadCompleter = Completer<AppOpenAdHandle?>();

    try {
      final handle = await _appOpenDelegate.loadAppOpen(AppConfig.appOpenAdId);
      _appOpenHandle = handle;
      _appOpenState = handle != null ? AppOpenAdState.loaded : AppOpenAdState.failed;
      final c = _appOpenLoadCompleter;
      _appOpenLoadCompleter = null;
      _isLoadingAppOpen = false;
      if (c != null && !c.isCompleted) c.complete(handle);
      return handle;
    } catch (e) {
      debugPrint('[AdService] Error loading AppOpen ad: $e');
      _appOpenHandle = null;
      _appOpenState = AppOpenAdState.failed;
      final c = _appOpenLoadCompleter;
      _appOpenLoadCompleter = null;
      _isLoadingAppOpen = false;
      if (c != null && !c.isCompleted) c.complete(null);
      return null;
    }
  }

  static Future<AppOpenAdHandle?> loadAppOpenAd() => _instance.loadAppOpen();

  Future<bool> _innerShowAppOpen({bool ignoreCooldown = false}) async {
    if (!_adsAvailable || !_isLegalAccepted) return false;

    // Fullscreen ad mutual exclusion & duplicate show protection
    if (_isShowingAppOpen || _isShowingRewarded || _isShowingInterstitial) {
      debugPrint('[AdService] Fullscreen ad already in progress. Ignoring App Open trigger.');
      return false;
    }

    // Cooldown check (300 seconds / 5 minutes minimum between App Open ads)
    if (!ignoreCooldown && lastAppOpenShown != null) {
      final elapsed = DateTime.now().difference(lastAppOpenShown!);
      if (elapsed.inSeconds < 300) {
        debugPrint('[AdService] AppOpen cooldown active (${elapsed.inSeconds}s < 300s). Skipping.');
        return false;
      }
    }

    _isShowingAppOpen = true;

    try {
      AppOpenAdHandle? handle = _appOpenHandle;
      if (handle == null) {
        try {
          handle = await loadAppOpen().timeout(const Duration(seconds: 10));
        } catch (e) {
          debugPrint('[AdService] Timeout/error waiting for AppOpen ad: $e');
        }
      }

      if (handle == null) {
        _appOpenState = AppOpenAdState.failed;
        _isShowingAppOpen = false;
        return false;
      }

      final completer = Completer<bool>();
      _appOpenState = AppOpenAdState.showing;

      // Invalidate service reference immediately so the exact same instance cannot be shown twice
      _appOpenHandle = null;

      await handle.show(
        onAdShowed: () {
          // App Open showed full screen
        },
        onAdDismissed: () {
          handle?.dispose();
          _isShowingAppOpen = false;
          _appOpenState = AppOpenAdState.dismissed;
          lastAppOpenShown = DateTime.now();
          _prefs?.setString(_lastAppOpenKey, lastAppOpenShown!.toIso8601String());
          if (!completer.isCompleted) completer.complete(true);
        },
        onAdFailedToShow: (err) {
          handle?.dispose();
          _isShowingAppOpen = false;
          _appOpenState = AppOpenAdState.failed;
          debugPrint('[AdService] AppOpen show failed: $err');
          if (!completer.isCompleted) completer.complete(false);
        },
      );

      return await completer.future;
    } catch (e) {
      debugPrint('[AdService] Error presenting AppOpen ad: $e');
      _isShowingAppOpen = false;
      _appOpenState = AppOpenAdState.failed;
      return false;
    } finally {
      _isShowingAppOpen = false;
    }
  }

  static Future<bool> showAppOpenAd({bool ignoreCooldown = false}) async {
    final service = AdService();
    await service.init();
    return service._innerShowAppOpen(ignoreCooldown: ignoreCooldown);
  }

  Future<bool> _innerShowInterstitial({bool ignoreCooldown = false}) async {
    if (!_adsAvailable || !_isLegalAccepted) return false;

    // Fullscreen ad mutual exclusion & duplicate show protection
    if (_isShowingInterstitial || _isShowingRewarded || _isShowingAppOpen) {
      debugPrint('[AdService] Fullscreen ad presentation already in progress. Ignoring Interstitial trigger.');
      return false;
    }

    // Cooldown check (90 seconds standard cooldown between interstitials)
    if (!ignoreCooldown && lastInterstitialShown != null) {
      final elapsed = DateTime.now().difference(lastInterstitialShown!);
      if (elapsed.inSeconds < 90) {
        debugPrint('[AdService] Interstitial cooldown active (${elapsed.inSeconds}s < 90s). Skipping.');
        return false;
      }
    }

    _isShowingInterstitial = true;

    try {
      InterstitialAdHandle? handle = _interstitialHandle;
      if (handle == null) {
        try {
          handle = await loadInterstitial().timeout(const Duration(seconds: 10));
        } catch (e) {
          debugPrint('[AdService] Timeout/error waiting for interstitial ad: $e');
        }
      }

      if (handle == null) {
        _interstitialState = InterstitialAdState.failed;
        _isShowingInterstitial = false;
        return false;
      }

      final completer = Completer<bool>();
      _interstitialState = InterstitialAdState.showing;

      // Invalidate service reference immediately so the exact same instance cannot be shown twice
      _interstitialHandle = null;

      await handle.show(
        onAdShowed: () {
          // Ad showed full screen
        },
        onAdDismissed: () {
          handle?.dispose();
          _isShowingInterstitial = false;
          _interstitialState = InterstitialAdState.dismissed;
          lastInterstitialShown = DateTime.now();
          _prefs?.setString(_lastInterstitialKey, lastInterstitialShown!.toIso8601String());
          if (!completer.isCompleted) completer.complete(true);
        },
        onAdFailedToShow: (err) {
          handle?.dispose();
          _isShowingInterstitial = false;
          _interstitialState = InterstitialAdState.failed;
          debugPrint('[AdService] Interstitial show failed: $err');
          if (!completer.isCompleted) completer.complete(false);
        },
      );

      return await completer.future;
    } catch (e) {
      debugPrint('[AdService] Error presenting interstitial ad: $e');
      _isShowingInterstitial = false;
      _interstitialState = InterstitialAdState.failed;
      return false;
    } finally {
      _isShowingInterstitial = false;
    }
  }

  static Future<RewardAdResult> showRewardedForResult() async {
    final service = AdService();
    await service.init();

    if (!service._adsAvailable || !service._isLegalAccepted) {
      service._rewardedState = RewardedAdState.idle;
      return RewardAdResult.unavailable;
    }

    // Fullscreen ad mutual exclusion & duplicate show protection
    if (service._isShowingRewarded || service._isShowingInterstitial || service._isShowingAppOpen) {
      debugPrint('[AdService] Fullscreen ad presentation already in progress. Ignoring Rewarded trigger.');
      return RewardAdResult.unavailable;
    }

    service._isShowingRewarded = true;

    try {
      RewardedAdHandle? handle = service._rewardedHandle;
      if (handle == null) {
        try {
          handle = await service.loadRewarded().timeout(const Duration(seconds: 10));
        } catch (e) {
          debugPrint('[AdService] Timeout/error waiting for rewarded ad: $e');
        }
      }

      if (handle == null) {
        AnalyticsService.log(AnalyticsService.rewardAdUnavailable);
        service._rewardedState = RewardedAdState.failed;
        service._isShowingRewarded = false;
        return RewardAdResult.unavailable;
      }

      final completer = Completer<RewardAdResult>();
      var rewardEarned = false;
      service._rewardedState = RewardedAdState.showing;

      // Invalidate service reference so the exact same instance cannot be shown twice
      service._rewardedHandle = null;

      await handle.show(
        onUserEarnedReward: () {
          rewardEarned = true;
          service._rewardedState = RewardedAdState.earned;
        },
        onAdDismissed: () {
          handle?.dispose();
          service._isShowingRewarded = false;
          service._rewardedState = rewardEarned ? RewardedAdState.earned : RewardedAdState.dismissed;
          if (!completer.isCompleted) {
            completer.complete(rewardEarned ? RewardAdResult.shownRewarded : RewardAdResult.shownNoReward);
          }
        },
        onAdFailedToShow: (err) {
          handle?.dispose();
          service._isShowingRewarded = false;
          service._rewardedState = RewardedAdState.failed;
          AnalyticsService.log(AnalyticsService.rewardAdFailed, {'error': err});
          if (!completer.isCompleted) completer.complete(RewardAdResult.failed);
        },
      );

      return await completer.future;
    } catch (e) {
      debugPrint('[AdService] Error presenting rewarded ad: $e');
      service._isShowingRewarded = false;
      service._rewardedState = RewardedAdState.failed;
      AnalyticsService.log(AnalyticsService.rewardAdFailed);
      return RewardAdResult.failed;
    } finally {
      // Ensure state is unblocked in all exit conditions
      service._isShowingRewarded = false;
    }
  }

  static Future<bool> showInterstitial({bool ignoreCooldown = false}) async {
    final service = AdService();
    await service.init();
    return service._innerShowInterstitial(ignoreCooldown: ignoreCooldown);
  }

  static Future<bool> showRewardedAd() async {
    final result = await showRewardedForResult();
    return result == RewardAdResult.shownRewarded;
  }
}

enum InterstitialAdState {
  idle,
  loading,
  loaded,
  showing,
  dismissed,
  failed,
}

abstract class InterstitialAdHandle {
  void dispose();
  Future<void> show({
    required void Function() onAdShowed,
    required void Function() onAdDismissed,
    required void Function(String error) onAdFailedToShow,
  });
}

abstract class InterstitialAdDelegate {
  Future<InterstitialAdHandle?> loadInterstitial(String adUnitId);
}

class DefaultInterstitialAdHandle implements InterstitialAdHandle {
  final InterstitialAd _ad;
  DefaultInterstitialAdHandle(this._ad);

  @override
  void dispose() {
    _ad.dispose();
  }

  @override
  Future<void> show({
    required void Function() onAdShowed,
    required void Function() onAdDismissed,
    required void Function(String error) onAdFailedToShow,
  }) async {
    _ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (shownAd) {
        AnalyticsService.log(AnalyticsService.interstitialShown);
        onAdShowed();
      },
      onAdDismissedFullScreenContent: (shownAd) {
        onAdDismissed();
      },
      onAdFailedToShowFullScreenContent: (shownAd, err) {
        onAdFailedToShow(err.message);
      },
    );

    await _ad.show();
  }
}

class DefaultInterstitialAdDelegate implements InterstitialAdDelegate {
  @override
  Future<InterstitialAdHandle?> loadInterstitial(String adUnitId) {
    final completer = Completer<InterstitialAdHandle?>();
    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          completer.complete(DefaultInterstitialAdHandle(ad));
        },
        onAdFailedToLoad: (error) {
          debugPrint('[AdService] InterstitialAd failed to load: ${error.message}');
          completer.complete(null);
        },
      ),
    );
    return completer.future;
  }
}

enum RewardedAdState {
  idle,
  loading,
  loaded,
  showing,
  earned,
  dismissed,
  failed,
}

abstract class RewardedAdHandle {
  void dispose();
  Future<void> show({
    required void Function() onUserEarnedReward,
    required void Function() onAdDismissed,
    required void Function(String error) onAdFailedToShow,
  });
}

abstract class RewardedAdDelegate {
  Future<RewardedAdHandle?> loadRewarded(String adUnitId);
}

class DefaultRewardedAdHandle implements RewardedAdHandle {
  final RewardedAd _ad;
  DefaultRewardedAdHandle(this._ad);

  @override
  void dispose() {
    _ad.dispose();
  }

  @override
  Future<void> show({
    required void Function() onUserEarnedReward,
    required void Function() onAdDismissed,
    required void Function(String error) onAdFailedToShow,
  }) async {
    _ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (shownAd) {
        AnalyticsService.log(AnalyticsService.rewardAdShown);
      },
      onAdDismissedFullScreenContent: (shownAd) {
        onAdDismissed();
      },
      onAdFailedToShowFullScreenContent: (shownAd, err) {
        onAdFailedToShow(err.message);
      },
    );

    await _ad.show(
      onUserEarnedReward: (shownAd, reward) {
        AnalyticsService.log(AnalyticsService.rewardAdRewarded, {
          'amount': reward.amount,
          'type': reward.type,
        });
        onUserEarnedReward();
      },
    );
  }
}

class DefaultRewardedAdDelegate implements RewardedAdDelegate {
  @override
  Future<RewardedAdHandle?> loadRewarded(String adUnitId) {
    final completer = Completer<RewardedAdHandle?>();
    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          completer.complete(DefaultRewardedAdHandle(ad));
        },
        onAdFailedToLoad: (error) {
          debugPrint('[AdService] RewardedAd failed to load: ${error.message}');
          completer.complete(null);
        },
      ),
    );
    return completer.future;
  }
}

enum AppOpenAdState {
  idle,
  loading,
  loaded,
  showing,
  dismissed,
  failed,
}

abstract class AppOpenAdHandle {
  void dispose();
  Future<void> show({
    required void Function() onAdShowed,
    required void Function() onAdDismissed,
    required void Function(String error) onAdFailedToShow,
  });
}

abstract class AppOpenAdDelegate {
  Future<AppOpenAdHandle?> loadAppOpen(String adUnitId);
}

class DefaultAppOpenAdHandle implements AppOpenAdHandle {
  final AppOpenAd _ad;
  DefaultAppOpenAdHandle(this._ad);

  @override
  void dispose() {
    _ad.dispose();
  }

  @override
  Future<void> show({
    required void Function() onAdShowed,
    required void Function() onAdDismissed,
    required void Function(String error) onAdFailedToShow,
  }) async {
    _ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (shownAd) {
        AnalyticsService.log(AnalyticsService.appOpenAdShown);
        onAdShowed();
      },
      onAdDismissedFullScreenContent: (shownAd) {
        onAdDismissed();
      },
      onAdFailedToShowFullScreenContent: (shownAd, err) {
        onAdFailedToShow(err.message);
      },
    );

    await _ad.show();
  }
}

class DefaultAppOpenAdDelegate implements AppOpenAdDelegate {
  @override
  Future<AppOpenAdHandle?> loadAppOpen(String adUnitId) {
    final completer = Completer<AppOpenAdHandle?>();
    AppOpenAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          completer.complete(DefaultAppOpenAdHandle(ad));
        },
        onAdFailedToLoad: (error) {
          debugPrint('[AdService] AppOpenAd failed to load: ${error.message}');
          completer.complete(null);
        },
      ),
    );
    return completer.future;
  }
}
