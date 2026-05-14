class AppConfig {
  /// Sentry configuration — inject via build.env or --dart-define.
  static const sentryDsn = String.fromEnvironment(
    'SENTRY_DSN',
    defaultValue: '',
  );

  /// AdMob App ID — AndroidManifest receives this through Gradle manifestPlaceholders.
  /// Required format: ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY
  static const admobAppId = String.fromEnvironment(
    'ADMOB_APP_ID',
    defaultValue: '',
  );

  /// AdMob Unit IDs — inject via build.env or --dart-define.
  /// Required format: ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY
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

  /// Whether the global leaderboard is active.
  static const isLeaderboardEnabled = false;

  /// Whether all required ad config is present.
  static bool get hasAdConfig =>
      admobAppId.isNotEmpty &&
      bannerAdId.isNotEmpty &&
      rewardedAdId.isNotEmpty &&
      appOpenAdId.isNotEmpty;

  static bool get isConfigured => hasAdConfig;

  /// Environment status.
  static const isProduction = bool.fromEnvironment('dart.vm.product');
}
