import 'dart:convert';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/foundation.dart' hide Key;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class EncryptionService {
  static const String _keyAlias = 'vitacase_master_key';
  final _storage = const FlutterSecureStorage();
  
  Key? _masterKey;

  /// Returns the master key, generating it if it doesn't exist.
  Future<Key> getMasterKey() async {
    if (_masterKey != null) return _masterKey!;

    String? storedKey = await _storage.read(key: _keyAlias);
    if (storedKey == null) {
      // Generate a new 32-byte key
      final key = Key.fromSecureRandom(32);
      await _storage.write(key: _keyAlias, value: base64Encode(key.bytes));
      _masterKey = key;
    } else {
      _masterKey = Key(base64Decode(storedKey));
    }
    return _masterKey!;
  }

  /// High-level method to encrypt bytes (for files)
  Future<Uint8List> encryptBytes(Uint8List data) async {
    final key = await getMasterKey();
    if (data.length < 1024 * 50) { // Small files: keep on main thread for speed
      return _syncEncryptBytes(data, key);
    }
    return compute(_bgEncrypt, _EncryptionTask(data, key));
  }

  /// High-level method to decrypt bytes (for files)
  Future<Uint8List> decryptBytes(Uint8List encryptedData) async {
    final key = await getMasterKey();
    if (encryptedData.length < 1024 * 50) { // Small files
      return _syncDecryptBytes(encryptedData, key);
    }
    return compute(_bgDecrypt, _EncryptionTask(encryptedData, key));
  }

  /// Internal sync encryption logic
  static Uint8List _syncEncryptBytes(Uint8List data, Key key) {
    final iv = IV.fromSecureRandom(12);
    final encrypter = Encrypter(AES(key, mode: AESMode.gcm));
    final encrypted = encrypter.encryptBytes(data, iv: iv);
    
    final result = Uint8List(iv.bytes.length + encrypted.bytes.length);
    result.setAll(0, iv.bytes);
    result.setAll(iv.bytes.length, encrypted.bytes);
    return result;
  }

  /// Internal sync decryption logic
  static Uint8List _syncDecryptBytes(Uint8List encryptedData, Key key) {
    if (encryptedData.length < 13) {
      throw StateError('Encrypted payload too short');
    }

    try {
      final ivBytes = encryptedData.sublist(0, 12);
      final actualEncryptedData = encryptedData.sublist(12);
      final iv = IV(ivBytes);
      final encrypter = Encrypter(AES(key, mode: AESMode.gcm));
      final decryptedList = encrypter.decryptBytes(Encrypted(actualEncryptedData), iv: iv);
      return Uint8List.fromList(decryptedList);
    } catch (_) {
      final ivBytes = encryptedData.sublist(0, 16);
      final actualEncryptedData = encryptedData.sublist(16);
      final iv = IV(ivBytes);
      final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
      final decryptedList = encrypter.decryptBytes(Encrypted(actualEncryptedData), iv: iv);
      return Uint8List.fromList(decryptedList);
    }
  }

  Future<String> encryptString(String input) async {
    final key = await getMasterKey();
    final iv = IV.fromSecureRandom(12);
    final encrypter = Encrypter(AES(key, mode: AESMode.gcm));
    final encrypted = encrypter.encrypt(input, iv: iv);
    return base64Encode(iv.bytes + encrypted.bytes);
  }

  Future<String?> decryptString(String input) async {
    if (input.isEmpty) return null;
    final key = await getMasterKey();
    final combined = base64Decode(input);
    if (combined.length < 13) return null;
    try {
      final iv = IV(combined.sublist(0, 12));
      final encryptedBytes = combined.sublist(12);
      final encrypter = Encrypter(AES(key, mode: AESMode.gcm));
      return encrypter.decrypt(Encrypted(encryptedBytes), iv: iv);
    } catch (_) {
      // Legacy CBC fallback (16-byte IV)
      try {
        final iv = IV(combined.sublist(0, 16));
        final encryptedBytes = combined.sublist(16);
        final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
        final result = encrypter.decrypt(Encrypted(encryptedBytes), iv: iv);
        
        // Log to Sentry so we know how many users still have CBC-encrypted data
        try {
          Sentry.captureMessage('Legacy CBC decryptString used', level: SentryLevel.info);
        } catch (_) {}
        
        return result;
      } catch (_) {
        return null;
      }
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
  final iv = IV.fromSecureRandom(12);
  final encrypter = Encrypter(AES(task.key, mode: AESMode.gcm));
  final encrypted = encrypter.encryptBytes(task.data, iv: iv);
  
  final result = Uint8List(iv.bytes.length + encrypted.bytes.length);
  result.setAll(0, iv.bytes);
  result.setAll(iv.bytes.length, encrypted.bytes);
  return result;
}

/// BACKGROUND DECRYPTION (Isolate)
Uint8List _bgDecrypt(_EncryptionTask task) {
  if (task.data.length < 13) throw StateError('Encrypted payload too short');

  try {
    final ivBytes = task.data.sublist(0, 12);
    final actualEncryptedData = task.data.sublist(12);
    final iv = IV(ivBytes);
    final encrypter = Encrypter(AES(task.key, mode: AESMode.gcm));
    final decryptedList = encrypter.decryptBytes(Encrypted(actualEncryptedData), iv: iv);
    return Uint8List.fromList(decryptedList);
  } catch (_) {
    // Legacy CBC fallback
    final ivBytes = task.data.sublist(0, 16);
    final actualEncryptedData = task.data.sublist(16);
    final iv = IV(ivBytes);
    final encrypter = Encrypter(AES(task.key, mode: AESMode.cbc));
    final decryptedList = encrypter.decryptBytes(Encrypted(actualEncryptedData), iv: iv);
    
    // Note: Can't easily use Sentry inside an isolate without passing the hub, 
    // but the DB and string decrypts will catch the majority of CBC usage.
    
    return Uint8List.fromList(decryptedList);
  }
}
