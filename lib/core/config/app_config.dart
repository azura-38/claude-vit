class AppConfig {
  /// Sentry configuration — inject via: --dart-define=SENTRY_DSN=xxx
  static const sentryDsn = String.fromEnvironment(
    'SENTRY_DSN',
    defaultValue: '',
  );

  /// AdMob configuration — inject via: --dart-define=ADMOB_APP_ID=xxx
  static const admobAppId = String.fromEnvironment(
    'ADMOB_APP_ID',
    defaultValue: '',
  );
  
  // Production AdMob Unit IDs
  static const bannerAdId = 'ca-app-pub-5877011177866406/1864503785';
  static const interstitialAdId = 'ca-app-pub-5877011177866406/9551422118';
  static const rewardedAdId = 'ca-app-pub-5877011177866406/2961963039';
  static const nativeAdId = 'ca-app-pub-5877011177866406/8238340441';
  static const appOpenAdId = 'ca-app-pub-5877011177866406/1720690677';

  // Premium Configuration Placeholders
  static const premiumEnabled = false;
  static const revenueCatApiKey = ''; 
  static const premiumMonthlyProductId = 'vitacase_premium_monthly';
  static const premiumAnnualProductId = 'vitacase_premium_annual';

  static const privacyUrl = 'https://vitacase.limanex.com/privacy';
  static const termsUrl = 'https://vitacase.limanex.com/terms';
  static const medicalDisclaimerUrl = 'https://vitacase.limanex.com/disclaimer';

  /// Whether the global leaderboard is active
  static const isLeaderboardEnabled = false;

  /// Whether all required config is present
  static bool get hasAdConfig =>
      admobAppId.isNotEmpty &&
      bannerAdId.isNotEmpty &&
      rewardedAdId.isNotEmpty;

  static bool get isConfigured => hasAdConfig;

  /// Environment status
  static const isProduction = bool.fromEnvironment('dart.vm.product');
}

