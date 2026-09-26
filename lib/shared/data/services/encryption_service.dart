import 'dart:convert';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/foundation.dart' hide Key;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Secure storage abstraction for master encryption key.
abstract class SecureKeyStorage {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

/// Default FlutterSecureStorage-backed implementation.
class FlutterSecureKeyStorage implements SecureKeyStorage {
  final FlutterSecureStorage _storage;
  const FlutterSecureKeyStorage([FlutterSecureStorage storage = const FlutterSecureStorage()])
      : _storage = storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) => _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

/// Base crypto exception for VitaCase encryption service.
class CryptoServiceException implements Exception {
  final String message;
  const CryptoServiceException(this.message);

  @override
  String toString() => 'CryptoServiceException: $message';
}

/// Thrown when secure key storage operations fail.
class KeyStorageException extends CryptoServiceException {
  const KeyStorageException(super.message);
}

/// Thrown when decryption fails due to corrupted data, tag mismatch, or wrong key.
class DecryptionException extends CryptoServiceException {
  const DecryptionException(super.message);
}

/// Thrown when encryption fails.
class EncryptionException extends CryptoServiceException {
  const EncryptionException(super.message);
}

class EncryptionService {
  static const String _keyAlias = 'vitacase_master_key';
  static Key? _cachedMasterKey;

  final SecureKeyStorage _storage;
  Key? _instanceKey;
  Future<Key>? _masterKeyFuture;

  EncryptionService({SecureKeyStorage? storage})
      : _storage = storage ?? const FlutterSecureKeyStorage();

  /// Clears in-memory static cache.
  static void clearCache() {
    _cachedMasterKey = null;
  }

  /// Clears in-memory cached key for this instance.
  void clearKeyCache() {
    _instanceKey = null;
    _cachedMasterKey = null;
    _masterKeyFuture = null;
  }

  /// Returns the master key, generating it if it doesn't exist.
  /// Concurrency-safe to prevent race conditions during simultaneous calls.
  Future<Key> getMasterKey() {
    if (_instanceKey != null) return Future.value(_instanceKey!);
    if (_storage is FlutterSecureKeyStorage && _cachedMasterKey != null) {
      _instanceKey = _cachedMasterKey;
      return Future.value(_cachedMasterKey!);
    }
    return _masterKeyFuture ??= _loadOrGenerateMasterKey().whenComplete(() {
      _masterKeyFuture = null;
    });
  }

  Future<Key> _loadOrGenerateMasterKey() async {
    String? storedKey;
    try {
      storedKey = await _storage.read(_keyAlias);
    } catch (e) {
      throw KeyStorageException('Failed to read encryption key from secure storage: $e');
    }

    if (storedKey == null) {
      // Generate a new 32-byte (256-bit) cryptographically secure key
      final key = Key.fromSecureRandom(32);
      try {
        await _storage.write(_keyAlias, base64Encode(key.bytes));
      } catch (e) {
        throw KeyStorageException('Failed to persist encryption key to secure storage: $e');
      }
      _instanceKey = key;
      if (_storage is FlutterSecureKeyStorage) {
        _cachedMasterKey = key;
      }
    } else {
      try {
        final decoded = base64Decode(storedKey);
        if (decoded.length != 32) {
          throw const KeyStorageException('Corrupted encryption key length in secure storage');
        }
        final key = Key(decoded);
        _instanceKey = key;
        if (_storage is FlutterSecureKeyStorage) {
          _cachedMasterKey = key;
        }
      } catch (e) {
        if (e is KeyStorageException) rethrow;
        throw KeyStorageException('Corrupted encryption key encoding: $e');
      }
    }
    return _instanceKey!;
  }

  /// Deletes the master key from secure storage and clears in-memory cache.
  Future<void> deleteMasterKey() async {
    _instanceKey = null;
    _cachedMasterKey = null;
    _masterKeyFuture = null;
    try {
      await _storage.delete(_keyAlias);
    } catch (e) {
      throw KeyStorageException('Failed to delete master key: $e');
    }
  }

  /// High-level method to encrypt bytes (for files)
  Future<Uint8List> encryptBytes(Uint8List data) async {
    final key = await getMasterKey();
    if (data.length < 1024 * 50) {
      // Small files: keep on main thread for speed
      return _syncEncryptBytes(data, key);
    }
    return compute(_bgEncrypt, _EncryptionTask(data, key));
  }

