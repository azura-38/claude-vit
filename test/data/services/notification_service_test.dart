import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:vitacase/core/notifications/app_notification_payload.dart';
import 'package:vitacase/core/notifications/notification_id_manager.dart';
import 'package:vitacase/core/types/runtime_types.dart';
import 'package:vitacase/shared/data/services/notification_service.dart';

class FakeNotificationPlatformAdapter implements NotificationPlatformAdapter {
  int initializeCallCount = 0;
  int cancelCallCount = 0;
  int cancelAllCallCount = 0;
  int showCallCount = 0;
  int zonedScheduleCallCount = 0;

  bool shouldThrowOnInitialize = false;
  bool shouldThrowOnSchedule = false;
  bool shouldThrowOnShow = false;
  bool shouldThrowOnCancel = false;
  NotificationPermissionState permissionToReturn = NotificationPermissionState.granted;

  final List<Map<String, dynamic>> scheduledNotifications = [];
  final List<Map<String, dynamic>> shownNotifications = [];
  final List<int> cancelledIds = [];

  @override
  Future<bool> initialize({
    required void Function(NotificationResponse) onDidReceiveNotificationResponse,
    bool useFallbackIcon = false,
  }) async {
    initializeCallCount++;
    if (shouldThrowOnInitialize) {
      throw Exception('Simulated platform initialization failure');
    }
    return true;
  }

  @override
  Future<NotificationPermissionState> requestPermissions({
    bool requestExactAlarm = false,
  }) async {
    return permissionToReturn;
  }

  @override
  Future<void> show({
    required int id,
    required String title,
    required String body,
    required String channelId,
    required String channelName,
    String? payload,
    bool useFallbackIcon = false,
  }) async {
    showCallCount++;
    if (shouldThrowOnShow) {
      throw Exception('Simulated platform show failure');
    }
    shownNotifications.add({
      'id': id,
      'title': title,
      'body': body,
      'channelId': channelId,
      'channelName': channelName,
      'payload': payload,
    });
  }

  @override
  Future<void> zonedSchedule({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    required String channelId,
    required String channelName,
    String? payload,
    bool useFallbackIcon = false,
    bool isMedication = false,
  }) async {
    zonedScheduleCallCount++;
    if (shouldThrowOnSchedule) {
      throw Exception('Simulated platform zonedSchedule failure');
    }
    scheduledNotifications.add({
      'id': id,
      'title': title,
      'body': body,
      'scheduledDate': scheduledDate,
      'channelId': channelId,
      'channelName': channelName,
      'payload': payload,
      'isMedication': isMedication,
    });
  }

  @override
  Future<void> cancel({required int id}) async {
    cancelCallCount++;
    if (shouldThrowOnCancel) {
      throw Exception('Simulated platform cancel failure');
    }
    cancelledIds.add(id);
  }

  @override
  Future<void> cancelAll() async {
    cancelAllCallCount++;
    if (shouldThrowOnCancel) {
      throw Exception('Simulated platform cancelAll failure');
    }
    cancelledIds.clear();
  }

