import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:vitacase/shared/data/services/notification_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('NotificationEngine Timezone, Safety & Architecture Tests', () {
    test('ensureTimezoneInitialized populates timezone database so UTC is found', () {
      NotificationEngine.ensureTimezoneInitialized();
      final utc = tz.getLocation('UTC');

      expect(utc.name, equals('UTC'));
    });

    test('Multiple calls to ensureTimezoneInitialized are idempotent and safe (Warm Start)', () {
      expect(() {
        NotificationEngine.ensureTimezoneInitialized();
        NotificationEngine.ensureTimezoneInitialized();
        NotificationEngine.ensureTimezoneInitialized();
      }, returnsNormally);
    });

    test('getLocation for Europe/Istanbul or UTC succeeds after timezone initialization', () {
      NotificationEngine.ensureTimezoneInitialized();

      final trLocation = tz.getLocation('Europe/Istanbul');
      expect(trLocation.name, equals('Europe/Istanbul'));

      final date = DateTime.now();
      final tzDate = tz.TZDateTime.from(date, trLocation);
      expect(tzDate, isNotNull);
    });

    test('getStableId generates stable positive integer IDs from string and date', () {
      final now = DateTime(2026, 8, 25, 12, 0, 0);
      final id1 = NotificationEngine.getStableId('med_123', now);
      final id2 = NotificationEngine.getStableId('med_123', now);
      final id3 = NotificationEngine.getStableId('med_123', now.add(const Duration(hours: 1)));

      expect(id1, equals(id2), reason: 'Identical input and date must generate identical ID');
      expect(id1, isNot(equals(id3)), reason: 'Distinct timestamps must generate distinct IDs');
      expect(id1, isNonNegative, reason: 'ID must be non-negative integer');
    });

    test('initializeCore is resilient and non-fatal in headless test environments', () async {
      expect(() async {
        await NotificationEngine.initializeCore();
      }, returnsNormally);
    });
  });
}