  /// High-level method to decrypt bytes (for files)
  Future<Uint8List> decryptBytes(Uint8List encryptedData) async {
    final key = await getMasterKey();
    if (encryptedData.length < 1024 * 50) {
      // Small files
      return _syncDecryptBytes(encryptedData, key);
    }
    return compute(_bgDecrypt, _EncryptionTask(encryptedData, key));
  }

  /// Internal sync encryption logic (AES-256-GCM)
  static Uint8List _syncEncryptBytes(Uint8List data, Key key) {
    try {
      final iv = IV.fromSecureRandom(12);
      final encrypter = Encrypter(AES(key, mode: AESMode.gcm));
      final encrypted = encrypter.encryptBytes(data, iv: iv);

      final result = Uint8List(iv.bytes.length + encrypted.bytes.length);
      result.setAll(0, iv.bytes);
      result.setAll(iv.bytes.length, encrypted.bytes);
      return result;
    } catch (e) {
      throw EncryptionException('Failed to encrypt data: $e');
    }
  }

  /// Internal sync decryption logic (AES-256-GCM with legacy AES-CBC fallback)
  static Uint8List _syncDecryptBytes(Uint8List encryptedData, Key key) {
    if (encryptedData.length < 28) {
      throw const DecryptionException('Encrypted payload too short or malformed');
    }

    try {
      final ivBytes = encryptedData.sublist(0, 12);
      final actualEncryptedData = encryptedData.sublist(12);
      final iv = IV(ivBytes);
      final encrypter = Encrypter(AES(key, mode: AESMode.gcm));
      final decryptedList = encrypter.decryptBytes(
        Encrypted(actualEncryptedData),
        iv: iv,
      );
      return Uint8List.fromList(decryptedList);
    } catch (_) {
      // Legacy CBC fallback (16-byte IV + ciphertext)
      if (encryptedData.length >= 32) {
        try {
          final ivBytes = encryptedData.sublist(0, 16);
          final actualEncryptedData = encryptedData.sublist(16);
          final iv = IV(ivBytes);
          final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
          final decryptedList = encrypter.decryptBytes(
            Encrypted(actualEncryptedData),
            iv: iv,
          );
          return Uint8List.fromList(decryptedList);
        } catch (_) {
          throw const DecryptionException(
            'Failed to decrypt data: authentication tag mismatch or corrupted ciphertext',
          );
        }
      }
      throw const DecryptionException(
        'Failed to decrypt data: authentication tag mismatch or corrupted ciphertext',
      );
    }
  }

  Future<String> encryptString(String input) async {
    final key = await getMasterKey();
    try {
      final iv = IV.fromSecureRandom(12);
      final encrypter = Encrypter(AES(key, mode: AESMode.gcm));
      final encrypted = encrypter.encrypt(input, iv: iv);
      return base64Encode(iv.bytes + encrypted.bytes);
    } catch (e) {
      throw EncryptionException('Failed to encrypt string: $e');
    }
  }

  Future<String?> decryptString(String input) async {
    if (input.isEmpty) return null;
    final key = await getMasterKey();
    final Uint8List combined;
    try {
      combined = base64Decode(input);
    } catch (_) {
      return null;
    }
    if (combined.length < 28) return null;

    try {
      final iv = IV(combined.sublist(0, 12));
      final encryptedBytes = combined.sublist(12);
      final encrypter = Encrypter(AES(key, mode: AESMode.gcm));
      return encrypter.decrypt(Encrypted(encryptedBytes), iv: iv);
    } catch (_) {
      // Legacy CBC fallback (16-byte IV)
      if (combined.length >= 32) {
        try {
          final iv = IV(combined.sublist(0, 16));
          final encryptedBytes = combined.sublist(16);
          final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
          final result = encrypter.decrypt(Encrypted(encryptedBytes), iv: iv);

          try {
            Sentry.captureMessage(
              'Legacy CBC decryptString used',
              level: SentryLevel.info,
            );
          } catch (_) {}

          return result;
        } catch (_) {
          return null;
        }
      }
      return null;
    }
  }
}

/// Data class for isolate tasks
class _EncryptionTask {
  final Uint8List data;
  final Key key;
  _EncryptionTask(this.data, this.key);
}

/// BACKGROUND ENCRYPTION (Isolate)
Uint8List _bgEncrypt(_EncryptionTask task) {
  return EncryptionService._syncEncryptBytes(task.data, task.key);
}

/// BACKGROUND DECRYPTION (Isolate)
Uint8List _bgDecrypt(_EncryptionTask task) {
  return EncryptionService._syncDecryptBytes(task.data, task.key);
}
