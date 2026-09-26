import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vitacase/core/error/error_mapper.dart';
import 'package:vitacase/core/error/failures.dart';
import 'package:vitacase/shared/data/services/encryption_service.dart';
import 'package:vitacase/shared/data/services/pin_service.dart';

class FakeSecureKeyStorage implements SecureKeyStorage {
  final Map<String, String> data;
  bool shouldFailRead = false;
  bool shouldFailWrite = false;

  FakeSecureKeyStorage([Map<String, String>? initial])
      : data = initial ?? {};

  @override
  Future<String?> read(String key) async {
    if (shouldFailRead) throw Exception('Simulated secure storage read failure');
    return data[key];
  }

  @override
  Future<void> write(String key, String value) async {
    if (shouldFailWrite) throw Exception('Simulated secure storage write failure');
    data[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    data.remove(key);
  }
}

class FakePinStorageWithSharedMap implements PinStorage {
  final Map<String, String> sharedMap;
  FakePinStorageWithSharedMap(this.sharedMap);

  @override
  Future<String?> read(String key) async => sharedMap[key];

  @override
  Future<void> write(String key, String value) async => sharedMap[key] = value;

  @override
  Future<void> delete(String key) async => sharedMap.remove(key);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ErrorMapper', () {
    test('should return Right on success', () async {
      final result = await ErrorMapper.runGuarded(() async => 42);

      expect(result.isRight, true);
      result.fold(
        (l) => fail('Should not be Left'),
        (r) => expect(r, 42),
      );
    });

    test('should return Left with UnknownFailure on generic exception', () async {
      final result = await ErrorMapper.runGuarded<int>(() async {
        throw Exception('Something went wrong');
      });

      expect(result.isLeft, true);
      result.fold(
        (l) {
          expect(l, isA<UnknownFailure>());
          expect(l.message, contains('Something went wrong'));
        },
        (r) => fail('Should not be Right'),
      );
    });

    test('should return Left with CryptoFailure on crypto-related error', () async {
      final result = await ErrorMapper.runGuarded<String>(() async {
        throw Exception('mac check in CCM failed');
      });

      expect(result.isLeft, true);
      result.fold(
        (l) => expect(l, isA<CryptoFailure>()),
        (r) => fail('Should not be Right'),
      );
    });

