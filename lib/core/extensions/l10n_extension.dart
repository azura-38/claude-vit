import 'package:flutter/widgets.dart';
import 'package:vitacase/core/l10n/translations.dart';
import 'package:vitacase/l10n/app_localizations.dart';

extension L10nBuildContext on BuildContext {
  dynamic get l10n => _L10nProxy(AppLocalizations.of(this), this);
}

class _L10nProxy {
  const _L10nProxy(this._generated, this._context);

  final AppLocalizations? _generated;
  final BuildContext _context;

  String call(String key, {Map<String, String>? extra}) {
    final value = _lookup(key);
    if (extra == null || extra.isEmpty) return value;

    var formatted = value;
    for (final entry in extra.entries) {
      formatted = formatted.replaceAll('{${entry.key}}', entry.value);
    }
    return formatted;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final name = _symbolName(invocation.memberName);
    if (invocation.isGetter) {
      return _lookup(name);
    }

    if (invocation.isMethod) {
      var value = _lookup(name);
      for (final argument in invocation.positionalArguments) {
        value = value.replaceFirst(RegExp(r'\{[^}]+\}'), argument.toString());
      }
      return value;
    }

    return super.noSuchMethod(invocation);
  }

  String _lookup(String key) {
    final locale = _generated?.localeName ?? Localizations.localeOf(_context).languageCode;
    final normalized = _normalizeKey(key);
    final languageCode = locale.split('_').first;

    return Translations.data[languageCode]?[normalized] ??
        Translations.data['en']?[normalized] ??
        key;
  }

  static String _normalizeKey(String key) {
    if (key.contains('_')) return key;
    final buffer = StringBuffer();
    for (var i = 0; i < key.length; i++) {
      final char = key[i];
      final isUpper = char.toUpperCase() == char && char.toLowerCase() != char;
      final previous = i > 0 ? key[i - 1] : '';
      final previousIsDigit = previous.codeUnitAt(0) >= 48 && previous.codeUnitAt(0) <= 57;
      final isDigit = char.codeUnitAt(0) >= 48 && char.codeUnitAt(0) <= 57;
      if (i > 0 &&
          (isUpper ||
              isDigit && !previousIsDigit ||
              previousIsDigit && char.toUpperCase() != char)) {
        buffer.write('_');
      }
      buffer.write(char.toLowerCase());
    }
    return buffer.toString();
  }

  static String _symbolName(Symbol symbol) {
    final text = symbol.toString();
    return text.substring(8, text.length - 2);
  }
}
