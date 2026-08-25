import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vitacase/shared/data/services/pin_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;
  late PinService pinService;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    pinService = PinService(prefs: prefs);
  });

  group('PinService Security & Legacy Migration Tests', () {
    test('A & B: New PIN creation and verification succeeds', () async {
      await pinService.setPin('123456');

      expect(await pinService.hasPin(), isTrue);
      expect(await pinService.verifyPin('123456'), isTrue);
    });

    test('C: Wrong PIN returns false without crashing', () async {
      await pinService.setPin('123456');

      expect(await pinService.verifyPin('654321'), isFalse);
      expect(await pinService.verifyPin('12345'), isFalse);
      expect(await pinService.verifyPin(''), isFalse);
    });

    test('D: New PIN is NEVER stored in SharedPreferences', () async {
      await pinService.setPin('987654');

      // Direct inspection of SharedPreferences keys
      expect(prefs.getString('sp_app_pin_code'), isNull);
      expect(prefs.getString('sp_app_pin_salt'), isNull);
      expect(prefs.getString('user_pin'), isNull);
      expect(prefs.getString('app_pin_code'), isNull);
      expect(prefs.getKeys().where((k) => k.contains('pin')), isEmpty);
    });

    test('E: Secure storage contains salted hash, not plaintext PIN', () async {
      const secureStorage = FlutterSecureStorage();
      await pinService.setPin('654321');

      final storedPin = await secureStorage.read(key: 'app_pin_code');
      final storedSalt = await secureStorage.read(key: 'app_pin_salt');

      expect(storedPin, isNotNull);
      expect(storedSalt, isNotNull);
      expect(storedPin, isNot(equals('654321')), reason: 'PIN must never be stored plaintext');
      expect(storedPin!.length, equals(64), reason: 'SHA-256 hash output is 64 hex characters');
      expect(storedSalt!.length, greaterThanOrEqualTo(16), reason: 'Salt must be cryptographic random base64');
    });

    test('F, G, H, I: Legacy plaintext PIN in SharedPreferences is detected, verified, migrated to SecureStorage, and legacy key removed', () async {
      // Seed legacy plaintext PIN in SharedPreferences
      await prefs.setString('sp_app_pin_code', '112233');

      // F. Detection
      expect(await pinService.hasPin(), isTrue);

      // G. Verification & migration
      final isValid = await pinService.verifyPin('112233');
      expect(isValid, isTrue);

      // H. Plaintext legacy value is wiped from SharedPreferences
      expect(prefs.getString('sp_app_pin_code'), isNull);
      expect(prefs.getString('user_pin'), isNull);

      // I. Migrated PIN remains usable for subsequent authentication
      const secureStorage = FlutterSecureStorage();
      final securePin = await secureStorage.read(key: 'app_pin_code');
      expect(securePin, isNotNull);
      expect(securePin!.length, equals(64));

      expect(await pinService.verifyPin('112233'), isTrue);
      expect(await pinService.verifyPin('000000'), isFalse);
    });

    test('F & G (user_pin legacy key): Legacy user_pin key in SharedPreferences is migrated and purged', () async {
      await prefs.setString('user_pin', '778899');

      expect(await pinService.hasPin(), isTrue);
      expect(await pinService.verifyPin('778899'), isTrue);

      // Legacy key is purged
      expect(prefs.getString('user_pin'), isNull);

      // Future verification works from secure storage
      expect(await pinService.verifyPin('778899'), isTrue);
    });

    test('J: Malformed input validation and length checking', () async {
      expect(() => pinService.setPin('12345'), throwsArgumentError);
      expect(() => pinService.setPin('1234567'), throwsArgumentError);
      expect(() => pinService.setPin('abcdef'), throwsArgumentError);
      expect(() => pinService.setPin(''), throwsArgumentError);
    });

    test('K: Error handling when secure storage is unavailable throws PinStorageException', () async {
      final failingStorage = FailingSecureStorage();
      final failingPinService = PinService(storage: failingStorage, prefs: prefs);

      expect(
        () => failingPinService.setPin('123456'),
        throwsA(isA<PinStorageException>()),
      );

      // Ensure it did NOT silently write to SharedPreferences
      expect(prefs.getString('sp_app_pin_code'), isNull);
      expect(prefs.getString('user_pin'), isNull);
    });

    test('L & M: clearPin removes secure storage entries and legacy keys (Wipe compatibility)', () async {
      await pinService.setPin('123456');
      await prefs.setString('sp_app_pin_code', 'legacy_residual');

      await pinService.clearPin();

      expect(await pinService.hasPin(), isFalse);
      const secureStorage = FlutterSecureStorage();
      expect(await secureStorage.read(key: 'app_pin_code'), isNull);
      expect(await secureStorage.read(key: 'app_pin_salt'), isNull);
      expect(prefs.getString('sp_app_pin_code'), isNull);
    });
  });
}

class FailingSecureStorage extends FlutterSecureStorage {
  const FailingSecureStorage();

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    throw Exception('Simulated SecureStorage Hardware Failure');
  }

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    throw Exception('Simulated SecureStorage Hardware Failure');
  }
}
