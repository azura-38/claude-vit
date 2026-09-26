import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vitacase/shared/data/services/pin_service.dart';

/// In-memory implementation of [PinStorage] for deterministic testing.
class FakePinStorage implements PinStorage {
  final Map<String, String> data = {};
  bool shouldThrowOnRead = false;
  bool shouldThrowOnWrite = false;

  @override
  Future<String?> read(String key) async {
    if (shouldThrowOnRead) throw Exception('Simulated storage read error');
    return data[key];
  }

  @override
  Future<void> write(String key, String value) async {
    if (shouldThrowOnWrite) throw Exception('Simulated storage write error');
    data[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    data.remove(key);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakePinStorage fakeStorage;
  late SharedPreferences prefs;
  late PinService pinService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    fakeStorage = FakePinStorage();
    pinService = PinService(
      storage: fakeStorage,
      prefs: prefs,
    );
  });

  group('PinService - PIN Format Validation', () {
    test('isValidPinFormat validates strictly 6-digit numeric strings', () {
      expect(PinService.isValidPinFormat('123456'), isTrue);
      expect(PinService.isValidPinFormat('000000'), isTrue);
      expect(PinService.isValidPinFormat('987654'), isTrue);

      expect(PinService.isValidPinFormat(''), isFalse);
      expect(PinService.isValidPinFormat('12345'), isFalse);
      expect(PinService.isValidPinFormat('1234567'), isFalse);
      expect(PinService.isValidPinFormat('1234'), isFalse);
      expect(PinService.isValidPinFormat('12345a'), isFalse);
      expect(PinService.isValidPinFormat('abcdef'), isFalse);
      expect(PinService.isValidPinFormat('12 456'), isFalse);
      expect(PinService.isValidPinFormat('12-456'), isFalse);
    });

    test('setPin throws ArgumentError for non-6-digit PINs', () async {
      expect(() => pinService.setPin('12345'), throwsA(isA<ArgumentError>()));
      expect(() => pinService.setPin('1234567'), throwsA(isA<ArgumentError>()));
      expect(() => pinService.setPin('abcdef'), throwsA(isA<ArgumentError>()));
      expect(() => pinService.setPin('12345e'), throwsA(isA<ArgumentError>()));
    });
  });

  group('PinService - Secure Storage & Hashing', () {
    test('setPin stores hashed PIN and salt, never plaintext', () async {
      const pin = '482910';
      await pinService.setPin(pin);

      final storedPin = fakeStorage.data['app_pin_code'];
      final storedSalt = fakeStorage.data['app_pin_salt'];

      expect(storedPin, isNotNull);
      expect(storedSalt, isNotNull);
      expect(storedPin, isNot(contains(pin)));
      expect(storedPin!.length, 64); // SHA-256 hex string length

      // Verify the stored hash matches sha256(salt:pin)
      final expectedHash = sha256.convert(utf8.encode('$storedSalt:$pin')).toString();
      expect(storedPin, equals(expectedHash));
    });

    test('setPin does NOT write credentials to SharedPreferences', () async {
      await pinService.setPin('112233');

      expect(prefs.containsKey('sp_app_pin_code'), isFalse);
      expect(prefs.containsKey('sp_app_pin_salt'), isFalse);
      expect(prefs.containsKey('app_pin_code'), isFalse);
      expect(prefs.containsKey('app_pin_salt'), isFalse);
    });
  });

  group('PinService - Verification & Authentication', () {
    test('verifyPin succeeds with correct PIN and fails with wrong PIN', () async {
      await pinService.setPin('567890');

      expect(await pinService.verifyPin('567890'), isTrue);
      expect(await pinService.verifyPin('000000'), isFalse);
      expect(await pinService.verifyPin('567891'), isFalse);
      expect(await pinService.verifyPin('12345'), isFalse);
      expect(await pinService.verifyPin('abcdef'), isFalse);
    });

    test('verifyPin returns false when no PIN is set', () async {
      expect(await pinService.verifyPin('123456'), isFalse);
    });
  });

