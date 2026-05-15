import 'package:flutter/widgets.dart';
import 'package:vitacase/core/l10n/translations.dart';
import 'package:vitacase/l10n/app_localizations.dart';

extension L10nBuildContext on BuildContext {
  /// Generated localization getters.
  ///
  /// Important: this must not use noSuchMethod/Symbol based proxying. Flutter
  /// Web and release/minified builds can rename member symbols, causing UI text
  /// keys to appear as short random strings such as xci/ggt.
  AppLocalizations get l10n => AppLocalizations.of(this)!;

  /// Dynamic runtime translation lookup for string keys such as good_morning.
  String tr(String key, {Map<String, String>? extra}) {
    final locale = AppLocalizations.of(this)?.localeName ?? Localizations.localeOf(this).languageCode;
    final languageCode = locale.split('_').first;
    final normalized = _normalizeTranslationKey(key);

    var value = Translations.data[languageCode]?[normalized] ??
        Translations.data['en']?[normalized] ??
        key;

    if (extra == null || extra.isEmpty) return value;

    for (final entry in extra.entries) {
      value = value.replaceAll('{${entry.key}}', entry.value);
    }
    return value;
  }
}

String _normalizeTranslationKey(String key) {
  if (key.isEmpty || key.contains('_')) return key;

  final buffer = StringBuffer();
  for (var i = 0; i < key.length; i++) {
    final char = key[i];
    final isUpper = char.toUpperCase() == char && char.toLowerCase() != char;
    final isDigit = _isDigit(char);
    final previous = i > 0 ? key[i - 1] : null;
    final previousIsDigit = previous != null && _isDigit(previous);

    if (i > 0 && (isUpper || (isDigit && !previousIsDigit))) {
      buffer.write('_');
    }
    buffer.write(char.toLowerCase());
  }
  return buffer.toString();
}

bool _isDigit(String value) {
  if (value.isEmpty) return false;
  final code = value.codeUnitAt(0);
  return code >= 48 && code <= 57;
}
