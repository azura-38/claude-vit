import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vitacase/core/config/app_config.dart';
import 'package:vitacase/core/types/runtime_types.dart';
import 'package:vitacase/shared/data/services/ad_service.dart';

class FakeInterstitialAdHandle implements InterstitialAdHandle {
  final bool willFailShow;
  final String? failureMessage;
  final Completer<void>? waitBeforeDismiss;
  bool isDisposed = false;
  int showCallCount = 0;

  FakeInterstitialAdHandle({
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
      onAdFailedToShow(failureMessage ?? 'Ad show failed');
      return;
    }

    onAdShowed();

    if (waitBeforeDismiss != null) {
      await waitBeforeDismiss!.future;
    }

    onAdDismissed();
  }
}

class FakeInterstitialAdDelegate implements InterstitialAdDelegate {
  final bool shouldFailLoad;
  final InterstitialAdHandle? handleToReturn;
  final Duration? loadDelay;
  int loadCallCount = 0;

  FakeInterstitialAdDelegate({
    this.shouldFailLoad = false,
    this.handleToReturn,
    this.loadDelay,
  });

  @override
  Future<InterstitialAdHandle?> loadInterstitial(String adUnitId) async {
    loadCallCount++;
    if (loadDelay != null) {
      await Future.delayed(loadDelay!);
    }
    if (shouldFailLoad) {
      return null;
    }
    return handleToReturn ?? FakeInterstitialAdHandle();
  }
}

class FakeRewardedAdHandle implements RewardedAdHandle {
  final bool willEarnReward;
  bool isDisposed = false;

  FakeRewardedAdHandle({this.willEarnReward = true});

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
    if (willEarnReward) onUserEarnedReward();
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

