import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;

class AppConfig {
  /// Sentry DSN is safe to ship in a client app. Do not ship Sentry auth tokens.
  static const sentryDsn = String.fromEnvironment(
    'SENTRY_DSN',
    defaultValue: 'https://8863ed5fd9c7fe25eaa7a085a7951aba@o4511037576052736.ingest.de.sentry.io/4511200845561936',
  );

  /// Production Ads Activation Flag.
  /// Activated for Phase 20 Production Release.
  /// Defaults to true in release mode (!kDebugMode) to enable live AdMob units.
  /// Defaults to false in debug/test mode (kDebugMode) to protect against policy violations.
  static const bool isProductionAdsActive = bool.fromEnvironment(
    'ENABLE_PRODUCTION_ADS',
    defaultValue: !kDebugMode,
  );

  // Production AdMob IDs (Scheduled for activation in Phase 20)
  static const String prodAdmobAppId = 'ca-app-pub-5877011177866406~6901208048';
  /// Officially verified Banner ID from latest Google AdMob placement document.
  static const String prodBannerAdId = 'ca-app-pub-5877011177866406/8010224598';
  /// Officially verified Interstitial ID from latest Google AdMob placement document.
  static const String prodInterstitialAdId = 'ca-app-pub-5877011177866406/9281662404';
  static const String prodRewardedAdId = 'ca-app-pub-5877011177866406/8638855182';
  static const String prodAppOpenAdId = 'ca-app-pub-5877011177866406/3230238539';
  /// Officially verified Rewarded Interstitial ID from Google AdMob placement document.
  static const String prodRewardedInterstitialAdId = 'ca-app-pub-5877011177866406/4940803235';
  static const String prodNativeAdId = 'ca-app-pub-5877011177866406/4587929537';

  // Google Test AdMob IDs (Active during Phase 15-19)
  static const String testAndroidAppId = 'ca-app-pub-3940256099942544~3347511713';
  static const String testIosAppId = 'ca-app-pub-3940256099942544~1458002511';
  static const String testAndroidBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String testIosBannerId = 'ca-app-pub-3940256099942544/2934735716';
  static const String testAndroidInterstitialId = 'ca-app-pub-3940256099942544/1033173712';
  static const String testIosInterstitialId = 'ca-app-pub-3940256099942544/4411468910';
  static const String testAndroidRewardedId = 'ca-app-pub-3940256099942544/5224354917';
  static const String testIosRewardedId = 'ca-app-pub-3940256099942544/1712485313';
  static const String testAndroidAppOpenId = 'ca-app-pub-3940256099942544/9257395921';
  static const String testIosAppOpenId = 'ca-app-pub-3940256099942544/5575463023';
  static const String testAndroidRewardedInterstitialId = 'ca-app-pub-3940256099942544/5354046379';
  static const String testIosRewardedInterstitialId = 'ca-app-pub-3940256099942544/6978759866';
  static const String testAndroidNativeId = 'ca-app-pub-3940256099942544/2247696110';
  static const String testIosNativeId = 'ca-app-pub-3940256099942544/3986624511';

  /// AdMob App ID. AndroidManifest receives the same default through Gradle manifestPlaceholders.
  static String get admobAppId {
    if (!isProductionAdsActive || kDebugMode) {
      if (!kIsWeb && Platform.isAndroid) return testAndroidAppId;
      if (!kIsWeb && Platform.isIOS) return testIosAppId;
      return testAndroidAppId;
    }
    return const String.fromEnvironment(
      'ADMOB_APP_ID',
      defaultValue: prodAdmobAppId,
    );
  }

  static String get bannerAdId {
    if (!isProductionAdsActive || kDebugMode) {
      if (!kIsWeb && Platform.isAndroid) return testAndroidBannerId;
      if (!kIsWeb && Platform.isIOS) return testIosBannerId;
      return testAndroidBannerId;
    }
    return const String.fromEnvironment(
      'ADMOB_BANNER_ID',
      defaultValue: prodBannerAdId,
    );
  }

