import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_localizations.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_zh.dart';

/// V1-safe localization delegate.
///
/// The generated `app_localizations.dart` file currently knows the original
/// generated locales. Hindi, Japanese, and Chinese are provided by seed
/// fallback classes until the full `flutter gen-l10n` output is regenerated.
/// This delegate prevents unsupported-locale gaps without overwriting the large
/// generated file by hand.
class VitaAppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const VitaAppLocalizationsDelegate();

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
    Locale('es'),
    Locale('pt'),
    Locale('de'),
    Locale('fr'),
    Locale('it'),
    Locale('hi'),
    Locale('ja'),
    Locale('zh'),
  ];

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    VitaAppLocalizationsDelegate(),
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  @override
  bool isSupported(Locale locale) => supportedLocales.any((item) => item.languageCode == locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(_lookup(locale));
  }

  @override
  bool shouldReload(VitaAppLocalizationsDelegate old) => false;

  AppLocalizations _lookup(Locale locale) {
    switch (locale.languageCode) {
      case 'hi':
        return AppLocalizationsHi();
      case 'ja':
        return AppLocalizationsJa();
      case 'zh':
        return AppLocalizationsZh();
      default:
        return lookupAppLocalizations(locale);
    }
  }
}
