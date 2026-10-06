import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vitacase/core/ads/ad_visibility_policy.dart';
import 'package:vitacase/core/config/app_config.dart';
import 'package:vitacase/core/types/runtime_types.dart';
import 'package:vitacase/shared/data/services/ad_service.dart';

class FakeAppOpenAdHandle implements AppOpenAdHandle {
  final bool willFailShow;
  final String? failureMessage;
  final Completer<void>? waitBeforeDismiss;
  bool isDisposed = false;
  int showCallCount = 0;

  FakeAppOpenAdHandle({
    this.willFailShow = false,
    this.failureMessage,
    this.waitBeforeDismiss,
  });

  @override
  void dispose() {
    isDisposed = true;
  }

  @override
  Future<void> show({
    required void Function() onAdShowed,
    required void Function() onAdDismissed,
    required void Function(String error) onAdFailedToShow,
  }) async {
    showCallCount++;
    if (willFailShow) {
      onAdFailedToShow(failureMessage ?? 'App Open show failed');
      return;
    }

    onAdShowed();

    if (waitBeforeDismiss != null) {
      await waitBeforeDismiss!.future;
    }

    onAdDismissed();
  }
}

class FakeAppOpenAdDelegate implements AppOpenAdDelegate {
  final bool shouldFailLoad;
  final AppOpenAdHandle? handleToReturn;
  final Duration? loadDelay;
  int loadCallCount = 0;

  FakeAppOpenAdDelegate({
    this.shouldFailLoad = false,
    this.handleToReturn,
    this.loadDelay,
  });

  @override
  Future<AppOpenAdHandle?> loadAppOpen(String adUnitId) async {
    loadCallCount++;
    if (loadDelay != null) {
      await Future.delayed(loadDelay!);
    }
    if (shouldFailLoad) {
      return null;
    }
    return handleToReturn ?? FakeAppOpenAdHandle();
  }
}

class FakeInterstitialAdHandle implements InterstitialAdHandle {
  final Completer<void>? waitBeforeDismiss;
  bool isDisposed = false;

  FakeInterstitialAdHandle({this.waitBeforeDismiss});

  @override
  void dispose() {
    isDisposed = true;
  }

  @override
  Future<void> show({
    required void Function() onAdShowed,
    required void Function() onAdDismissed,
    required void Function(String error) onAdFailedToShow,
  }) async {
    onAdShowed();
    if (waitBeforeDismiss != null) {
      await waitBeforeDismiss!.future;
    }
    onAdDismissed();
  }
}

class FakeInterstitialAdDelegate implements InterstitialAdDelegate {
  final InterstitialAdHandle? handleToReturn;
  FakeInterstitialAdDelegate({this.handleToReturn});

  @override
  Future<InterstitialAdHandle?> loadInterstitial(String adUnitId) async {
    return handleToReturn ?? FakeInterstitialAdHandle();
  }
}

class FakeRewardedAdHandle implements RewardedAdHandle {
  final Completer<void>? waitBeforeDismiss;
  bool isDisposed = false;

  FakeRewardedAdHandle({this.waitBeforeDismiss});

  @override
  void dispose() {
    isDisposed = true;
  }

  @override
  Future<void> show({
    required void Function() onUserEarnedReward,
    required void Function() onAdDismissed,
    required void Function(String error) onAdFailedToShow,
  }) async {
    onUserEarnedReward();
    if (waitBeforeDismiss != null) {
      await waitBeforeDismiss!.future;
    }
    onAdDismissed();
  }
}

class FakeRewardedAdDelegate implements RewardedAdDelegate {
  final RewardedAdHandle? handleToReturn;
  FakeRewardedAdDelegate({this.handleToReturn});

