import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../core/config/app_config.dart';
import 'ad_service.dart';

class ConsentService {
  static final ConsentService _instance = ConsentService._internal();
  factory ConsentService() => _instance;
  ConsentService._internal();

  @visibleForTesting
  static bool? canRequestAdsOverrideForTesting;

  /// Checks whether UMP consent allows ad requests.
  /// Fails closed (returns false) if error occurs or ads are not configured.
  /// Legal terms acceptance is NOT treated as UMP consent.
  static Future<bool> canRequestAds() async {
    if (canRequestAdsOverrideForTesting != null) {
      return canRequestAdsOverrideForTesting!;
    }
    if (kIsWeb || !AppConfig.hasAdConfig) return false;
    try {
      return await ConsentInformation.instance.canRequestAds();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ConsentService] canRequestAds check error: $e');
      }
      return false;
    }
  }

  Future<void> initializeAdsWithConsent() async {
    if (kIsWeb || !AppConfig.hasAdConfig) return;
    try {
      final params = ConsentRequestParameters();

      // Request consent information update from the Google Mobile Ads SDK.
      ConsentInformation.instance.requestConsentInfoUpdate(
        params,
        () async {
          // Consent info update success.
          // Check if a consent form is available and show it if required.
          ConsentForm.loadAndShowConsentFormIfRequired((formError) async {
            if (formError != null && kDebugMode) {
              debugPrint('[ConsentService] Form error: ${formError.message}');
            }
            // NOTE: AdService().init() is handled exclusively in Phase 3 of bootstrap.
            // We do not re-run AdService().init() here to avoid duplicate SDK initialization paths.
          });
        },
        (FormError error) {
          // Consent info update failure.
          if (kDebugMode) {
            debugPrint(
              '[ConsentService] Consent info update error: ${error.message}',
            );
          }
        },
      );
    } catch (e) {
      // SECURITY: Fail closed. Do NOT initialize ads when the consent flow fails.
      if (kDebugMode) {
        debugPrint(
          '[ConsentService] Unexpected consent error – ads suppressed: $e',
        );
      }
    }
  }
}
