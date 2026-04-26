import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  static Future<void> log(String event, [Map<String, dynamic>? params]) async {
    // 1. Debug Logs
    if (kDebugMode) {
      if (kDebugMode) debugPrint('[Analytics] Event: $event Params: $params');
    }

    // 2. Production Metrics via Firebase Analytics
    try {
      FirebaseAnalytics.instance.logEvent(
        name: event,
        parameters: params?.cast<String, Object>(),
      );
    } catch (e) {
      if (kDebugMode) {
        if (kDebugMode) debugPrint('[FirebaseAnalytics] Failed to log event: $e');
      }
    }
  }

  static const String onboardingComplete = 'onboarding_complete';
  static const String packageSelected = 'package_selected';
  
  // Ad Events
  static const String rewardAdShown = 'reward_ad_shown';
  static const String rewardAdRewarded = 'reward_ad_rewarded';
  static const String rewardAdFailed = 'reward_ad_failed';
  static const String rewardAdUnavailable = 'reward_ad_unavailable';
  static const String rewardAdDismissed = 'reward_ad_dismissed';
  static const String adShown = 'ad_shown';
  static const String appOpenAdShown = 'app_open_ad_shown';
  static const String interstitialShown = 'interstitial_ad_shown';

  // Legal Events
  static const String termsAccepted = 'terms_accepted';
  static const String disclaimerAccepted = 'disclaimer_accepted';
  static const String privacyAccepted = 'privacy_accepted';

  // Feature Events
  static const String seasonLevelUp = 'season_level_up';
  static const String premiumClickDisabled = 'premium_click_coming_soon';
  static const String missionCompleted = 'mission_completed';

  // Data Events
  static const String backupImportSuccess = 'backup_import_success';
  static const String backupImportFail = 'backup_import_fail';
  static const String backupExportSuccess = 'backup_export_success';
  static const String medicineReminderPermissionDenied = 'medicine_permission_denied';
  static const String appointmentReminderPermissionDenied = 'appointment_permission_denied';

  // Notification Events
  static const String notificationPermissionPromptShown = 'notification_perm_prompt';
  static const String notificationPermissionResult = 'notification_perm_result';

  // App Events
  static const String appOpened = 'app_opened';
  static const String appLockEnabled = 'app_lock_enabled';
  static const String appLockDisabled = 'app_lock_disabled';
  static const String appLockAuthSuccess = 'app_lock_auth_success';
  static const String appLockAuthFail = 'app_lock_auth_fail';
  static const String biometricAuthFailed = 'biometric_auth_failed';
  static const String engagementReminderToggled = 'engagement_reminder_toggled';
  // File Context
  static const String documentAdded = 'document_added';
  static const String documentDeleted = 'document_deleted';
  static const String documentDecrypted = 'document_decrypted';
  static const String medicineAdded = 'medicine_added';
  static const String appointmentAdded = 'appointment_added';

  // Gamification Events
  static const String achievementUnlocked = 'achievement_unlocked';
  static const String comboUnlocked = 'combo_unlocked';
  static const String streakDay = 'streak_day';
  static const String streakMilestone = 'streak_milestone';
  static const String streakRecoveredWithAd = 'streak_recovered_with_ad';

  // Monetization Funnel
  static const String premiumPageView = 'premium_page_view';
  static const String limitReached = 'limit_reached';
  static const String rewardedAdForLimit = 'rewarded_ad_for_limit';

  // User Journey
  static const String profileCompleted = 'profile_completed';
  static const String themeChanged = 'theme_changed';
  static const String backupCreated = 'backup_created';
}
