import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vitacase/core/ads/ad_visibility_policy.dart';
import 'package:vitacase/core/config/app_config.dart';
import 'package:vitacase/core/types/runtime_types.dart';
import 'package:vitacase/shared/data/services/ad_service.dart';
import 'package:vitacase/shared/widgets/vitacase_banner_ad.dart';
import 'package:vitacase/shared/widgets/vitacase_shell_ad_frame.dart';

class FakeTestRewardedAdHandle implements RewardedAdHandle {
  final bool willEarnReward;
  final bool willFailShow;
  final Completer<void>? waitBeforeDismiss;
  bool isDisposed = false;

  FakeTestRewardedAdHandle({
    this.willEarnReward = true,
    this.willFailShow = false,
    this.waitBeforeDismiss,
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
    if (willFailShow) {
      onAdFailedToShow('Simulated rewarded show error');
      return;
    }
    if (willEarnReward) {
      onUserEarnedReward();
    }
    if (waitBeforeDismiss != null) {
      await waitBeforeDismiss!.future;
    }
    onAdDismissed();
  }
}

class FakeTestRewardedAdDelegate implements RewardedAdDelegate {
  final bool shouldFailLoad;
  final RewardedAdHandle? handleToReturn;
  final bool shouldThrowOnLoad;

  FakeTestRewardedAdDelegate({
    this.shouldFailLoad = false,
    this.handleToReturn,
    this.shouldThrowOnLoad = false,
  });

  @override
  Future<RewardedAdHandle?> loadRewarded(String adUnitId) async {
    if (shouldThrowOnLoad) throw Exception('Simulated rewarded load error');
    if (shouldFailLoad) return null;
    return handleToReturn ?? FakeTestRewardedAdHandle();
  }
}

class FakeTestInterstitialAdHandle implements InterstitialAdHandle {
  final bool willFailShow;
  final Completer<void>? waitBeforeDismiss;
  bool isDisposed = false;

  FakeTestInterstitialAdHandle({
    this.willFailShow = false,
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
    if (willFailShow) {
      onAdFailedToShow('Simulated interstitial show error');
      return;
    }
    onAdShowed();
    if (waitBeforeDismiss != null) {
      await waitBeforeDismiss!.future;
    }
    onAdDismissed();
  }
}

class FakeTestInterstitialAdDelegate implements InterstitialAdDelegate {
  final bool shouldFailLoad;
  final InterstitialAdHandle? handleToReturn;
  final bool shouldThrowOnLoad;

  FakeTestInterstitialAdDelegate({
    this.shouldFailLoad = false,
    this.handleToReturn,
    this.shouldThrowOnLoad = false,
  });

  @override
  Future<InterstitialAdHandle?> loadInterstitial(String adUnitId) async {
    if (shouldThrowOnLoad) throw Exception('Simulated interstitial load error');
    if (shouldFailLoad) return null;
    return handleToReturn ?? FakeTestInterstitialAdHandle();
  }
}

class FakeTestAppOpenAdHandle implements AppOpenAdHandle {
  final bool willFailShow;
  final Completer<void>? waitBeforeDismiss;
  bool isDisposed = false;

  FakeTestAppOpenAdHandle({
    this.willFailShow = false,
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
    if (willFailShow) {
      onAdFailedToShow('Simulated App Open show error');
      return;
    }
    onAdShowed();
    if (waitBeforeDismiss != null) {
      await waitBeforeDismiss!.future;
    }
    onAdDismissed();
  }
}

class FakeTestAppOpenAdDelegate implements AppOpenAdDelegate {
  final bool shouldFailLoad;
  final AppOpenAdHandle? handleToReturn;
  final bool shouldThrowOnLoad;

  FakeTestAppOpenAdDelegate({
    this.shouldFailLoad = false,
    this.handleToReturn,
    this.shouldThrowOnLoad = false,
  });

