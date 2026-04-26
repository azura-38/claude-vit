import 'package:flutter/material.dart';
import 'translations.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  String translate(String key, {Map<String, String>? extra}) {
    String text = Translations.data[locale.languageCode]?[key] ??
        Translations.data['en']?[key] ??
        key;

    if (extra != null) {
      extra.forEach((placeholder, value) {
        text = text.replaceAll('{$placeholder}', value);
      });
    }
    return text;
  }

  // Helper extension like context.l10n('key') is implemented in a separate utility or added here
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return [
      'en',
      'tr',
      'de',
      'es',
      'fr',
      'pt',
      'ar',
      'zh',
      'ja',
      'ko',
    ].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

extension AppLocalizationsHighlight on BuildContext {
  String l10n(String key, {Map<String, String>? extra}) {
    return AppLocalizations.of(this)?.translate(key, extra: extra) ?? key;
  }
}
