import 'package:flutter/widgets.dart';
import 'package:vitacase/core/l10n/translations.dart';
import 'package:vitacase/l10n/app_localizations.dart';

extension L10nBuildContext on BuildContext {
  /// Backward-compatible translation proxy.
  ///
  /// Prefer `context.tr('snake_case_key')` in new code. The proxy exists so the
  /// current codebase can keep working while old `context.l10n.someCamelKey`
  /// calls are migrated screen by screen.
  dynamic get l10n => _L10nProxy(this);

  String tr(String key, {Map<String, String>? extra}) {
    return _lookupTranslation(this, key, extra: extra);
  }
}

class _L10nProxy {
  const _L10nProxy(this._context);

  final BuildContext _context;

  String call(String key, {Map<String, String>? extra}) {
    return _lookupTranslation(_context, key, extra: extra);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final name = _symbolName(invocation.memberName);
    if (name.isEmpty) return '';

    if (invocation.isGetter) {
      return _lookupTranslation(_context, name);
    }

    if (invocation.isMethod) {
      var value = _lookupTranslation(_context, name);
      for (final argument in invocation.positionalArguments) {
        value = value.replaceFirst(RegExp(r'\{[^}]+\}'), argument.toString());
      }
      return value;
    }

    return super.noSuchMethod(invocation);
  }
}

String _lookupTranslation(
  BuildContext context,
  String key, {
  Map<String, String>? extra,
}) {
  final locale = AppLocalizations.of(context)?.localeName ?? Localizations.localeOf(context).languageCode;
  final languageCode = locale.split('_').first;
  final normalized = _normalizeTranslationKey(key);

  var value = Translations.data[languageCode]?[normalized] ??
      Translations.data['en']?[normalized] ??
      normalized;

  if (extra == null || extra.isEmpty) return value;

  for (final entry in extra.entries) {
    value = value.replaceAll('{${entry.key}}', entry.value);
  }
  return value;
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

String _symbolName(Symbol symbol) {
  final text = symbol.toString();
  if (!text.startsWith('Symbol("') || !text.endsWith('")')) return '';
  final value = text.substring(8, text.length - 2);
  if (value.isEmpty) return '';
  return value;
}