  @override
  Future<AppOpenAdHandle?> loadAppOpen(String adUnitId) async {
    if (shouldThrowOnLoad) throw Exception('Simulated App Open load error');
    if (shouldFailLoad) return null;
    return handleToReturn ?? FakeTestAppOpenAdHandle();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(
      'plugins.flutter.io/google_mobile_ads',
      (ByteData? message) async {
        return const StandardMethodCodec().encodeSuccessEnvelope(null);
      },
    );
    SharedPreferences.setMockInitialValues({});
    AdService.resetForTesting();
  });

  tearDown(() {
    AdService.resetForTesting();
  });

  group('Phase 15 Ads Integration Tests (A - J)', () {
    testWidgets('A. Banner lifecycle: mount and dispose cleanly with policy active', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            adVisibilityPolicyProvider.overrideWithValue(
              const AdVisibilityPolicy(
                bootstrapCompleted: true,
                isPremium: false,
                onboardingCompleted: true,
                profileCreated: true,
                lockEnabled: false,
                lockState: AppLockState.unlocked,
              ),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: VitaCaseBannerAd(),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(VitaCaseBannerAd), findsOneWidget);

      // Unmount widget to verify safe disposal without exceptions
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: SizedBox())));
      await tester.pump();

      expect(find.byType(VitaCaseBannerAd), findsNothing);
    });