  group('Phase 13 Interstitial Ads Tests', () {
    // K. Debug/test ad configuration
    test('K. Debug configuration uses test ad ID on non-iOS debug mode', () {
      expect(AppConfig.interstitialAdId, equals('ca-app-pub-3940256099942544/1033173712'));
    });

    // A. Interstitial load success
    test('A. Interstitial load success sets state to loaded and returns handle', () async {
      final fakeHandle = FakeInterstitialAdHandle();
      final delegate = FakeInterstitialAdDelegate(handleToReturn: fakeHandle);
      AdService.setInterstitialDelegateForTesting(delegate);

      final service = AdService();
      expect(AdService.interstitialState, equals(InterstitialAdState.idle));

      final handle = await service.loadInterstitial();

      expect(handle, isNotNull);
      expect(AdService.interstitialState, equals(InterstitialAdState.loaded));
      expect(AdService.isInterstitialAdAvailable, isTrue);
      expect(delegate.loadCallCount, equals(1));
    });

    // B. Interstitial load failure
    test('B. Interstitial load failure sets state to failed and returns null', () async {
      final delegate = FakeInterstitialAdDelegate(shouldFailLoad: true);
      AdService.setInterstitialDelegateForTesting(delegate);

      final service = AdService();
      final handle = await service.loadInterstitial();

      expect(handle, isNull);
      expect(AdService.interstitialState, equals(InterstitialAdState.failed));
      expect(AdService.isInterstitialAdAvailable, isFalse);
    });

    // C. Interstitial show success
    test('C. Interstitial show success displays ad and returns true', () async {
      final fakeHandle = FakeInterstitialAdHandle();
      final delegate = FakeInterstitialAdDelegate(handleToReturn: fakeHandle);
      AdService.setInterstitialDelegateForTesting(delegate);

      final shown = await AdService.showInterstitial();

      expect(shown, isTrue);
      expect(fakeHandle.showCallCount, equals(1));
      expect(AdService.interstitialState, equals(InterstitialAdState.dismissed));
      expect(AdService().lastInterstitialShown, isNotNull);
    });

    // D. Interstitial show failure
    test('D. Interstitial show failure sets state to failed and returns false gracefully without crashing', () async {
      final fakeHandle = FakeInterstitialAdHandle(willFailShow: true, failureMessage: 'Network timeout');
      final delegate = FakeInterstitialAdDelegate(handleToReturn: fakeHandle);
      AdService.setInterstitialDelegateForTesting(delegate);

      final shown = await AdService.showInterstitial();

      expect(shown, isFalse);
      expect(fakeHandle.isDisposed, isTrue);
      expect(AdService.interstitialState, equals(InterstitialAdState.failed));
    });

    // E. Dismiss lifecycle
    test('E. Dismiss lifecycle properly disposes handle and clears cached reference', () async {
      final fakeHandle = FakeInterstitialAdHandle();
      final delegate = FakeInterstitialAdDelegate(handleToReturn: fakeHandle);
      AdService.setInterstitialDelegateForTesting(delegate);

      await AdService().loadInterstitial();
      expect(AdService.isInterstitialAdAvailable, isTrue);

      final shown = await AdService.showInterstitial();
      expect(shown, isTrue);

      // Handle must be disposed and service reference cleared
      expect(fakeHandle.isDisposed, isTrue);
      expect(AdService.isInterstitialAdAvailable, isFalse);
      expect(AdService.interstitialState, equals(InterstitialAdState.dismissed));
    });

    // F. Duplicate show protection
    test('F. Duplicate show protection prevents concurrent presentations', () async {
      final waitCompleter = Completer<void>();
      final fakeHandle = FakeInterstitialAdHandle(waitBeforeDismiss: waitCompleter);
      final delegate = FakeInterstitialAdDelegate(handleToReturn: fakeHandle);
      AdService.setInterstitialDelegateForTesting(delegate);

      // Trigger first show
      final firstShowFuture = AdService.showInterstitial();

      // Ensure it is in progress
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(AdService.isInterstitialAdShowing, isTrue);

      // Trigger second show while first is in progress
      final secondShowResult = await AdService.showInterstitial();

      // Second show should be rejected immediately
      expect(secondShowResult, isFalse);

      // Finish first show
      waitCompleter.complete();
      final firstShowResult = await firstShowFuture;
      expect(firstShowResult, isTrue);
      expect(fakeHandle.showCallCount, equals(1));
    });

    // G. Duplicate load protection
    test('G. Duplicate load protection collapses concurrent load requests into one', () async {
      final delegate = FakeInterstitialAdDelegate(
        loadDelay: const Duration(milliseconds: 50),
      );
      AdService.setInterstitialDelegateForTesting(delegate);

      final service = AdService();
      final f1 = service.loadInterstitial();
      final f2 = service.loadInterstitial();

      final results = await Future.wait([f1, f2]);

      expect(results[0], isNotNull);
      expect(results[1], isNotNull);
      expect(identical(results[0], results[1]), isTrue);
      expect(delegate.loadCallCount, equals(1));
    });

    // H. Dispose during async load/show
    test('H. Dispose during async load or reset cleanly clears state without exceptions', () async {
      final fakeHandle = FakeInterstitialAdHandle();
      final delegate = FakeInterstitialAdDelegate(handleToReturn: fakeHandle);
      AdService.setInterstitialDelegateForTesting(delegate);

      await AdService().loadInterstitial();
      expect(AdService.isInterstitialAdAvailable, isTrue);

      AdService.resetForTesting();
      expect(fakeHandle.isDisposed, isTrue);
      expect(AdService.isInterstitialAdAvailable, isFalse);
      expect(AdService.interstitialState, equals(InterstitialAdState.idle));
    });

    // I. Cooldown/frequency behavior
    test('I. Cooldown suppresses consecutive shows within 90 seconds unless bypassed', () async {
      final fakeHandle = FakeInterstitialAdHandle();
      final delegate = FakeInterstitialAdDelegate(handleToReturn: fakeHandle);
      AdService.setInterstitialDelegateForTesting(delegate);

      // First show succeeds
      final firstShown = await AdService.showInterstitial();
      expect(firstShown, isTrue);

      // Immediate second show should be suppressed by cooldown
      final secondShown = await AdService.showInterstitial();
      expect(secondShown, isFalse);

      // When ignoreCooldown is true (e.g. manual debug test), it bypasses cooldown
      final forcedShown = await AdService.showInterstitial(ignoreCooldown: true);
      expect(forcedShown, isTrue);
    });

    // J. Rewarded + Interstitial independence
    test('J. Rewarded and Interstitial lifecycles operate completely independently', () async {
      final interstitialHandle = FakeInterstitialAdHandle();
      final rewardedHandle = FakeRewardedAdHandle();

      AdService.setInterstitialDelegateForTesting(
        FakeInterstitialAdDelegate(handleToReturn: interstitialHandle),
      );
      AdService.setRewardedDelegateForTesting(
        FakeRewardedAdDelegate(handleToReturn: rewardedHandle),
      );

      final service = AdService();

      // 1. Load Interstitial
      await service.loadInterstitial();
      expect(AdService.interstitialState, equals(InterstitialAdState.loaded));
      expect(AdService.rewardedState, equals(RewardedAdState.idle));

      // 2. Load Rewarded
      await service.loadRewarded();
      expect(AdService.interstitialState, equals(InterstitialAdState.loaded));
      expect(AdService.rewardedState, equals(RewardedAdState.loaded));

      // 3. Show Rewarded
      final rewardResult = await AdService.showRewardedForResult();
      expect(rewardResult, equals(RewardAdResult.shownRewarded));
      expect(AdService.rewardedState, equals(RewardedAdState.earned));
      // Interstitial is still loaded and untouched!
      expect(AdService.interstitialState, equals(InterstitialAdState.loaded));

      // 4. Show Interstitial
      final interstitialShown = await AdService.showInterstitial();
      expect(interstitialShown, isTrue);
      expect(AdService.interstitialState, equals(InterstitialAdState.dismissed));
      // Rewarded state remains unaffected
      expect(AdService.rewardedState, equals(RewardedAdState.earned));
    });
  });
}
