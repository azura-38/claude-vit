import 'package:flutter/material.dart';
import '../constants/legal_data.dart';
import 'app_localizations.dart';

class LegalContent {
  static String getPrivacyPolicy(BuildContext context) {
    final lang = AppLocalizations.of(context)?.locale.languageCode ?? 'en';
    return LegalData.getPrivacyPolicy(lang);
  }

  static String getTerms(BuildContext context) {
    final lang = AppLocalizations.of(context)?.locale.languageCode ?? 'en';
    return LegalData.getTerms(lang);
  }

  static String getDisclaimer(BuildContext context) {
    final lang = AppLocalizations.of(context)?.locale.languageCode ?? 'en';
    return LegalData.getDisclaimer(lang);
  }
}
