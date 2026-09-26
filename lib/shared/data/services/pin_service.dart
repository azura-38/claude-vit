import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Exception thrown when secure PIN operations fail.
class PinSecurityException implements Exception {
  final String message;
  const PinSecurityException(this.message);

  @override
  String toString() => 'PinSecurityException: $message';
}

/// Abstract storage interface for PIN credentials to allow secure storage
/// and deterministic unit testing without platform channel dependencies.
abstract class PinStorage {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

/// Default implementation of [PinStorage] backed by [FlutterSecureStorage].
class FlutterSecurePinStorage implements PinStorage {
  final FlutterSecureStorage _storage;

  FlutterSecurePinStorage([FlutterSecureStorage? storage])
      : _storage = storage ??
            const FlutterSecureStorage(
              iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
            );

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) => _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

/// Secure PIN service handling:
/// - Strictly 6-digit numeric PIN validation
/// - Cryptographic per-device 256-bit salt generation
/// - SHA-256 salted hashing with constant-time equality checks
/// - Secure storage only (never plaintext, never storing credentials in SharedPreferences)
/// - Automatic migration from legacy SharedPreferences or legacy static-salt hashes
/// - Complete wipe of PIN, salt, and legacy preferences
/// - Concurrency-safe salt generation
class PinService {
  final PinStorage _storage;
  final SharedPreferences? _prefs;

  static const _pinKey = 'app_pin_code';
  static const _pinSaltKey = 'app_pin_salt';
  static const _legacySalt = 'vitacase_pin_salt_f8a2';

  // Legacy SharedPreferences keys from older app versions
  static const List<String> _legacyPrefKeys = [
    'sp_app_pin_code',
    'sp_app_pin_salt',
    'app_pin_code',
    'app_pin_salt',
  ];

  static final RegExp _numericPinRegex = RegExp(r'^\d{6}$');

  Future<String>? _saltFuture;
  bool _migrationAttempted = false;

  PinService({
    PinStorage? storage,
    FlutterSecureStorage? secureStorage,
    SharedPreferences? prefs,
  })  : _storage = storage ?? FlutterSecurePinStorage(secureStorage),
        _prefs = prefs;

  /// Validates whether the given [pin] is strictly 6 numeric digits.
  static bool isValidPinFormat(String pin) {
    return _numericPinRegex.hasMatch(pin);
  }

  /// Migrates any legacy credentials found in SharedPreferences to SecureStorage,
  /// then immediately purges all credentials from SharedPreferences.
  Future<void> _migrateLegacyPreferencesIfNeeded() async {
    if (_migrationAttempted) return;
    _migrationAttempted = true;

    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();

      final spPin = prefs.getString('sp_app_pin_code') ?? prefs.getString('app_pin_code');
      final spSalt = prefs.getString('sp_app_pin_salt') ?? prefs.getString('app_pin_salt');

      if (spPin != null && spPin.isNotEmpty) {
        final existingSecurePin = await _storage.read(_pinKey);
        if (existingSecurePin == null || existingSecurePin.isEmpty) {
          await _storage.write(_pinKey, spPin);
          if (spSalt != null && spSalt.isNotEmpty) {
            await _storage.write(_pinSaltKey, spSalt);
          }
        }
      }

      await _wipeLegacyPrefsWith(prefs);
    } catch (_) {
      // Fail safely without throwing during passive checks
    }
  }

  Future<void> _wipeLegacyPrefs() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await _wipeLegacyPrefsWith(prefs);
    } catch (_) {}
  }

  Future<void> _wipeLegacyPrefsWith(SharedPreferences prefs) async {
    for (final key in _legacyPrefKeys) {
      if (prefs.containsKey(key)) {
        await prefs.remove(key);
      }
    }
  }

  /// Generates or retrieves the cryptographically secure 256-bit salt.
  Future<String> _getOrCreateSalt() {
    return _saltFuture ??= _computeAndStoreSalt();
  }

  Future<String> _computeAndStoreSalt() async {
    try {
      final stored = await _storage.read(_pinSaltKey);
      if (stored != null && stored.isNotEmpty) {
        return stored;
      }

      final random = Random.secure();
      final bytes = List<int>.generate(32, (_) => random.nextInt(256));
      final salt = base64UrlEncode(bytes);
      await _storage.write(_pinSaltKey, salt);
      return salt;
    } finally {
      _saltFuture = null;
    }
  }

  /// Computes salted SHA-256 hash.
  String _hashPin(String pin, String salt) {
    return sha256.convert(utf8.encode('$salt:$pin')).toString();
  }

  /// Computes legacy SHA-256 hash.
  String _legacyHashPin(String pin) {
    return sha256.convert(utf8.encode('$_legacySalt$pin')).toString();
  }

  /// Compares two strings in constant time to prevent timing attacks.
  bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }

  /// Checks if a PIN is currently configured.
  Future<bool> hasPin() async {
    try {
      await _migrateLegacyPreferencesIfNeeded();
      final stored = await _storage.read(_pinKey);
      return stored != null && stored.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Configures a new 6-digit numeric PIN.
  ///
  /// Throws [ArgumentError] if the PIN is not exactly 6 numeric digits.
  /// Throws [PinSecurityException] if writing to secure storage fails.
  Future<void> setPin(String pin) async {
    if (!isValidPinFormat(pin)) {
      throw ArgumentError('PIN must be exactly 6 numeric digits');
    }

    try {
      final salt = await _getOrCreateSalt();
      final hash = _hashPin(pin, salt);
      await _storage.write(_pinKey, hash);
      await _wipeLegacyPrefs();
    } catch (e) {
      if (e is ArgumentError) rethrow;
      throw PinSecurityException('Failed to securely store PIN: $e');
    }
  }

  /// Verifies [input] against the stored PIN.
  ///
  /// Seamlessly migrates legacy plaintext or legacy-salted hashes to
  /// modern per-device salted hashes upon successful verification.
  Future<bool> verifyPin(String input) async {
    // Only accept numeric inputs of length 4 to 6 for verification
    if (!RegExp(r'^\d{4,6}$').hasMatch(input)) {
      return false;
    }

    try {
      await _migrateLegacyPreferencesIfNeeded();
      final stored = await _storage.read(_pinKey);
      if (stored == null || stored.isEmpty) return false;

      // 1. Handle legacy plaintext PIN if present in storage
      if (stored.length == 4 || stored.length == 6) {
        final isPlaintextMatch = _constantTimeEquals(stored, input);
        if (isPlaintextMatch && isValidPinFormat(input)) {
          await setPin(input);
        }
        return isPlaintextMatch;
      }

      // 2. Check modern hashed PIN with salt
      final salt = await _storage.read(_pinSaltKey);
      if (salt != null && salt.isNotEmpty) {
        final hash = _hashPin(input, salt);
        if (_constantTimeEquals(stored, hash)) {
          return true;
        }
      }

      // 3. Check legacy static salt hash
      final legacyHash = _legacyHashPin(input);
      if (_constantTimeEquals(stored, legacyHash)) {
        if (isValidPinFormat(input)) {
          await setPin(input);
        }
        return true;
      }

      return false;
    } catch (_) {
      return false;
    }
  }

  /// Clears PIN and salt from secure storage and wipes any legacy SharedPreferences.
  Future<void> clearPin() async {
    try {
      await _storage.delete(_pinKey);
      await _storage.delete(_pinSaltKey);
    } catch (e) {
      throw PinSecurityException('Failed to clear PIN from secure storage: $e');
    } finally {
      await _wipeLegacyPrefs();
    }
  }
}