  @override
  Future<RewardedAdHandle?> loadRewarded(String adUnitId) async {
    return handleToReturn ?? FakeRewardedAdHandle();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/google_mobile_ads'),
      (MethodCall methodCall) async {
        return null;
      },
    );
    SharedPreferences.setMockInitialValues({});
    AdService.resetForTesting();
  });

  tearDown(() {
    AdService.resetForTesting();
  });

  group('Phase 14 App Open Ads Tests', () {
    // P. Debug/test ad configuration
    test('P. Debug configuration uses Google test App Open ID on non-iOS debug mode', () {
      expect(AppConfig.appOpenAdId, equals('ca-app-pub-3940256099942544/9257395921'));
    });

    // A. App Open load success
    test('A. App Open load success sets state to loaded and returns handle', () async {
      final fakeHandle = FakeAppOpenAdHandle();
      final delegate = FakeAppOpenAdDelegate(handleToReturn: fakeHandle);
      AdService.setAppOpenDelegateForTesting(delegate);

      final service = AdService();
      expect(AdService.appOpenState, equals(AppOpenAdState.idle));

      final handle = await service.loadAppOpen();

      expect(handle, isNotNull);
      expect(AdService.appOpenState, equals(AppOpenAdState.loaded));
      expect(AdService.isAppOpenAdAvailable, isTrue);
      expect(delegate.loadCallCount, equals(1));
    });

    // B. App Open load failure
    test('B. App Open load failure sets state to failed and returns null', () async {
      final delegate = FakeAppOpenAdDelegate(shouldFailLoad: true);
      AdService.setAppOpenDelegateForTesting(delegate);

      final service = AdService();
      final handle = await service.loadAppOpen();

      expect(handle, isNull);
      expect(AdService.appOpenState, equals(AppOpenAdState.failed));
      expect(AdService.isAppOpenAdAvailable, isFalse);
    });

    // C. App Open show success
    test('C. App Open show success displays ad, disposes instance and returns true', () async {
      final fakeHandle = FakeAppOpenAdHandle();
      final delegate = FakeAppOpenAdDelegate(handleToReturn: fakeHandle);
      AdService.setAppOpenDelegateForTesting(delegate);

      final shown = await AdService.showAppOpenAd();

      expect(shown, isTrue);
      expect(fakeHandle.showCallCount, equals(1));
      expect(fakeHandle.isDisposed, isTrue);
      expect(AdService.appOpenState, equals(AppOpenAdState.dismissed));
      expect(AdService().lastAppOpenShown, isNotNull);
    });

    // D. App Open show failure
    test('D. App Open show failure handles error gracefully and returns false without crashing', () async {
      final fakeHandle = FakeAppOpenAdHandle(willFailShow: true, failureMessage: 'AppOpen show error');
      final delegate = FakeAppOpenAdDelegate(handleToReturn: fakeHandle);
      AdService.setAppOpenDelegateForTesting(delegate);

      final shown = await AdService.showAppOpenAd();

      expect(shown, isFalse);
      expect(fakeHandle.isDisposed, isTrue);
      expect(AdService.appOpenState, equals(AppOpenAdState.failed));
    });

    // E. Dismiss lifecycle
    test('E. Dismiss lifecycle properly nullifies cached reference so ad cannot be shown twice', () async {
      final fakeHandle = FakeAppOpenAdHandle();
      final delegate = FakeAppOpenAdDelegate(handleToReturn: fakeHandle);
      AdService.setAppOpenDelegateForTesting(delegate);

      await AdService().loadAppOpen();
      expect(AdService.isAppOpenAdAvailable, isTrue);

      final shown = await AdService.showAppOpenAd();
      expect(shown, isTrue);

      expect(fakeHandle.isDisposed, isTrue);
      expect(AdService.isAppOpenAdAvailable, isFalse);
      expect(AdService.appOpenState, equals(AppOpenAdState.dismissed));
    });

    // F. Duplicate show protection
    test('F. Duplicate show protection prevents concurrent presentations of App Open ad', () async {
      final waitCompleter = Completer<void>();
      final fakeHandle = FakeAppOpenAdHandle(waitBeforeDismiss: waitCompleter);
      final delegate = FakeAppOpenAdDelegate(handleToReturn: fakeHandle);
      AdService.setAppOpenDelegateForTesting(delegate);

      // Trigger first show
      final firstShowFuture = AdService.showAppOpenAd();

      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(AdService.isAppOpenAdShowing, isTrue);

      // Trigger second show while first is in progress
      final secondShowResult = await AdService.showAppOpenAd();
      expect(secondShowResult, isFalse);

      // Complete first show
      waitCompleter.complete();
      final firstShowResult = await firstShowFuture;
      expect(firstShowResult, isTrue);
      expect(fakeHandle.showCallCount, equals(1));
    });

    // G. Duplicate load protection
    test('G. Duplicate load protection collapses concurrent load requests into one', () async {
      final delegate = FakeAppOpenAdDelegate(loadDelay: const Duration(milliseconds: 50));
      AdService.setAppOpenDelegateForTesting(delegate);

      final service = AdService();
      final f1 = service.loadAppOpen();
      final f2 = service.loadAppOpen();

      final results = await Future.wait([f1, f2]);

      expect(results[0], isNotNull);
      expect(results[1], isNotNull);
      expect(identical(results[0], results[1]), isTrue);
      expect(delegate.loadCallCount, equals(1));
    });

    // H. Cooldown behavior
    test('H. Cooldown suppresses consecutive App Open shows within 5 minutes unless bypassed', () async {
      final fakeHandle = FakeAppOpenAdHandle();
      final delegate = FakeAppOpenAdDelegate(handleToReturn: fakeHandle);
      AdService.setAppOpenDelegateForTesting(delegate);

      // First show succeeds
      final firstShown = await AdService.showAppOpenAd();
      expect(firstShown, isTrue);

      // Immediate second show should be suppressed by cooldown
      final secondShown = await AdService.showAppOpenAd();
      expect(secondShown, isFalse);

      // When ignoreCooldown is true, it bypasses cooldown
      final forcedShown = await AdService.showAppOpenAd(ignoreCooldown: true);
      expect(forcedShown, isTrue);
    });

    // I. Cold start gating
    test('I. Cold start gating: AdVisibilityPolicy blocks ads when bootstrap is running', () {
      const policy = AdVisibilityPolicy(
        bootstrapCompleted: false,
        isPremium: false,
        onboardingCompleted: true,
        profileCreated: true,
        lockEnabled: false,
        lockState: AppLockState.unlocked,
      );

      expect(policy.canShowAppOpen, isFalse);
      expect(policy.canShowBanner, isFalse);
    });

    // J. Onboarding blocks App Open
    test('J. Onboarding blocks App Open: policy rejects when onboarding is incomplete', () {
      const policy = AdVisibilityPolicy(
        bootstrapCompleted: true,
        isPremium: false,
        onboardingCompleted: false,
        profileCreated: false,
        lockEnabled: false,
        lockState: AppLockState.unlocked,
      );

      expect(policy.canShowAppOpen, isFalse);
    });

    // K. AppLock blocks App Open
    test('K. AppLock blocks App Open: policy rejects when lock is enabled and locked', () {
      const policy = AdVisibilityPolicy(
        bootstrapCompleted: true,
        isPremium: false,
        onboardingCompleted: true,
        profileCreated: true,
        lockEnabled: true,
        lockState: AppLockState.locked,
      );

      expect(policy.canShowAppOpen, isFalse);
    });

    // L. Bootstrap-not-ready blocks App Open
    test('L. Bootstrap-not-ready blocks App Open but permits when fully initialized', () {
      const pendingPolicy = AdVisibilityPolicy(
        bootstrapCompleted: false,
        isPremium: false,
        onboardingCompleted: true,
        profileCreated: true,
        lockEnabled: false,
        lockState: AppLockState.unlocked,
      );
      expect(pendingPolicy.canShowAppOpen, isFalse);

      const readyPolicy = AdVisibilityPolicy(
        bootstrapCompleted: true,
        isPremium: false,
        onboardingCompleted: true,
        profileCreated: true,
        lockEnabled: false,
        lockState: AppLockState.unlocked,
      );
      expect(readyPolicy.canShowAppOpen, isTrue);
    });

    // M. Rewarded + App Open mutual exclusion
    test('M. Rewarded and App Open are mutually exclusive: App Open cannot show when Rewarded is showing', () async {
      final rewardedWait = Completer<void>();
      final rewardedHandle = FakeRewardedAdHandle(waitBeforeDismiss: rewardedWait);
      AdService.setRewardedDelegateForTesting(
        FakeRewardedAdDelegate(handleToReturn: rewardedHandle),
      );
      AdService.setAppOpenDelegateForTesting(FakeAppOpenAdDelegate());

      // Start Rewarded ad
      final rewardedFuture = AdService.showRewardedForResult();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(AdService.isRewardedAdShowing, isTrue);

      // Attempt App Open while Rewarded is showing -> must be suppressed
      final appOpenShown = await AdService.showAppOpenAd();
      expect(appOpenShown, isFalse);

      rewardedWait.complete();
      final result = await rewardedFuture;
      expect(result, equals(RewardAdResult.shownRewarded));
    });

    // N. Interstitial + App Open mutual exclusion
    test('N. Interstitial and App Open are mutually exclusive in both directions', () async {
      final interstitialWait = Completer<void>();
      final interstitialHandle = FakeInterstitialAdHandle(waitBeforeDismiss: interstitialWait);
      AdService.setInterstitialDelegateForTesting(
        FakeInterstitialAdDelegate(handleToReturn: interstitialHandle),
      );
      AdService.setAppOpenDelegateForTesting(FakeAppOpenAdDelegate());

      // 1. Interstitial is showing -> App Open must fail
      final interstitialFuture = AdService.showInterstitial();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(AdService.isInterstitialAdShowing, isTrue);

      final appOpenDuringInterstitial = await AdService.showAppOpenAd();
      expect(appOpenDuringInterstitial, isFalse);

      interstitialWait.complete();
      expect(await interstitialFuture, isTrue);

      // 2. App Open is showing -> Interstitial must fail
      final appOpenWait = Completer<void>();
      final appOpenHandle = FakeAppOpenAdHandle(waitBeforeDismiss: appOpenWait);
      AdService.setAppOpenDelegateForTesting(
        FakeAppOpenAdDelegate(handleToReturn: appOpenHandle),
      );

      final appOpenFuture = AdService.showAppOpenAd();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(AdService.isAppOpenAdShowing, isTrue);

      final interstitialDuringAppOpen = await AdService.showInterstitial(ignoreCooldown: true);
      expect(interstitialDuringAppOpen, isFalse);

      appOpenWait.complete();
      expect(await appOpenFuture, isTrue);
    });

    // O. Dispose/stale callback safety
    test('O. Dispose / resetForTesting cleanly resets state without throwing or leaking', () async {
      final fakeHandle = FakeAppOpenAdHandle();
      final delegate = FakeAppOpenAdDelegate(handleToReturn: fakeHandle);
      AdService.setAppOpenDelegateForTesting(delegate);

      await AdService().loadAppOpen();
      expect(AdService.isAppOpenAdAvailable, isTrue);

      AdService.resetForTesting();
      expect(fakeHandle.isDisposed, isTrue);
      expect(AdService.isAppOpenAdAvailable, isFalse);
      expect(AdService.appOpenState, equals(AppOpenAdState.idle));
    });
  });
}
