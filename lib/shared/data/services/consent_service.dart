import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_service.dart';

class ConsentService {
  Future<void> initializeAdsWithConsent() async {
    try {
      final params = ConsentRequestParameters();
      
      // Request consent information update from the Google Mobile Ads SDK.
      ConsentInformation.instance.requestConsentInfoUpdate(
        params,
        () async {
          // Consent info update success.
          // Check if a consent form is available and show it if required.
          ConsentForm.loadAndShowConsentFormIfRequired((formError) async {
            if (formError == null) {
              // Consent has been obtained or is not required.
              if (await ConsentInformation.instance.canRequestAds()) {
                await AdService().init();
              }
            } else {
              if (kDebugMode) debugPrint('[ConsentService] Form error: ${formError.message}');
            }
          });
        },
        (FormError error) {
          // Consent info update failure.
          if (kDebugMode) debugPrint('[ConsentService] Consent info update error: ${error.message}');
        },
      );
    } catch (e) {
      // SECURITY: Fail closed. Do NOT initialize ads when the consent flow fails.
      if (kDebugMode) debugPrint('[ConsentService] Unexpected consent error – ads suppressed: $e');
    }
  }
}
