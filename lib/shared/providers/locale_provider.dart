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

const List<SupportedLanguage> supportedLanguages = [
  SupportedLanguage('en', 'English'),
  SupportedLanguage('tr', 'Türkçe'),
  SupportedLanguage('de', 'Deutsch'),
  SupportedLanguage('fr', 'Français'),
  SupportedLanguage('es', 'Español'),
  SupportedLanguage('it', 'Italiano'),
  SupportedLanguage('pt', 'Português'),
];

class LocaleNotifier extends Notifier<Locale> {
  static const _supportedLocales = ['en', 'tr', 'de', 'fr', 'es', 'it', 'pt'];

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
    if (!_supportedLocales.contains(languageCode)) {
      return;
    }
    await ref.read(userPreferencesControllerProvider.notifier).updateLocale(languageCode);
  }
}
