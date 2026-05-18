class AppConfig {
  /// Sentry DSN is safe to ship in a client app. Do not ship Sentry auth tokens.
  static const sentryDsn = String.fromEnvironment(
    'SENTRY_DSN',
    defaultValue: 'https://8863ed5fd9c7fe25eaa7a085a7951aba@o4511037576052736.ingest.de.sentry.io/4511200845561936',
  );

  /// AdMob App ID. AndroidManifest receives the same default through Gradle manifestPlaceholders.
  static const admobAppId = String.fromEnvironment(
    'ADMOB_APP_ID',
    defaultValue: 'ca-app-pub-5877011177866406~6901208048',
  );

  static const bannerAdId = String.fromEnvironment(
    'ADMOB_BANNER_ID',
    defaultValue: 'ca-app-pub-5877011177866406/1864503785',
  );

  static const interstitialAdId = String.fromEnvironment(
    'ADMOB_INTERSTITIAL_ID',
    defaultValue: 'ca-app-pub-5877011177866406/9551422118',
  );

  static const rewardedAdId = String.fromEnvironment(
    'ADMOB_REWARDED_ID',
    defaultValue: 'ca-app-pub-5877011177866406/2961963039',
  );

  static const appOpenAdId = String.fromEnvironment(
    'ADMOB_APP_OPEN_ID',
    defaultValue: 'ca-app-pub-5877011177866406/1720690677',
  );

  static const nativeAdId = String.fromEnvironment(
    'ADMOB_NATIVE_ID',
    defaultValue: 'ca-app-pub-5877011177866406/8238340441',
  );

  // Premium is disabled for V1.
  static const premiumEnabled = bool.fromEnvironment(
    'ENABLE_PREMIUM',
    defaultValue: false,
  );
  static const revenueCatApiKey = '';
  static const premiumMonthlyProductId = 'vitacase_premium_monthly';
  static const premiumAnnualProductId = 'vitacase_premium_annual';

  static const privacyUrl = 'https://vitacase.limanex.com/privacy';
  static const termsUrl = 'https://vitacase.limanex.com/terms';
  static const medicalDisclaimerUrl = 'https://vitacase.limanex.com/disclaimer';

  static const isLeaderboardEnabled = false;

  static bool get hasAdConfig =>
      admobAppId.isNotEmpty &&
      bannerAdId.isNotEmpty &&
      rewardedAdId.isNotEmpty &&
      appOpenAdId.isNotEmpty;

  static bool get isConfigured => hasAdConfig;

  static const isProduction = bool.fromEnvironment('dart.vm.product');
}
