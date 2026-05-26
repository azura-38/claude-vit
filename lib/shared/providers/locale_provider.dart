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

/// V1 safe language list.
/// Other languages are temporarily disabled because their generated/runtime
/// translation packs are not fully verified yet and can cause broken UI labels.
const List<SupportedLanguage> supportedLanguages = [
  SupportedLanguage('tr', 'Türkçe'),
  SupportedLanguage('en', 'English'),
];

class LocaleNotifier extends Notifier<Locale> {
  static const _supportedLocales = ['tr', 'en'];

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
    if (systemLocale.languageCode == 'tr') {
      return const Locale('tr');
    }

    return const Locale('en');
  }

  Future<void> setLocale(String languageCode) async {
    if (!_supportedLocales.contains(languageCode)) return;
    await ref.read(userPreferencesControllerProvider.notifier).updateLocale(languageCode);
  }
}