    testWidgets('B. Banner load-before-widget: AdWidget is never inserted before ad load completes', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            adVisibilityPolicyProvider.overrideWithValue(
              const AdVisibilityPolicy(
                bootstrapCompleted: true,
                isPremium: false,
                onboardingCompleted: true,
                profileCreated: true,
                lockEnabled: false,
                lockState: AppLockState.unlocked,
              ),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: VitaCaseBannerAd(),
            ),
          ),
        ),
      );
      await tester.pump();

      // Before onAdLoaded callback fires, AdWidget must NOT be in the tree
      expect(find.byType(AdWidget), findsNothing);
    });

    testWidgets('C. Banner duplicate protection: single shell frame wraps content without duplicates', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            adVisibilityPolicyProvider.overrideWithValue(
              const AdVisibilityPolicy(
                bootstrapCompleted: true,
                isPremium: false,
                onboardingCompleted: true,
                profileCreated: true,
                lockEnabled: false,
                lockState: AppLockState.unlocked,
              ),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: VitaCaseShellAdFrame(
                showBanner: true,
                child: Text('Main Shell Content'),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(VitaCaseBannerAd), findsOneWidget);
      expect(find.text('Main Shell Content'), findsOneWidget);
    });

    test('D. Rewarded integration: user action triggers ad and delivers earned reward', () async {
      AdService.setRewardedDelegateForTesting(
        FakeTestRewardedAdDelegate(
          handleToReturn: FakeTestRewardedAdHandle(willEarnReward: true),
        ),
      );

      final result = await AdService.showRewardedForResult();
      expect(result, RewardAdResult.shownRewarded);
      expect(AdService.rewardedState, RewardedAdState.earned);
    });

    test('E. Interstitial integration: successful show records cooldown timestamp', () async {
      AdService.setInterstitialDelegateForTesting(
        FakeTestInterstitialAdDelegate(
          handleToReturn: FakeTestInterstitialAdHandle(),
        ),
      );

      final success = await AdService.showInterstitial(ignoreCooldown: true);
      expect(success, isTrue);
      expect(AdService.interstitialState, InterstitialAdState.dismissed);
      expect(AdService().lastInterstitialShown, isNotNull);
    });

    test('F. App Open integration: successful show records cooldown timestamp', () async {
      AdService.setAppOpenDelegateForTesting(
        FakeTestAppOpenAdDelegate(
          handleToReturn: FakeTestAppOpenAdHandle(),
        ),
      );

      final success = await AdService.showAppOpenAd(ignoreCooldown: true);
      expect(success, isTrue);
      expect(AdService.appOpenState, AppOpenAdState.dismissed);
      expect(AdService().lastAppOpenShown, isNotNull);
    });

    test('G. Fullscreen mutual exclusion: Rewarded, Interstitial and App Open mutually exclude each other', () async {
      final rewardedHold = Completer<void>();
      AdService.setRewardedDelegateForTesting(
        FakeTestRewardedAdDelegate(
          handleToReturn: FakeTestRewardedAdHandle(waitBeforeDismiss: rewardedHold),
        ),
      );
      AdService.setInterstitialDelegateForTesting(FakeTestInterstitialAdDelegate());
      AdService.setAppOpenDelegateForTesting(FakeTestAppOpenAdDelegate());

      // 1. Start showing Rewarded
      final rewardedFuture = AdService.showRewardedForResult();
      await Future.delayed(const Duration(milliseconds: 20));

      expect(AdService.isRewardedAdShowing, isTrue);
      expect(AdService.isAnyFullscreenAdShowing, isTrue);

      // Rewarded is showing -> Interstitial and App Open MUST be blocked
      final interstitialBlocked = await AdService.showInterstitial(ignoreCooldown: true);
      expect(interstitialBlocked, isFalse);

      final appOpenBlocked = await AdService.showAppOpenAd(ignoreCooldown: true);
      expect(appOpenBlocked, isFalse);

      // Complete Rewarded ad
      rewardedHold.complete();
      await rewardedFuture;
      expect(AdService.isRewardedAdShowing, isFalse);

      // 2. Start showing Interstitial
      final interstitialHold = Completer<void>();
      AdService.setInterstitialDelegateForTesting(
        FakeTestInterstitialAdDelegate(
          handleToReturn: FakeTestInterstitialAdHandle(waitBeforeDismiss: interstitialHold),
        ),
      );

      final interstitialFuture = AdService.showInterstitial(ignoreCooldown: true);
      await Future.delayed(const Duration(milliseconds: 20));

      expect(AdService.isInterstitialAdShowing, isTrue);

      // Interstitial is showing -> Rewarded and App Open MUST be blocked
      final rewardedBlocked = await AdService.showRewardedForResult();
      expect(rewardedBlocked, RewardAdResult.unavailable);

      final appOpenBlocked2 = await AdService.showAppOpenAd(ignoreCooldown: true);
      expect(appOpenBlocked2, isFalse);

      // Complete Interstitial ad
      interstitialHold.complete();
      await interstitialFuture;
      expect(AdService.isInterstitialAdShowing, isFalse);

      // 3. Start showing App Open
      final appOpenHold = Completer<void>();
      AdService.setAppOpenDelegateForTesting(
        FakeTestAppOpenAdDelegate(
          handleToReturn: FakeTestAppOpenAdHandle(waitBeforeDismiss: appOpenHold),
        ),
      );

      final appOpenFuture = AdService.showAppOpenAd(ignoreCooldown: true);
      await Future.delayed(const Duration(milliseconds: 20));

      expect(AdService.isAppOpenAdShowing, isTrue);

      // App Open is showing -> Rewarded and Interstitial MUST be blocked
      final rewardedBlocked2 = await AdService.showRewardedForResult();
      expect(rewardedBlocked2, RewardAdResult.unavailable);

      final interstitialBlocked2 = await AdService.showInterstitial(ignoreCooldown: true);
      expect(interstitialBlocked2, isFalse);

      // Complete App Open ad
      appOpenHold.complete();
      await appOpenFuture;
      expect(AdService.isAppOpenAdShowing, isFalse);
    });

    test('H. Cooldown behavior: suppresses consecutive shows within cooldown windows', () async {
      AdService.setInterstitialDelegateForTesting(FakeTestInterstitialAdDelegate());
      AdService.setAppOpenDelegateForTesting(FakeTestAppOpenAdDelegate());

      // Interstitial cooldown (90 seconds)
      final firstInterstitial = await AdService.showInterstitial(ignoreCooldown: true);
      expect(firstInterstitial, isTrue);

      final duplicateInterstitial = await AdService.showInterstitial(ignoreCooldown: false);
      expect(duplicateInterstitial, isFalse); // Suppressed by 90s cooldown

      // App Open cooldown (300 seconds)
      final firstAppOpen = await AdService.showAppOpenAd(ignoreCooldown: true);
      expect(firstAppOpen, isTrue);

      final duplicateAppOpen = await AdService.showAppOpenAd(ignoreCooldown: false);
      expect(duplicateAppOpen, isFalse); // Suppressed by 300s cooldown
    });

    test('I. Lifecycle safety: resetForTesting cleanly resets handles and state', () async {
      AdService.setRewardedDelegateForTesting(FakeTestRewardedAdDelegate());
      AdService.setInterstitialDelegateForTesting(FakeTestInterstitialAdDelegate());
      AdService.setAppOpenDelegateForTesting(FakeTestAppOpenAdDelegate());

      await AdService.loadInterstitialAd();
      await AdService().loadRewarded();
      await AdService.loadAppOpenAd();

      expect(AdService.isInterstitialAdAvailable, isTrue);
      expect(AdService.isRewardedAdAvailable, isTrue);
      expect(AdService.isAppOpenAdAvailable, isTrue);

      AdService.resetForTesting();

      expect(AdService.isInterstitialAdAvailable, isFalse);
      expect(AdService.isRewardedAdAvailable, isFalse);
      expect(AdService.isAppOpenAdAvailable, isFalse);
      expect(AdService.isAnyFullscreenAdShowing, isFalse);
      expect(AdService.interstitialState, InterstitialAdState.idle);
      expect(AdService.rewardedState, RewardedAdState.idle);
      expect(AdService.appOpenState, AppOpenAdState.idle);
    });

    test('J. Ad failure does not block app or throw unhandled exceptions', () async {
      // 1. Rewarded load throws exception
      AdService.setRewardedDelegateForTesting(
        FakeTestRewardedAdDelegate(shouldThrowOnLoad: true),
      );
      final rewardedResult = await AdService.showRewardedForResult();
      expect(rewardedResult, RewardAdResult.unavailable);

      // 2. Interstitial load throws exception
      AdService.setInterstitialDelegateForTesting(
        FakeTestInterstitialAdDelegate(shouldThrowOnLoad: true),
      );
      final interstitialResult = await AdService.showInterstitial(ignoreCooldown: true);
      expect(interstitialResult, isFalse);

      // 3. App Open load throws exception
      AdService.setAppOpenDelegateForTesting(
        FakeTestAppOpenAdDelegate(shouldThrowOnLoad: true),
      );
      final appOpenResult = await AdService.showAppOpenAd(ignoreCooldown: true);
      expect(appOpenResult, isFalse);

      // App is never locked in a showing or loading state
      expect(AdService.isAnyFullscreenAdShowing, isFalse);
    });

    test('K. Ads Mode Policy: Phase 15-19 enforces test ad IDs while production IDs remain safely configured for Phase 20', () {
      // 1. Verify test mode is active
      expect(AppConfig.isProductionAdsActive, isFalse);

      // 2. Verify all active getters serve Google test ad units
      expect(AppConfig.bannerAdId, contains('3940256099942544'));
      expect(AppConfig.interstitialAdId, contains('3940256099942544'));
      expect(AppConfig.rewardedAdId, contains('3940256099942544'));
      expect(AppConfig.appOpenAdId, contains('3940256099942544'));

      expect(AppConfig.prodBannerAdId, equals('ca-app-pub-5877011177866406/8010224598'));
      expect(AppConfig.prodInterstitialAdId, equals('ca-app-pub-5877011177866406/9281662404'));
      expect(AppConfig.prodRewardedInterstitialAdId, equals('ca-app-pub-5877011177866406/4940803235'));
      expect(AppConfig.prodInterstitialAdId, isNot(equals(AppConfig.prodRewardedInterstitialAdId)));
      expect(AppConfig.prodRewardedAdId, equals('ca-app-pub-5877011177866406/8638855182'));
      expect(AppConfig.prodAppOpenAdId, equals('ca-app-pub-5877011177866406/3230238539'));
      expect(AppConfig.prodAdmobAppId, equals('ca-app-pub-5877011177866406~6901208048'));
    });
  });
}
