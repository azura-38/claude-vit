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

/// V1 keeps only fully maintained translations enabled.
/// Additional locales can be re-enabled after every visible string is translated.
const List<SupportedLanguage> supportedLanguages = [
  SupportedLanguage('en', 'English'),
  SupportedLanguage('tr', 'Türkçe'),
];

class LocaleNotifier extends Notifier<Locale> {
  static const _supportedLocales = ['en', 'tr'];

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
