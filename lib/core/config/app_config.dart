import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;

class AppConfig {
  /// Sentry DSN is safe to ship in a client app. Do not ship Sentry auth tokens.
  static const sentryDsn = String.fromEnvironment(
    'SENTRY_DSN',
    defaultValue: 'https://8863ed5fd9c7fe25eaa7a085a7951aba@o4511037576052736.ingest.de.sentry.io/4511200845561936',
  );

  /// AdMob App ID. AndroidManifest receives the same default through Gradle manifestPlaceholders.
  static String get admobAppId {
    if (kDebugMode) {
      if (!kIsWeb && Platform.isAndroid) return 'ca-app-pub-3940256099942544~3347511713';
      if (!kIsWeb && Platform.isIOS) return 'ca-app-pub-3940256099942544~1458002511';
    }
    return const String.fromEnvironment(
      'ADMOB_APP_ID',
      defaultValue: 'ca-app-pub-5877011177866406~6901208048',
    );
  }

  static String get bannerAdId {
    if (kDebugMode) {
      if (!kIsWeb && Platform.isAndroid) return 'ca-app-pub-3940256099942544/6300978111';
      if (!kIsWeb && Platform.isIOS) return 'ca-app-pub-3940256099942544/2934735716';
    }
    return const String.fromEnvironment(
      'ADMOB_BANNER_ID',
      defaultValue: 'ca-app-pub-5877011177866406/4230356792',
    );
  }

  static String get interstitialAdId {
    if (kDebugMode) {
      if (!kIsWeb && Platform.isAndroid) return 'ca-app-pub-3940256099942544/1033173712';
      if (!kIsWeb && Platform.isIOS) return 'ca-app-pub-3940256099942544/4411468910';
    }
    return const String.fromEnvironment(
      'ADMOB_INTERSTITIAL_ID',
      defaultValue: 'ca-app-pub-5877011177866406/4940803235',
    );
  }

  static String get rewardedInterstitialAdId {
    if (kDebugMode) {
      if (!kIsWeb && Platform.isAndroid) return 'ca-app-pub-3940256099942544/5354046379';
      if (!kIsWeb && Platform.isIOS) return 'ca-app-pub-3940256099942544/6978759866';
    }
    return const String.fromEnvironment(
      'ADMOB_REWARDED_INTERSTITIAL_ID',
      defaultValue: 'ca-app-pub-5877011177866406/4940803235',
    );
  }

  static const closedTestFallbackEnabled = bool.fromEnvironment(
    'CLOSED_TEST_FALLBACK_ENABLED',
    defaultValue: true,
  );

  static String get rewardedAdId {
    if (kDebugMode) {
      if (!kIsWeb && Platform.isAndroid) return 'ca-app-pub-3940256099942544/5224354917';
      if (!kIsWeb && Platform.isIOS) return 'ca-app-pub-3940256099942544/1712485313';
    }
    return const String.fromEnvironment(
      'ADMOB_REWARDED_ID',
      defaultValue: 'ca-app-pub-5877011177866406/8638855182',
    );
  }

  static String get appOpenAdId {
    if (kDebugMode) {
      if (!kIsWeb && Platform.isAndroid) return 'ca-app-pub-3940256099942544/9257395921';
      if (!kIsWeb && Platform.isIOS) return 'ca-app-pub-3940256099942544/5575463023';
    }
    return const String.fromEnvironment(
      'ADMOB_APP_OPEN_ID',
      defaultValue: 'ca-app-pub-5877011177866406/3230238539',
    );
  }

  static String get nativeAdId {
    if (kDebugMode) {
      if (!kIsWeb && Platform.isAndroid) return 'ca-app-pub-3940256099942544/2247696110';
      if (!kIsWeb && Platform.isIOS) return 'ca-app-pub-3940256099942544/3986624511';
    }
    return const String.fromEnvironment(
      'ADMOB_NATIVE_ID',
      defaultValue: 'ca-app-pub-5877011177866406/4587929537',
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

  static const privacyUrl = 'https://vitacase.limanex.com/privacy';
  static const termsUrl = 'https://vitacase.limanex.com/terms';
  static const medicalDisclaimerUrl = 'https://vitacase.limanex.com/disclaimer';

  static const isLeaderboardEnabled = false;

  static bool get hasAdConfig => admobAppId.isNotEmpty;

  static bool get isConfigured => hasAdConfig;

  static const isProduction = bool.fromEnvironment('dart.vm.product');
}