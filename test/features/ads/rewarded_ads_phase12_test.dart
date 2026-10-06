import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vitacase/core/config/app_config.dart';
import 'package:vitacase/core/types/runtime_types.dart';
import 'package:vitacase/shared/data/services/ad_service.dart';

class FakeRewardedAdHandle implements RewardedAdHandle {
  final bool willEarnReward;
  final bool willFailShow;
  final String? failureMessage;
  bool isDisposed = false;
  int showCallCount = 0;

  FakeRewardedAdHandle({
    this.willEarnReward = true,
    this.willFailShow = false,
    this.failureMessage,
  });

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
    showCallCount++;
    if (willFailShow) {
      onAdFailedToShow(failureMessage ?? 'Ad show failed');
      return;
    }

    if (willEarnReward) {
      onUserEarnedReward();
    }
    onAdDismissed();
  }
}

class FakeRewardedAdDelegate implements RewardedAdDelegate {
  final bool shouldFailLoad;
  final RewardedAdHandle? handleToReturn;
  final Duration? loadDelay;
  int loadCallCount = 0;

  FakeRewardedAdDelegate({
    this.shouldFailLoad = false,
    this.handleToReturn,
    this.loadDelay,
  });

  @override
  Future<RewardedAdHandle?> loadRewarded(String adUnitId) async {
    loadCallCount++;
    if (loadDelay != null) {
      await Future.delayed(loadDelay!);
    }
    if (shouldFailLoad) {
      return null;
    }
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

  group('Phase 12 Rewarded Ads Tests', () {
    // J. Debug configuration uses test ad ID
    test('J. Debug configuration uses test ad ID on Android debug mode', () {
      expect(AppConfig.rewardedAdId, equals('ca-app-pub-3940256099942544/5224354917'));
    });

    // A. Rewarded load success
    test('A. Rewarded load success sets state to loaded and returns handle', () async {
      final fakeHandle = FakeRewardedAdHandle();
      final delegate = FakeRewardedAdDelegate(handleToReturn: fakeHandle);
      AdService.setRewardedDelegateForTesting(delegate);

      final service = AdService();
      final loadedHandle = await service.loadRewarded();

      expect(loadedHandle, isNotNull);
      expect(AdService.rewardedState, equals(RewardedAdState.loaded));
      expect(AdService.isRewardedAdAvailable, isTrue);
      expect(delegate.loadCallCount, equals(1));
    });

    // B. Rewarded load failure
    test('B. Rewarded load failure sets state to failed and returns null', () async {
      final delegate = FakeRewardedAdDelegate(shouldFailLoad: true);
      AdService.setRewardedDelegateForTesting(delegate);

      final service = AdService();
      final loadedHandle = await service.loadRewarded();

      expect(loadedHandle, isNull);
      expect(AdService.rewardedState, equals(RewardedAdState.failed));
      expect(AdService.isRewardedAdAvailable, isFalse);
    });

    // C. Reward callback gives reward
    test('C. Reward callback gives reward only when onUserEarnedReward fires', () async {
      final fakeHandle = FakeRewardedAdHandle(willEarnReward: true);
      final delegate = FakeRewardedAdDelegate(handleToReturn: fakeHandle);
      AdService.setRewardedDelegateForTesting(delegate);

      final result = await AdService.showRewardedForResult();

      expect(result, equals(RewardAdResult.shownRewarded));
      expect(AdService.rewardedState, equals(RewardedAdState.earned));
      expect(fakeHandle.isDisposed, isTrue);
      expect(AdService.isRewardedAdShowing, isFalse);

      final boolResult = await AdService.showRewardedAd();
      // Second show call triggers another load
      expect(boolResult, isTrue);
    });

    // D. No reward without callback
    test('D. No reward without callback when onUserEarnedReward is not invoked', () async {
      final fakeHandle = FakeRewardedAdHandle(willEarnReward: false);
      final delegate = FakeRewardedAdDelegate(handleToReturn: fakeHandle);
      AdService.setRewardedDelegateForTesting(delegate);

      final result = await AdService.showRewardedForResult();

      expect(result, equals(RewardAdResult.shownNoReward));
      expect(AdService.rewardedState, equals(RewardedAdState.dismissed));
      expect(fakeHandle.isDisposed, isTrue);
      expect(AdService.isRewardedAdShowing, isFalse);
    });

    // E. Double tap protection
    test('E. Double tap protection rejects concurrent presentation requests', () async {
      final completer = Completer<void>();
      final fakeHandle = _DelayedRewardedAdHandle(completer);
      final delegate = FakeRewardedAdDelegate(handleToReturn: fakeHandle);
      AdService.setRewardedDelegateForTesting(delegate);

      // Start first show
      final firstShowFuture = AdService.showRewardedForResult();

      // Second immediate trigger while first is showing
      final secondShowResult = await AdService.showRewardedForResult();
      expect(secondShowResult, equals(RewardAdResult.unavailable));

      // Complete first show
      completer.complete();
      final firstResult = await firstShowFuture;
      expect(firstResult, equals(RewardAdResult.shownRewarded));
      expect(fakeHandle.showCallCount, equals(1));
    });

    // F. Ad dismissed without reward
    test('F. Ad dismissed without reward returns shownNoReward and cleans up handle', () async {
      final fakeHandle = FakeRewardedAdHandle(willEarnReward: false);
      final delegate = FakeRewardedAdDelegate(handleToReturn: fakeHandle);
      AdService.setRewardedDelegateForTesting(delegate);

      final result = await AdService.showRewardedForResult();
      expect(result, equals(RewardAdResult.shownNoReward));
      expect(fakeHandle.isDisposed, isTrue);
      expect(AdService.isRewardedAdAvailable, isFalse);
    });

    // G. Dispose during async load / cleanup
    test('G. Handle is properly disposed and nullified after completion', () async {
      final fakeHandle = FakeRewardedAdHandle(willEarnReward: true);
      final delegate = FakeRewardedAdDelegate(handleToReturn: fakeHandle);
      AdService.setRewardedDelegateForTesting(delegate);

      await AdService.showRewardedForResult();

      expect(fakeHandle.isDisposed, isTrue);
      expect(AdService.isRewardedAdAvailable, isFalse);
      expect(AdService.isRewardedAdShowing, isFalse);
    });

    // H. Show failure
    test('H. Show failure handles error gracefully without throwing', () async {
      final fakeHandle = FakeRewardedAdHandle(willFailShow: true, failureMessage: 'Network disconnected');
      final delegate = FakeRewardedAdDelegate(handleToReturn: fakeHandle);
      AdService.setRewardedDelegateForTesting(delegate);

      final result = await AdService.showRewardedForResult();

      expect(result, equals(RewardAdResult.failed));
      expect(AdService.rewardedState, equals(RewardedAdState.failed));
      expect(fakeHandle.isDisposed, isTrue);
      expect(AdService.isRewardedAdShowing, isFalse);
    });

    // I. Existing use case integration
    test('I. showRewardedAd wrapper returns true on success and false on failure', () async {
      // Success case
      final successHandle = FakeRewardedAdHandle(willEarnReward: true);
      AdService.setRewardedDelegateForTesting(FakeRewardedAdDelegate(handleToReturn: successHandle));
      expect(await AdService.showRewardedAd(), isTrue);

      // Dismiss without reward
      final noRewardHandle = FakeRewardedAdHandle(willEarnReward: false);
      AdService.setRewardedDelegateForTesting(FakeRewardedAdDelegate(handleToReturn: noRewardHandle));
      expect(await AdService.showRewardedAd(), isFalse);

      // Load failure
      AdService.setRewardedDelegateForTesting(FakeRewardedAdDelegate(shouldFailLoad: true));
      expect(await AdService.showRewardedAd(), isFalse);
    });
  });
}

class _DelayedRewardedAdHandle implements RewardedAdHandle {
  final Completer<void> showCompleter;
  bool isDisposed = false;
  int showCallCount = 0;

  _DelayedRewardedAdHandle(this.showCompleter);

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
    showCallCount++;
    await showCompleter.future;
    onUserEarnedReward();
    onAdDismissed();
  }
}
