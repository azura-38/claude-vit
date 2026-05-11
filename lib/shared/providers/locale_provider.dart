import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'shared_prefs_provider.dart';

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);

class SupportedLanguage {
  final String code;
  final String name;

  const SupportedLanguage(this.code, this.name);
}

const List<SupportedLanguage> supportedLanguages = [
  SupportedLanguage('en', 'English'),
  SupportedLanguage('tr', 'Turkce'),
];

class LocaleNotifier extends Notifier<Locale> {
  static const _supportedLocales = ['en', 'tr'];

  @override
  Locale build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final code = prefs.getString(_key);
    if (code != null && _supportedLocales.contains(code)) {
      return Locale(code);
    }

    final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
    if (_supportedLocales.contains(systemLocale.languageCode)) {
      return Locale(systemLocale.languageCode);
    }

    return const Locale('en');
  }

  static const String _key = 'app_locale';
  Future<void> setLocale(String languageCode) async {
    if (!_supportedLocales.contains(languageCode)) {
      return;
    }
    state = Locale(languageCode);
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_key, languageCode);
  }
}
