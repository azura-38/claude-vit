import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'user_preferences_controller.dart';

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);

class SupportedLanguage {
  final String code;
  final String name;

  const SupportedLanguage(this.code, this.name);
}

/// V1 language list.
/// hi/ja/zh use runtime fallback for any untranslated ARB key until the full
/// generated localization pack is produced.
const List<SupportedLanguage> supportedLanguages = [
  SupportedLanguage('en', 'English'),
  SupportedLanguage('tr', 'Türkçe'),
  SupportedLanguage('es', 'Español'),
  SupportedLanguage('pt', 'Português'),
  SupportedLanguage('de', 'Deutsch'),
  SupportedLanguage('fr', 'Français'),
  SupportedLanguage('it', 'Italiano'),
  SupportedLanguage('hi', 'हिन्दी'),
  SupportedLanguage('ja', '日本語'),
  SupportedLanguage('zh', '简体中文'),
];

class LocaleNotifier extends Notifier<Locale> {
  static const _supportedLocales = [
    'en',
    'tr',
    'es',
    'pt',
    'de',
    'fr',
    'it',
    'hi',
    'ja',
    'zh',
  ];

  @override
  Locale build() {
    final prefs = ref.watch(userPreferencesControllerProvider);
    final code = prefs.maybeWhen(
      data: (p) => p.locale,
      orElse: () => null,
    );

    if (code != null && _supportedLocales.contains(code)) {
      return Locale(code);
    }

    final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
    if (_supportedLocales.contains(systemLocale.languageCode)) {
      return Locale(systemLocale.languageCode);
    }

    return const Locale('en');
  }

  Future<void> setLocale(String languageCode) async {
    if (!_supportedLocales.contains(languageCode)) return;
    await ref.read(userPreferencesControllerProvider.notifier).updateLocale(languageCode);
  }
}
