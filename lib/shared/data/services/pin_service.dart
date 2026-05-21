import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PinService {
  final _storage = const FlutterSecureStorage();
  static const _pinKey = 'app_pin_code';
  static const _pinSaltKey = 'app_pin_salt';
  static const _legacySalt = 'vitacase_pin_salt_f8a2';

  // SharedPreferences fallback keys (prefixed to avoid collisions)
  static const _spPinKey = 'sp_app_pin_code';
  static const _spSaltKey = 'sp_app_pin_salt';

  bool _useFallback = false;

  Future<String?> _secureRead(String key) async {
    if (_useFallback) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key == _pinKey ? _spPinKey : _spSaltKey);
    }
    try {
      return await _storage.read(key: key);
    } catch (e) {
      debugPrint('[PinService] SecureStorage read failed, switching to fallback: $e');
      _useFallback = true;
      // Try to read from fallback
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key == _pinKey ? _spPinKey : _spSaltKey);
    }
  }

  Future<void> _secureWrite(String key, String value) async {
    if (_useFallback) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key == _pinKey ? _spPinKey : _spSaltKey, value);
      return;
    }
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      debugPrint('[PinService] SecureStorage write failed, switching to fallback: $e');
      _useFallback = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key == _pinKey ? _spPinKey : _spSaltKey, value);
    }
  }

  Future<void> _secureDelete(String key) async {
    if (_useFallback) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key == _pinKey ? _spPinKey : _spSaltKey);
      return;
    }
    try {
      await _storage.delete(key: key);
    } catch (e) {
      debugPrint('[PinService] SecureStorage delete failed, switching to fallback: $e');
      _useFallback = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key == _pinKey ? _spPinKey : _spSaltKey);
    }
  }

  Future<String> _getOrCreateSalt() async {
    final stored = await _secureRead(_pinSaltKey);
    if (stored != null && stored.isNotEmpty) return stored;

    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    final salt = base64UrlEncode(bytes);
    await _secureWrite(_pinSaltKey, salt);
    return salt;
  }

  String _hashPin(String pin, String salt) {
    return sha256.convert(utf8.encode('$salt:$pin')).toString();
  }

  String _legacyHashPin(String pin) {
    return sha256.convert(utf8.encode('$_legacySalt$pin')).toString();
  }

  Future<bool> hasPin() async {
    final stored = await _secureRead(_pinKey);
    return stored != null && stored.isNotEmpty;
  }

  Future<void> setPin(String pin) async {
    if (pin.length != 6) throw Exception("PIN must be 6 digits");
    final salt = await _getOrCreateSalt();
    await _secureWrite(_pinKey, _hashPin(pin, salt));
  }

  Future<bool> verifyPin(String input) async {
    final stored = await _secureRead(_pinKey);
    if (stored == null) return false;

    if (stored.length == 4 || stored.length == 6) {
      final isMatch = stored == input;
      if (isMatch) {
        await setPin(input);
      }
      return isMatch;
    }

    final salt = await _getOrCreateSalt();
    if (stored == _hashPin(input, salt)) return true;

    final legacyMatch = stored == _legacyHashPin(input);
    if (legacyMatch) {
      await setPin(input);
    }
    return legacyMatch;
  }

  Future<void> clearPin() async {
    await _secureDelete(_pinKey);
    await _secureDelete(_pinSaltKey);
  }
}
