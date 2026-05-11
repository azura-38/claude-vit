import 'package:flutter/material.dart';
import 'package:vitacase/l10n/app_localizations.dart';
import '../constants/legal_data.dart';

class LegalContent {
  static String getPrivacyPolicy(BuildContext context) {
    final lang = _languageCode(context);
    return LegalData.getPrivacyPolicy(lang);
  }

  static String getTerms(BuildContext context) {
    final lang = _languageCode(context);
    return LegalData.getTerms(lang);
  }

  static String getDisclaimer(BuildContext context) {
    final lang = _languageCode(context);
    return LegalData.getDisclaimer(lang);
  }

  static String _languageCode(BuildContext context) {
    return AppLocalizations.of(context)?.localeName.split('_').first ?? 'en';
  }
}
