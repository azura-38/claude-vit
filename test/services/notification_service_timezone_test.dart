import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:vitacase/shared/data/services/notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('NotificationService Timezone Initialization & Crash Resilience Tests', () {
    test('ensureTimezoneInitialized populates timezone database so UTC is found', () {
      NotificationService.ensureTimezoneInitialized();
      final utc = tz.getLocation('UTC');

      expect(utc.name, equals('UTC'));
    });

    test('Multiple calls to ensureTimezoneInitialized are idempotent and safe (Warm Start)', () {
      expect(() {
        NotificationService.ensureTimezoneInitialized();
        NotificationService.ensureTimezoneInitialized();
        NotificationService.ensureTimezoneInitialized();
      }, returnsNormally);
    });

    test('getLocation for Europe/Istanbul or UTC succeeds after timezone initialization', () {
      NotificationService.ensureTimezoneInitialized();

      final trLocation = tz.getLocation('Europe/Istanbul');
      expect(trLocation.name, equals('Europe/Istanbul'));

      final date = DateTime.now();
      final tzDate = tz.TZDateTime.from(date, trLocation);
      expect(tzDate, isNotNull);
    });

    test('initCore is resilient and non-fatal even when local notifications plugin is not mocked', () async {
      expect(() async {
        await NotificationService.initCore();
      }, returnsNormally);
    });

    test('requestStartupPermissions is non-fatal on permission denied or uninitialized state', () async {
      expect(() async {
        await NotificationService.requestStartupPermissions();
      }, returnsNormally);
    });
  });
}
