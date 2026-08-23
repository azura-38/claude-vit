import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_service.dart';

class ConsentService {
  Future<void> initializeAdsWithConsent() async {
    final completer = Completer<void>();

    try {
      final params = ConsentRequestParameters();

      ConsentInformation.instance.requestConsentInfoUpdate(
        params,
        () async {
          ConsentForm.loadAndShowConsentFormIfRequired((formError) async {
            try {
              if (await ConsentInformation.instance.canRequestAds()) {
                await AdService().init();
              } else {
                await AdService().init();
              }
            } catch (e) {
              if (kDebugMode) {
                debugPrint('[ConsentService] Error showing form/init: $e');
              }
              await AdService().init();
            } finally {
              if (!completer.isCompleted) completer.complete();
            }
          });
        },
        (FormError error) async {
          if (kDebugMode) {
            debugPrint(
              '[ConsentService] Consent info update error: ${error.message}',
            );
          }
          await AdService().init();
          if (!completer.isCompleted) completer.complete();
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[ConsentService] Unexpected consent error – fallback init: $e',
        );
      }
      await AdService().init();
      if (!completer.isCompleted) completer.complete();
    }

    return completer.future.timeout(
      const Duration(seconds: 4),
      onTimeout: () async {
        if (kDebugMode) {
          debugPrint('[ConsentService] Initialization timed out after 4s – starting AdService in background');
        }
        await AdService().init();
        if (!completer.isCompleted) completer.complete();
      },
    );
  }
}
