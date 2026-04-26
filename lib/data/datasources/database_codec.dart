import 'dart:convert';
import 'package:encrypt/encrypt.dart';
import 'package:sembast/sembast.dart';
// ignore: implementation_imports
import 'package:sembast/src/json_encodable_codec.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class DatabaseEncryptionCodec implements SembastCodec {
  @override
  final String signature;
  
  @override
  final Codec<Object?, String> codec;

  DatabaseEncryptionCodec(Key key) 
      : signature = 'aes256',
        codec = _AesCodec(key);

  @override
  JsonEncodableCodec get jsonEncodableCodec => sembastDefaultJsonEncodableCodec;
}

class _AesCodec extends Codec<Object?, String> {
  final Key _key;

  _AesCodec(this._key);

  @override
  Converter<Object?, String> get encoder => _AesEncoder(_key);

  @override
  Converter<String, Object?> get decoder => _AesDecoder(_key);
}

class _AesEncoder extends Converter<Object?, String> {
  final Key _key;

  _AesEncoder(this._key);

  @override
  String convert(Object? input) {
    if (input == null) return '';
    
    // 1. Convert to JSON
    final jsonString = jsonEncode(input);
    
    // 2. Encrypt (AES-GCM for authenticated encryption)
    final iv = IV.fromSecureRandom(12);
    final encrypter = Encrypter(AES(_key, mode: AESMode.gcm));
    final encrypted = encrypter.encrypt(jsonString, iv: iv);
    
    // 3. Combine IV + Encrypted Data and Base64 encode
    return base64Encode(iv.bytes + encrypted.bytes);
  }
}

class _AesDecoder extends Converter<String, Object?> {
  final Key _key;

  _AesDecoder(this._key);

  @override
  Object? convert(String input) {
    if (input.isEmpty) return null;

    try {
      // 1. Base64 decode
      final combined = base64Decode(input);
      
      // 2. Extract IV and Data (try GCM 12-byte IV first)
      try {
        final iv = IV(combined.sublist(0, 12));
        final encryptedBytes = combined.sublist(12);
        final encrypter = Encrypter(AES(_key, mode: AESMode.gcm));
        final decrypted = encrypter.decrypt(Encrypted(encryptedBytes), iv: iv);
        return jsonDecode(decrypted);
      } catch (_) {
        // 3. Legacy fallback: AES-CBC with 16-byte IV
        final iv = IV(combined.sublist(0, 16));
        final encryptedBytes = combined.sublist(16);
        final encrypter = Encrypter(AES(_key, mode: AESMode.cbc));
        final decrypted = encrypter.decrypt(Encrypted(encryptedBytes), iv: iv);
        
        try {
          Sentry.captureMessage('Legacy CBC database decode used', level: SentryLevel.info);
        } catch (_) {}
        
        return jsonDecode(decrypted);
      }
    } catch (e) {
      // If decryption fails, it could be due to a wrong key or corrupted data.
      return null;
    }
  }
}