  /// Whether a distinct, verified production Interstitial ID is configured.
  static bool get isProductionInterstitialVerified =>
      prodInterstitialAdId.isNotEmpty &&
      prodInterstitialAdId != prodRewardedInterstitialAdId;

  static String get interstitialAdId {
    if (!isProductionAdsActive || kDebugMode) {
      if (!kIsWeb && Platform.isIOS) return testIosInterstitialId;
      return testAndroidInterstitialId;
    }
    const envId = String.fromEnvironment(
      'ADMOB_INTERSTITIAL_ID',
      defaultValue: prodInterstitialAdId,
    );
    if (envId.isEmpty || envId == prodRewardedInterstitialAdId) {
      return '';
    }
    return envId;
  }

  static String get rewardedInterstitialAdId {
    if (!isProductionAdsActive || kDebugMode) {
      if (!kIsWeb && Platform.isAndroid) return testAndroidRewardedInterstitialId;
      if (!kIsWeb && Platform.isIOS) return testIosRewardedInterstitialId;
      return testAndroidRewardedInterstitialId;
    }
    return const String.fromEnvironment(
      'ADMOB_REWARDED_INTERSTITIAL_ID',
      defaultValue: prodRewardedInterstitialAdId,
    );
  }

  static const closedTestFallbackEnabled = bool.fromEnvironment(
    'CLOSED_TEST_FALLBACK_ENABLED',
    defaultValue: true,
  );

  static String get rewardedAdId {
    if (!isProductionAdsActive || kDebugMode) {
      if (!kIsWeb && Platform.isIOS) return testIosRewardedId;
      return testAndroidRewardedId;
    }
    return const String.fromEnvironment(
      'ADMOB_REWARDED_ID',
      defaultValue: prodRewardedAdId,
    );
  }

  static String get appOpenAdId {
    if (!isProductionAdsActive || kDebugMode) {
      if (!kIsWeb && Platform.isIOS) return testIosAppOpenId;
      return testAndroidAppOpenId;
    }
    return const String.fromEnvironment(
      'ADMOB_APP_OPEN_ID',
      defaultValue: prodAppOpenAdId,
    );
  }

  static String get nativeAdId {
    if (!isProductionAdsActive || kDebugMode) {
      if (!kIsWeb && Platform.isAndroid) return testAndroidNativeId;
      if (!kIsWeb && Platform.isIOS) return testIosNativeId;
      return testAndroidNativeId;
    }
    return const String.fromEnvironment(
      'ADMOB_NATIVE_ID',
      defaultValue: prodNativeAdId,
    );
  }

  // Premium is disabled for V1.
  static const premiumEnabled = bool.fromEnvironment(
    'ENABLE_PREMIUM',
    defaultValue: false,
  );
  static const revenueCatApiKey = '';
  static const premiumMonthlyProductId = 'vitacase_premium_monthly';
  static const premiumAnnualProductId = 'vitacase_premium_annual';

  // Planned for V1.2 / V1.3. Disabled in V1.
  // When enabled: every 1000 XP grants 1 automatic daily-limit unlock token.
  static const adSkipRewardsEnabled = bool.fromEnvironment(
    'ENABLE_AD_SKIP_REWARDS',
    defaultValue: false,
  );
  static const xpPerAdSkipToken = int.fromEnvironment(
    'XP_PER_AD_SKIP_TOKEN',
    defaultValue: 1000,
  );
  static const adSkipRewardsTargetVersion = 'V1.2 / V1.3';

  static const privacyUrl = 'https://limanexstudio.com/privacy/vitacase';
  static const termsUrl = 'https://limanexstudio.com/terms/vitacase';
  static const medicalDisclaimerUrl = 'https://limanexstudio.com/disclaimer/vitacase';

  static const isLeaderboardEnabled = false;

  static bool get hasAdConfig => admobAppId.isNotEmpty;

  static bool get isConfigured => hasAdConfig;

  static const isProduction = bool.fromEnvironment('dart.vm.product');
}