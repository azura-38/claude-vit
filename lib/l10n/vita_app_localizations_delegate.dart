import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_localizations.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_zh.dart';

/// V1-safe localization delegate.
///
/// Supports all 10 official VitaCase languages with safe English fallback
/// on unsupported or missing locales.
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
      case 'de':
        return AppLocalizationsDe();
      case 'es':
        return AppLocalizationsEs();
      case 'fr':
        return AppLocalizationsFr();
      case 'hi':
        return AppLocalizationsHi();
      case 'it':
        return AppLocalizationsIt();
      case 'ja':
        return AppLocalizationsJa();
      case 'pt':
        return AppLocalizationsPt();
      case 'tr':
        return AppLocalizationsTr();
      case 'zh':
        return AppLocalizationsZh();
      case 'en':
      default:
        return AppLocalizationsEn();
    }
  }
}
