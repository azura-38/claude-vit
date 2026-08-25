import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Exception thrown when secure storage operations fail.
class PinStorageException implements Exception {
  final String message;
  const PinStorageException(this.message);

  @override
  String toString() => 'PinStorageException: $message';
}

class PinService {
  final FlutterSecureStorage _storage;
  final SharedPreferences? _prefs;

  PinService({
    FlutterSecureStorage? storage,
    SharedPreferences? prefs,
  })  : _storage = storage ?? const FlutterSecureStorage(),
        _prefs = prefs;

  static const _pinKey = 'app_pin_code';
  static const _pinSaltKey = 'app_pin_salt';
  static const _legacySalt = 'vitacase_pin_salt_f8a2';

  // Legacy SharedPreferences keys for migration
  static const _legacySpPinKey = 'sp_app_pin_code';
  static const _legacySpSaltKey = 'sp_app_pin_salt';
  static const _legacyUserPinKey = 'user_pin';

  Future<SharedPreferences> _getPrefs() async {
    return _prefs ?? await SharedPreferences.getInstance();
  }

  Future<String> _getOrCreateSalt() async {
    try {
      final stored = await _storage.read(key: _pinSaltKey);
      if (stored != null && stored.isNotEmpty) return stored;

      final random = Random.secure();
      final bytes = List<int>.generate(32, (_) => random.nextInt(256));
      final salt = base64UrlEncode(bytes);
      await _storage.write(key: _pinSaltKey, value: salt);
      return salt;
    } catch (e) {
      debugPrint('[PinService] Failed to access or generate salt in SecureStorage: $e');
      throw const PinStorageException('Secure storage unavailable for PIN salt');
    }
  }

  String _hashPin(String pin, String salt) {
    return sha256.convert(utf8.encode('$salt:$pin')).toString();
  }

  String _legacyHashPin(String pin) {
    return sha256.convert(utf8.encode('$_legacySalt$pin')).toString();
  }

  /// Checks if a PIN exists in secure storage or legacy storage.
  Future<bool> hasPin() async {
    try {
      final stored = await _storage.read(key: _pinKey);
      if (stored != null && stored.isNotEmpty) return true;
    } catch (e) {
      debugPrint('[PinService] SecureStorage read error during hasPin: $e');
    }

    // Check legacy SharedPreferences locations for migration candidates
    try {
      final prefs = await _getPrefs();
      final legacySp = prefs.getString(_legacySpPinKey);
      if (legacySp != null && legacySp.isNotEmpty) return true;
      final legacyUser = prefs.getString(_legacyUserPinKey);
      if (legacyUser != null && legacyUser.isNotEmpty) return true;
    } catch (e) {
      debugPrint('[PinService] SharedPreferences read error during hasPin: $e');
    }

    return false;
  }

  /// Sets a new 6-digit PIN. Always stored with cryptographic salt in SecureStorage.
  /// Never written as plaintext or to SharedPreferences.
  Future<void> setPin(String pin) async {
    if (pin.length != 6) throw ArgumentError('PIN must be exactly 6 digits');
    if (!RegExp(r'^\d{6}$').hasMatch(pin)) throw ArgumentError('PIN must contain only digits');

    try {
      final salt = await _getOrCreateSalt();
      final hashedPin = _hashPin(pin, salt);
      await _storage.write(key: _pinKey, value: hashedPin);

      // Clean up any legacy plaintext keys from SharedPreferences
      await _cleanLegacyStorage();
    } catch (e) {
      if (e is ArgumentError || e is PinStorageException) rethrow;
      debugPrint('[PinService] Failed to write PIN to SecureStorage: $e');
      throw const PinStorageException('Secure storage unavailable for setting PIN');
    }
  }

  /// Verifies PIN input against secure storage or performs on-the-fly legacy migration.
  Future<bool> verifyPin(String input) async {
    if (input.isEmpty) return false;

    String? stored;
    bool isFromSecureStorage = false;

    try {
      stored = await _storage.read(key: _pinKey);
      if (stored != null && stored.isNotEmpty) {
        isFromSecureStorage = true;
      }
    } catch (e) {
      debugPrint('[PinService] SecureStorage read error during verifyPin: $e');
    }

    // If not found in secure storage, check legacy SharedPreferences
    if (stored == null || stored.isEmpty) {
      try {
        final prefs = await _getPrefs();
        stored = prefs.getString(_legacySpPinKey) ?? prefs.getString(_legacyUserPinKey);
      } catch (e) {
        debugPrint('[PinService] SharedPreferences read error during legacy verifyPin: $e');
      }
    }

    if (stored == null || stored.isEmpty) return false;

    // Case 1: Legacy Plaintext PIN (4 or 6 digits)
    if (stored.length == 4 || stored.length == 6) {
      final isMatch = stored == input;
      if (isMatch) {
        // Migrate to secure storage if valid 6-digit PIN
        if (input.length == 6) {
          try {
            await setPin(input);
          } catch (e) {
            debugPrint('[PinService] Non-fatal error during legacy PIN migration: $e');
          }
        }
        await _cleanLegacyStorage();
      }
      return isMatch;
    }

    // Case 2: Modern Secure Storage Salted Hash
    if (isFromSecureStorage) {
      try {
        final salt = await _storage.read(key: _pinSaltKey);
        if (salt != null && stored == _hashPin(input, salt)) {
          return true;
        }
      } catch (e) {
        debugPrint('[PinService] Verification hash comparison error: $e');
      }
    }

    // Case 3: Legacy Static Salt Hash
    if (stored == _legacyHashPin(input)) {
      if (input.length == 6) {
        try {
          await setPin(input);
        } catch (e) {
          debugPrint('[PinService] Non-fatal error during legacy hash migration: $e');
        }
      }
      await _cleanLegacyStorage();
      return true;
    }

    return false;
  }

  /// Cleans up legacy plaintext and hash keys from SharedPreferences.
  Future<void> _cleanLegacyStorage() async {
    try {
      final prefs = await _getPrefs();
      await prefs.remove(_legacySpPinKey);
      await prefs.remove(_legacySpSaltKey);
      await prefs.remove(_legacyUserPinKey);
    } catch (e) {
      debugPrint('[PinService] Non-fatal error cleaning legacy storage: $e');
    }
  }

  /// Clears PIN verification state from secure storage and legacy storage.
  Future<void> clearPin() async {
    try {
      await _storage.delete(key: _pinKey);
      await _storage.delete(key: _pinSaltKey);
    } catch (e) {
      debugPrint('[PinService] SecureStorage delete error: $e');
    }
    await _cleanLegacyStorage();
  }
}
