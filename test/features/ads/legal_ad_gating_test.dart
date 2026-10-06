import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vitacase/core/ads/ad_visibility_policy.dart';
import 'package:vitacase/core/types/runtime_types.dart';
import 'package:vitacase/shared/data/services/ad_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 20.3.1 — Legal Gate on ALL Ad Formats (AdVisibilityPolicy)', () {
    test('All 5 ad formats are BLOCKED when legal is NOT accepted', () {
      const policy = AdVisibilityPolicy(
        bootstrapCompleted: true,
        isPremium: false,
        onboardingCompleted: true,
        profileCreated: true,
        legalAccepted: false,
        lockEnabled: false,
        lockState: AppLockState.unlocked,
      );

      // 1. Banner
      expect(policy.canShowBanner, isFalse, reason: 'Banner must be blocked when legalAccepted is false');
      // 2. Interstitial
      expect(policy.canShowInterstitial, isFalse, reason: 'Interstitial must be blocked when legalAccepted is false');
      // 3. Rewarded
      expect(policy.canShowRewarded, isFalse, reason: 'Rewarded must be blocked when legalAccepted is false');
      // 4. Rewarded Interstitial
      expect(policy.canShowRewardedInterstitial, isFalse, reason: 'Rewarded Interstitial must be blocked when legalAccepted is false');
      // 5. App Open
      expect(policy.canShowAppOpen, isFalse, reason: 'App Open must be blocked when legalAccepted is false');
    });

    test('All 5 ad formats are ALLOWED when legal IS accepted (standard policy active)', () {
      const policy = AdVisibilityPolicy(
        bootstrapCompleted: true,
        isPremium: false,
        onboardingCompleted: true,
        profileCreated: true,
        legalAccepted: true,
        lockEnabled: false,
        lockState: AppLockState.unlocked,
      );

      expect(policy.canShowBanner, isTrue, reason: 'Banner is allowed when legal is accepted');
      expect(policy.canShowInterstitial, isTrue, reason: 'Interstitial is allowed when legal is accepted');
      expect(policy.canShowRewarded, isTrue, reason: 'Rewarded is allowed when legal is accepted');
      expect(policy.canShowRewardedInterstitial, isTrue, reason: 'Rewarded Interstitial is allowed when legal is accepted');
      expect(policy.canShowAppOpen, isTrue, reason: 'App Open is allowed when legal is accepted');
    });
  });

  group('Phase 20.3.1 — Direct Presentation Gating in AdService', () {
    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/google_mobile_ads'),
        (MethodCall methodCall) async {
          return null;
        },
      );
      AdService.resetForTesting();
    });

    tearDown(() {
      AdService.resetForTesting();
    });

    test('AdService presentation calls are BLOCKED when legal_accepted is false in prefs', () async {
      SharedPreferences.setMockInitialValues({
        'legal_accepted': false,
        'legal_accepted_version': '',
      });

      final interstitialResult = await AdService.showInterstitial(ignoreCooldown: true);
      expect(interstitialResult, isFalse, reason: 'Interstitial presentation must return false when legal is unaccepted');

      final appOpenResult = await AdService.showAppOpenAd(ignoreCooldown: true);
      expect(appOpenResult, isFalse, reason: 'App Open presentation must return false when legal is unaccepted');

      final rewardedResult = await AdService.showRewardedForResult();
      expect(rewardedResult, RewardAdResult.unavailable, reason: 'Rewarded presentation must be unavailable when legal is unaccepted');
    });

    test('AdService presentation calls are BLOCKED when legal version is outdated', () async {
      SharedPreferences.setMockInitialValues({
        'legal_accepted': true,
        'legal_accepted_version': '1.0.0-2025-01', // Outdated version
      });

      final interstitialResult = await AdService.showInterstitial(ignoreCooldown: true);
      expect(interstitialResult, isFalse, reason: 'Interstitial presentation must return false when legal version is outdated');

      final appOpenResult = await AdService.showAppOpenAd(ignoreCooldown: true);
      expect(appOpenResult, isFalse, reason: 'App Open presentation must return false when legal version is outdated');

      final rewardedResult = await AdService.showRewardedForResult();
      expect(rewardedResult, RewardAdResult.unavailable, reason: 'Rewarded presentation must be unavailable when legal version is outdated');
    });
  });
}