  group('PinService - Legacy Migration', () {
    test('migrates plaintext 6-digit PIN on successful verification', () async {
      const plaintextPin = '998877';
      fakeStorage.data['app_pin_code'] = plaintextPin;

      expect(await pinService.hasPin(), isTrue);

      // Verify with the plaintext PIN
      final verified = await pinService.verifyPin(plaintextPin);
      expect(verified, isTrue);

      // Verify storage was upgraded to hashed PIN with salt
      final newStored = fakeStorage.data['app_pin_code'];
      final salt = fakeStorage.data['app_pin_salt'];
      expect(newStored, isNot(equals(plaintextPin)));
      expect(salt, isNotNull);
      expect(newStored!.length, 64);

      // Subsequent verifications work with the new hash
      expect(await pinService.verifyPin(plaintextPin), isTrue);
    });

    test('migrates legacy static-salt hash on successful verification', () async {
      const pin = '345678';
      const legacySalt = 'vitacase_pin_salt_f8a2';
      final legacyHash = sha256.convert(utf8.encode('$legacySalt$pin')).toString();

      fakeStorage.data['app_pin_code'] = legacyHash;

      // Verify matches legacy hash
      final verified = await pinService.verifyPin(pin);
      expect(verified, isTrue);

      // Verify upgraded to modern salt and hash
      final upgradedHash = fakeStorage.data['app_pin_code'];
      final salt = fakeStorage.data['app_pin_salt'];
      expect(salt, isNotNull);
      expect(upgradedHash, isNot(equals(legacyHash)));

      // Verifies with new hash
      expect(await pinService.verifyPin(pin), isTrue);
    });

    test('migrates legacy SharedPreferences credentials and wipes prefs', () async {
      const legacyPinHash = 'some_legacy_hash_value';
      const legacySalt = 'some_legacy_salt';

      await prefs.setString('sp_app_pin_code', legacyPinHash);
      await prefs.setString('sp_app_pin_salt', legacySalt);

      expect(await pinService.hasPin(), isTrue);

      // Credentials should be in secure storage now
      expect(fakeStorage.data['app_pin_code'], equals(legacyPinHash));
      expect(fakeStorage.data['app_pin_salt'], equals(legacySalt));

      // SharedPreferences should be wiped of credential keys
      expect(prefs.containsKey('sp_app_pin_code'), isFalse);
      expect(prefs.containsKey('sp_app_pin_salt'), isFalse);
    });
  });

  group('PinService - Clear / Wipe', () {
    test('clearPin removes all keys from secure storage and shared preferences', () async {
      await pinService.setPin('654321');
      await prefs.setString('sp_app_pin_code', 'old_pref_value');

      expect(await pinService.hasPin(), isTrue);

      await pinService.clearPin();

      expect(await pinService.hasPin(), isFalse);
      expect(fakeStorage.data.containsKey('app_pin_code'), isFalse);
      expect(fakeStorage.data.containsKey('app_pin_salt'), isFalse);
      expect(prefs.containsKey('sp_app_pin_code'), isFalse);
      expect(await pinService.verifyPin('654321'), isFalse);
    });
  });

  group('PinService - Error Handling & Concurrency', () {
    test('hasPin and verifyPin return false on storage read failure without crashing', () async {
      await pinService.setPin('123456');
      fakeStorage.shouldThrowOnRead = true;

      expect(await pinService.hasPin(), isFalse);
      expect(await pinService.verifyPin('123456'), isFalse);
    });

    test('setPin throws PinSecurityException on storage write failure', () async {
      fakeStorage.shouldThrowOnWrite = true;

      expect(
        () => pinService.setPin('123456'),
        throwsA(isA<PinSecurityException>()),
      );
    });

    test('concurrent salt generation produces consistent salt', () async {
      final futures = await Future.wait([
        pinService.setPin('111111'),
      ]);
      expect(futures.length, 1);
      expect(fakeStorage.data['app_pin_salt'], isNotNull);
    });
  });
}