  @override
  Future<List<PendingNotificationRequest>> getPendingNotificationRequests() async {
    return scheduledNotifications.map((s) => PendingNotificationRequest(
      s['id'] as int,
      s['title'] as String?,
      s['body'] as String?,
      s['payload'] as String?,
    )).toList();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeNotificationPlatformAdapter fakeAdapter;

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'notification_hide_sensitive_content': true,
      'app_locale': 'en',
    });
    NotificationService.resetForTesting();
    fakeAdapter = FakeNotificationPlatformAdapter();
    NotificationService.setAdapterForTesting(fakeAdapter);
  });

  tearDown(() {
    NotificationService.resetForTesting();
  });

  group('Phase 6 — Notification Core Tests', () {
    test('1. initialize succeeds and sets isInitialized to true', () async {
      expect(NotificationService.isInitialized, isFalse);

      await NotificationService.initCore();

      expect(NotificationService.isInitialized, isTrue);
      expect(fakeAdapter.initializeCallCount, 1);
    });

    test('2. initialize twice succeeds idempotently without duplicate resources', () async {
      await NotificationService.initCore();
      expect(NotificationService.isInitialized, isTrue);
      expect(fakeAdapter.initializeCallCount, 1);

      // Second call should return immediately
      await NotificationService.initCore();
      expect(NotificationService.isInitialized, isTrue);
      expect(fakeAdapter.initializeCallCount, 1);

      // Concurrent calls should be de-duplicated
      NotificationService.resetForTesting();
      NotificationService.setAdapterForTesting(fakeAdapter);
      await Future.wait([
        NotificationService.initCore(),
        NotificationService.initCore(),
        NotificationService.initCore(),
      ]);
      expect(NotificationService.isInitialized, isTrue);
      expect(fakeAdapter.initializeCallCount, 2); // 1 from previous group, 1 from parallel batch
    });

    test('3. permission denied does not crash or block initialization', () async {
      fakeAdapter.permissionToReturn = NotificationPermissionState.denied;

      await NotificationService.initCore();
      expect(NotificationService.isInitialized, isTrue);

      final prefs = await SharedPreferences.getInstance();
      final service = NotificationService(prefs);

      // Requesting permissions when denied returns denied without crashing
      final state = await service.requestPermissions();
      expect(state, NotificationPermissionState.denied);

      // Startup permissions request completes safely
      await NotificationService.requestStartupPermissions();
      expect(NotificationService.isInitialized, isTrue);
    });

    test('4. notification scheduling API works with fake platform adapter', () async {
      await NotificationService.initCore();

      final scheduleTime = DateTime.now().add(const Duration(hours: 2));
      final success = await NotificationService.schedule(
        id: 'test_item_1',
        title: 'Reminder Title',
        body: 'Medication Body',
        date: scheduleTime,
        type: NotificationType.medication,
      );

      expect(success, isTrue);
      expect(fakeAdapter.zonedScheduleCallCount, 1);
      expect(fakeAdapter.scheduledNotifications.length, 1);

      final record = fakeAdapter.scheduledNotifications.first;
      expect(record['title'], 'Reminder Title');
      // Body is sanitized because hide_sensitive_content is true
      expect(record['body'], 'You have a reminder');
      expect(record['id'], greaterThanOrEqualTo(NotificationIdManager.medicationMin));
      expect(record['id'], lessThan(NotificationIdManager.medicationMin + NotificationIdManager.medicationRange));
    });

    test('5. cancel works via key and numeric id', () async {
      await NotificationService.initCore();

      final cancelKeySuccess = await NotificationService.cancel('item_42');
      expect(cancelKeySuccess, isTrue);
      expect(fakeAdapter.cancelCallCount, 1);

      final cancelIdSuccess = await NotificationService.cancelById(9991);
      expect(cancelIdSuccess, isTrue);
      expect(fakeAdapter.cancelCallCount, 2);
      expect(fakeAdapter.cancelledIds, contains(9991));
    });

    test('6. cancelAll works safely', () async {
      await NotificationService.initCore();

      final cancelAllSuccess = await NotificationService.cancelAll();
      expect(cancelAllSuccess, isTrue);
      expect(fakeAdapter.cancelAllCallCount, 1);
    });

    test('7. timezone is initialized before scheduling without UTC crash', () async {
      // Ensure tz data is available
      tz.initializeTimeZones();

      // Ensure local timezone falls back to tz.UTC without throwing LocationNotFoundException
      NotificationService.ensureTimezoneInitialized();
      expect(tz.local, isNotNull);

      // Timezone fallback safety: setting to tz.UTC must be 100% valid
      tz.setLocalLocation(tz.UTC);
      expect(tz.local, equals(tz.UTC));

      // Scheduling automatically calls ensureTimezoneInitialized if not already set
      final futureDate = DateTime.now().add(const Duration(minutes: 30));
      final result = await NotificationService.schedule(
        id: 'tz_test',
        title: 'Check',
        body: 'Body',
        date: futureDate,
      );
      expect(result, isTrue);
    });

    test('8. invalid scheduling input fails safely without crashing', () async {
      await NotificationService.initCore();

      // Negative or epoch zero timestamp
      final invalidDate = DateTime.fromMillisecondsSinceEpoch(0);
      final result = await NotificationService.schedule(
        id: 'invalid_date',
        title: 'Test',
        body: 'Test',
        date: invalidDate,
      );

      expect(result, isFalse);
      expect(fakeAdapter.zonedScheduleCallCount, 0);
    });

    test('9. notification exceptions are contained and do not crash the app', () async {
      await NotificationService.initCore();

      fakeAdapter.shouldThrowOnSchedule = true;
      fakeAdapter.shouldThrowOnShow = true;
      fakeAdapter.shouldThrowOnCancel = true;

      final futureDate = DateTime.now().add(const Duration(hours: 1));

      // Schedule failure must return false, not throw
      final scheduleResult = await NotificationService.schedule(
        id: 'err_test',
        title: 'Err Title',
        body: 'Err Body',
        date: futureDate,
      );
      expect(scheduleResult, isFalse);

      // Show failure must return false, not throw
      final showResult = await NotificationService.show(
        id: 1234,
        title: 'Show Title',
        body: 'Show Body',
      );
      expect(showResult, isFalse);

      // Cancel failure must return false, not throw
      final cancelResult = await NotificationService.cancel('err_item');
      expect(cancelResult, isFalse);

      final cancelAllResult = await NotificationService.cancelAll();
      expect(cancelAllResult, isFalse);
    });

    test('10. notification IDs are deterministic and non-colliding across namespaces', () {
      final key = 'med_aspirin_100mg';
      final date = DateTime(2026, 9, 26, 8, 0);
      final occurrenceKey = NotificationIdManager.buildKey(key, date);

      // Determinism: Same input yields same ID every time
      final id1 = NotificationIdManager.getId(key: occurrenceKey, type: NotificationType.medication);
      final id2 = NotificationIdManager.getId(key: occurrenceKey, type: NotificationType.medication);
      expect(id1, equals(id2));

      // Namespace isolation:
      final medId = NotificationIdManager.getId(key: occurrenceKey, type: NotificationType.medication);
      final apptId = NotificationIdManager.getId(key: occurrenceKey, type: NotificationType.appointment);
      final sysId = NotificationIdManager.getId(key: occurrenceKey, type: NotificationType.engagement);
      final genId = NotificationIdManager.getId(key: occurrenceKey, type: NotificationType.unknown);

      // System range: 1 .. 99,999
      expect(sysId, greaterThanOrEqualTo(NotificationIdManager.systemMin));
      expect(sysId, lessThanOrEqualTo(NotificationIdManager.systemMax));

      // Medication range: 100,000,000 .. 899,999,999
      expect(medId, greaterThanOrEqualTo(NotificationIdManager.medicationMin));
      expect(medId, lessThan(NotificationIdManager.medicationMin + NotificationIdManager.medicationRange));

      // Appointment range: 1,000,000,000 .. 1,699,999,999
      expect(apptId, greaterThanOrEqualTo(NotificationIdManager.appointmentMin));
      expect(apptId, lessThan(NotificationIdManager.appointmentMin + NotificationIdManager.appointmentRange));

      // General range: 1,700,000,000 .. 2,147,483,647
      expect(genId, greaterThanOrEqualTo(NotificationIdManager.generalMin));
      expect(genId, lessThanOrEqualTo(0x7FFFFFFF));

      // Strict non-collision across namespaces
      expect(sysId != medId, isTrue);
      expect(medId != apptId, isTrue);
      expect(apptId != genId, isTrue);
      expect(sysId != apptId, isTrue);

      // Fixed system IDs are preserved
      expect(NotificationService.engagementId, 9999);
      expect(NotificationService.getStableIdStatic('engagement'), isPositive);
    });

    test('11. Privacy: sensitive text is hidden when privacy flag is active', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notification_hide_sensitive_content', true);

      final safeText = NotificationService.safeText('Take Metformin 500mg');
      expect(safeText, 'You have a reminder');
      expect(safeText.contains('Metformin'), isFalse);

      final safeMed = NotificationService.safeMedicationBodyStatic('Metformin');
      expect(safeMed, 'Details hidden');
      expect(safeMed.contains('Metformin'), isFalse);
    });
  });
}