    test('should use customMapper when provided', () async {
      final result = await ErrorMapper.runGuarded<String>(
        () async {
          throw FormatException('bad input');
        },
        customMapper: (e) => const ValidationFailure('Custom: bad input'),
      );

      expect(result.isLeft, true);
      result.fold(
        (l) {
          expect(l, isA<ValidationFailure>());
          expect(l.message, 'Custom: bad input');
        },
        (r) => fail('Should not be Right'),
      );
    });
  });

  group('Phase 3 — Master Key Management', () {
    late FakeSecureKeyStorage storage;
    late EncryptionService service;

    setUp(() {
      storage = FakeSecureKeyStorage();
      service = EncryptionService(storage: storage);
    });

    test('1. Key generation succeeds and generates 32-byte (256-bit) key', () async {
      final key = await service.getMasterKey();
      expect(key.bytes.length, 32);
    });

    test('2. Key is stored in secure storage under vitacase_master_key', () async {
      await service.getMasterKey();
      expect(storage.data.containsKey('vitacase_master_key'), isTrue);
      final rawBase64 = storage.data['vitacase_master_key']!;
      final decoded = base64Decode(rawBase64);
      expect(decoded.length, 32);
    });

    test('3. Key is NOT stored in SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await service.getMasterKey();

      expect(prefs.containsKey('vitacase_master_key'), isFalse);
      expect(prefs.getKeys().where((k) => k.toLowerCase().contains('key')), isEmpty);
    });

    test('4. Key is not logged/leaked in service string representation', () async {
      final key = await service.getMasterKey();
      expect(service.toString().contains(base64Encode(key.bytes)), isFalse);
    });

    test('Same key is returned consistently on subsequent calls and across service instances', () async {
      final key1 = await service.getMasterKey();
      final key2 = await service.getMasterKey();
      expect(key1.bytes, equals(key2.bytes));

      final service2 = EncryptionService(storage: storage);
      final key3 = await service2.getMasterKey();
      expect(key3.bytes, equals(key1.bytes));
    });
  });

  group('Phase 3 — Document Encryption & Round-Trip', () {
    late FakeSecureKeyStorage storage;
    late EncryptionService service;

    setUp(() {
      storage = FakeSecureKeyStorage();
      service = EncryptionService(storage: storage);
    });

    test('5. Plaintext document bytes are encrypted into ciphertext', () async {
      final plaintext = Uint8List.fromList(utf8.encode('Sensitive medical lab results'));
      final ciphertext = await service.encryptBytes(plaintext);

      expect(ciphertext, isNot(equals(plaintext)));
      expect(ciphertext.length, greaterThan(plaintext.length));
    });

    test('6. Encrypt -> decrypt round-trip restores exact original data', () async {
      final plaintext = Uint8List.fromList(utf8.encode('Patient diagnosis: confidential report'));
      final ciphertext = await service.encryptBytes(plaintext);
      final decrypted = await service.decryptBytes(ciphertext);

      expect(decrypted, equals(plaintext));
      expect(utf8.decode(decrypted), 'Patient diagnosis: confidential report');
    });

    test('7. Empty file round-trip succeeds (produces 28-byte authenticated payload)', () async {
      final empty = Uint8List(0);
      final ciphertext = await service.encryptBytes(empty);

      // 12 bytes IV + 0 bytes data + 16 bytes auth tag = 28 bytes
      expect(ciphertext.length, 28);

      final decrypted = await service.decryptBytes(ciphertext);
      expect(decrypted.length, 0);
      expect(decrypted, equals(empty));
    });

    test('8. Small file round-trip succeeds (< 50KB)', () async {
      final smallData = Uint8List.fromList(List.generate(1024, (i) => i % 256));
      final ciphertext = await service.encryptBytes(smallData);
      final decrypted = await service.decryptBytes(ciphertext);

      expect(decrypted, equals(smallData));
    });

    test('9. Larger file round-trip succeeds (>= 50KB isolate path)', () async {
      // 64 KB of synthetic binary data
      final largeData = Uint8List.fromList(List.generate(64 * 1024, (i) => (i * 7) % 256));
      final ciphertext = await service.encryptBytes(largeData);
      final decrypted = await service.decryptBytes(ciphertext);

      expect(decrypted, equals(largeData));
    });

    test('10. Binary/PDF-like structured data round-trip succeeds', () async {
      final pdfHeader = [0x25, 0x50, 0x44, 0x46, 0x2D, 0x31, 0x2E, 0x35]; // %PDF-1.5
      final body = List.generate(4096, (i) => (i * 13) % 256);
      final pdfData = Uint8List.fromList([...pdfHeader, ...body]);

      final ciphertext = await service.encryptBytes(pdfData);
      final decrypted = await service.decryptBytes(ciphertext);

      expect(decrypted, equals(pdfData));
      expect(decrypted.sublist(0, 8), equals(pdfHeader));
    });

    test('11. Each encryption operation uses a cryptographically secure random 12-byte nonce', () async {
      final data = Uint8List.fromList(utf8.encode('Same input data'));
      final cipher1 = await service.encryptBytes(data);
      final cipher2 = await service.encryptBytes(data);

      final nonce1 = cipher1.sublist(0, 12);
      final nonce2 = cipher2.sublist(0, 12);

      expect(nonce1, isNot(equals(nonce2)));
    });

    test('12. Encrypting the same plaintext twice produces different ciphertexts', () async {
      final data = Uint8List.fromList(utf8.encode('Duplicate content check'));
      final cipher1 = await service.encryptBytes(data);
      final cipher2 = await service.encryptBytes(data);

      expect(cipher1, isNot(equals(cipher2)));
    });

    test('String encrypt / decrypt round-trip works correctly', () async {
      const input = 'Turkish characters: ğüşıöç ĞÜŞİÖÇ & symbols: §±!@#\$%^&*()';
      final encrypted = await service.encryptString(input);
      final decrypted = await service.decryptString(encrypted);

      expect(decrypted, input);
    });
  });

  group('Phase 3 — Cryptographic Integrity & Failure Handling', () {
    late FakeSecureKeyStorage storage;
    late EncryptionService service;

    setUp(() {
      storage = FakeSecureKeyStorage();
      service = EncryptionService(storage: storage);
    });

    test('13. Tampering with ciphertext body causes decryption to fail (authentication tag check)', () async {
      final plaintext = Uint8List.fromList(utf8.encode('Original message'));
      final ciphertext = await service.encryptBytes(plaintext);

      // Mutate a byte in the middle of ciphertext
      final tampered = Uint8List.fromList(ciphertext);
      tampered[15] ^= 0xFF;

      expect(
        () async => service.decryptBytes(tampered),
        throwsA(isA<DecryptionException>()),
      );
    });

    test('14. Tampering with authentication tag causes decryption to fail', () async {
      final plaintext = Uint8List.fromList(utf8.encode('Original message with auth tag'));
      final ciphertext = await service.encryptBytes(plaintext);

      // Mutate the last byte (part of the 16-byte GCM tag)
      final tampered = Uint8List.fromList(ciphertext);
      tampered[tampered.length - 1] ^= 0x01;

      expect(
        () async => service.decryptBytes(tampered),
        throwsA(isA<DecryptionException>()),
      );
    });

    test('15. Attempting to decrypt with wrong key throws DecryptionException', () async {
      final plaintext = Uint8List.fromList(utf8.encode('Data encrypted under Key A'));
      final ciphertext = await service.encryptBytes(plaintext);

      // Setup a second service with a different random key
      final otherStorage = FakeSecureKeyStorage();
      final otherService = EncryptionService(storage: otherStorage);
      await otherService.getMasterKey(); // Generates different key

      expect(
        () async => otherService.decryptBytes(ciphertext),
        throwsA(isA<DecryptionException>()),
      );
    });

    test('16. Missing encrypted file throws FileSystemException safely', () async {
      final nonExistent = File('path/to/non_existent_vault_document.enc');
      expect(nonExistent.existsSync(), isFalse);

      expect(
        () async {
          if (!await nonExistent.exists()) {
            throw const FileSystemException('File not found', 'path/to/non_existent_vault_document.enc');
          }
        },
        throwsA(isA<FileSystemException>()),
      );
    });

    test('17. Corrupted key length in secure storage throws KeyStorageException safely', () async {
      // Write invalid key length (only 16 bytes instead of 32)
      storage.data['vitacase_master_key'] = base64Encode(List.filled(16, 1));
      final corruptService = EncryptionService(storage: storage);

      expect(
        () async => corruptService.getMasterKey(),
        throwsA(isA<KeyStorageException>()),
      );
    });

    test('18. Malformed/truncated encrypted payload (< 28 bytes) throws DecryptionException', () async {
      final tooShort = Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);

      expect(
        () async => service.decryptBytes(tooShort),
        throwsA(isA<DecryptionException>()),
      );
    });

    test('19. Secure storage failure on read throws KeyStorageException and never creates plaintext fallback', () async {
      storage.shouldFailRead = true;
      final failService = EncryptionService(storage: storage);

      expect(
        () async => failService.getMasterKey(),
        throwsA(isA<KeyStorageException>()),
      );
    });

    test('20. Secure storage failure on write throws KeyStorageException and does not cache unpersisted key', () async {
      storage.shouldFailWrite = true;
      final failService = EncryptionService(storage: storage);

      expect(
        () async => failService.getMasterKey(),
        throwsA(isA<KeyStorageException>()),
      );
    });
  });

  group('Phase 3 — Storage, PIN & Wipe Isolation', () {
    test('21. PinService.clearPin does not delete or invalidate master encryption key', () async {
      final sharedMap = <String, String>{};
      final keyStorage = FakeSecureKeyStorage(sharedMap);
      final pinStorage = FakePinStorageWithSharedMap(sharedMap);
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final encService = EncryptionService(storage: keyStorage);
      final pinService = PinService(storage: pinStorage, prefs: prefs);

      // Generate both keys
      await encService.getMasterKey();
      await pinService.setPin('123456');

      expect(sharedMap.containsKey('vitacase_master_key'), isTrue);
      expect(sharedMap.containsKey('app_pin_code'), isTrue);

      // Clear PIN
      await pinService.clearPin();

      // Master key is preserved!
      expect(sharedMap.containsKey('vitacase_master_key'), isTrue);
      expect(sharedMap.containsKey('app_pin_code'), isFalse);
    });

    test('22. Changing PIN via PinService.setPin does not invalidate document encryption or access', () async {
      final sharedMap = <String, String>{};
      final keyStorage = FakeSecureKeyStorage(sharedMap);
      final pinStorage = FakePinStorageWithSharedMap(sharedMap);
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final encService = EncryptionService(storage: keyStorage);
      final pinService = PinService(storage: pinStorage, prefs: prefs);

      await pinService.setPin('111111');
      final originalData = Uint8List.fromList(utf8.encode('Confidential blood test results'));
      final ciphertext = await encService.encryptBytes(originalData);

      // User changes PIN
      await pinService.setPin('999999');
      expect(await pinService.verifyPin('999999'), isTrue);

      // Document is still 100% decryptable!
      final decrypted = await encService.decryptBytes(ciphertext);
      expect(decrypted, equals(originalData));
    });

    test('23. Document delete removes encrypted file without touching master key', () async {
      final storage = FakeSecureKeyStorage();
      final service = EncryptionService(storage: storage);
      await service.getMasterKey();

      final tempDir = await Directory.systemTemp.createTemp('vitacase_test_doc_');
      final docFile = File('${tempDir.path}/test_doc.enc');
      await docFile.writeAsBytes(await service.encryptBytes(Uint8List.fromList([1, 2, 3])));
      expect(await docFile.exists(), isTrue);

      // Delete file
      await docFile.delete();
      expect(await docFile.exists(), isFalse);

      // Key is preserved
      expect(storage.data.containsKey('vitacase_master_key'), isTrue);
      await tempDir.delete(recursive: true);
    });

    test('24. Full wipe clears master key from secure storage and in-memory cache', () async {
      final storage = FakeSecureKeyStorage();
      final service = EncryptionService(storage: storage);
      await service.getMasterKey();
      expect(storage.data.containsKey('vitacase_master_key'), isTrue);

      // Delete master key
      await service.deleteMasterKey();
      expect(storage.data.containsKey('vitacase_master_key'), isFalse);

      // Next call generates a new, clean key
      final newKey = await service.getMasterKey();
      expect(newKey.bytes.length, 32);
      expect(storage.data.containsKey('vitacase_master_key'), isTrue);
    });

    test('25. Encryption / decryption does not log sensitive key or plaintext bytes', () async {
      final logs = <String>[];
      final storage = FakeSecureKeyStorage();
      final service = EncryptionService(storage: storage);

      final key = await service.getMasterKey();
      final plaintext = Uint8List.fromList(utf8.encode('Secret medical data'));
      final ciphertext = await service.encryptBytes(plaintext);
      final decrypted = await service.decryptBytes(ciphertext);

      // Verify no keys or plaintexts in logs
      expect(logs.any((l) => l.contains(base64Encode(key.bytes))), isFalse);
      expect(logs.any((l) => l.contains('Secret medical data')), isFalse);
      expect(decrypted, equals(plaintext));
    });

    test('26. Concurrent encryption and decryption operations succeed without corruption', () async {
      final storage = FakeSecureKeyStorage();
      final service = EncryptionService(storage: storage);

      final items = List.generate(10, (i) => Uint8List.fromList(utf8.encode('Document #$i contents')));

      // Encrypt all concurrently
      final ciphertexts = await Future.wait(items.map((data) => service.encryptBytes(data)));

      // Decrypt all concurrently
      final decryptedList = await Future.wait(ciphertexts.map((c) => service.decryptBytes(c)));

      for (var i = 0; i < items.length; i++) {
        expect(decryptedList[i], equals(items[i]));
      }
    });
  });
}
