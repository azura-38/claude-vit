import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PinService {
  final _storage = const FlutterSecureStorage();
  static const _pinKey = 'app_pin_code';
  static const _salt = 'vitacase_pin_salt_f8a2';

  String _hashPin(String pin) {
    return sha256.convert(utf8.encode('$_salt$pin')).toString();
  }

  Future<bool> hasPin() async {
    final stored = await _storage.read(key: _pinKey);
    return stored != null && stored.isNotEmpty;
  }

  Future<void> setPin(String pin) async {
    if (pin.length != 6) throw Exception("PIN must be 6 digits");
    await _storage.write(key: _pinKey, value: _hashPin(pin));
  }

  Future<bool> verifyPin(String input) async {
    final stored = await _storage.read(key: _pinKey);
    if (stored == null) return false;

    // Migration: if stored value is exactly 4 chars, it's plaintext from old version
    if (stored.length == 4) {
      final isMatch = stored == input;
      if (isMatch) {
        // Auto-migrate to hashed storage
        await setPin(input);
      }
      return isMatch;
    }

    return stored == _hashPin(input);
  }

  Future<void> clearPin() async {
    await _storage.delete(key: _pinKey);
  }
}
