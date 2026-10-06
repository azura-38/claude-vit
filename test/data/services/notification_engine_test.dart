import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vitacase/core/notifications/app_notification_payload.dart';
import 'package:vitacase/core/types/runtime_types.dart';
import 'package:vitacase/shared/data/services/notification_engine.dart';
import '../../features/notifications/fake_awesome_notifications_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeAwesomeNotificationsClient fakeClient;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'notification_hide_sensitive_content': true,
      'app_locale': 'en',
    });
    fakeClient = FakeAwesomeNotificationsClient();
    NotificationEngine.resetForTesting();
    NotificationEngine.setClientForTesting(fakeClient);
  });

  tearDown(() {
    NotificationEngine.resetForTesting();
  });

  group('Item 2 — NotificationEngine Core Migration Tests', () {
    test('1. initializeCore succeeds and sets isInitialized to true', () async {
      expect(NotificationEngine.isInitialized, isFalse);

      await NotificationEngine.initializeCore();

      expect(NotificationEngine.isInitialized, isTrue);
      expect(fakeClient.initializeCallCount, 1);
    });

    test('2. initializeCore twice succeeds idempotently', () async {
      await NotificationEngine.initializeCore();
      expect(NotificationEngine.isInitialized, isTrue);
      expect(fakeClient.initializeCallCount, 1);

      await NotificationEngine.initializeCore();
      expect(NotificationEngine.isInitialized, isTrue);
      expect(fakeClient.initializeCallCount, 1);
    });

    test('3. permission denied returns denied without crashing', () async {
      fakeClient.isAllowed = false;
      await NotificationEngine.initializeCore();

      final state = await NotificationEngine.requestPermissions();
      expect(state, NotificationPermissionState.denied);
    });

    test('4. scheduleMedication creates notification with safe masked text', () async {
      await NotificationEngine.initializeCore();

      final scheduleTime = DateTime.now().add(const Duration(hours: 2));
      await NotificationEngine.scheduleMedication(
        id: 'med_test_1',
        title: '💊 Medication Title',
        body: 'Confidential Drug Name 500mg',
        date: scheduleTime,
        explicitId: 10005,
        payload: AppNotificationPayload(
          type: NotificationType.medication,
          entityId: 'med_test_1',
          occurrenceAt: scheduleTime,
        ),
      );

      expect(fakeClient.createNotificationCallCount, 1);
      expect(fakeClient.scheduledNotifications.length, 1);

      final record = fakeClient.scheduledNotifications.first;
      expect(record['id'], 10005);
      expect(record['title'], '💊 Medication Title');
      expect(record['body'], 'Reminder details are hidden.');
      expect(record['entityId'], 'med_test_1');
    });

    test('5. scheduleAppointment creates notification with correct channel and action buttons', () async {
      await NotificationEngine.initializeCore();

      final scheduleTime = DateTime.now().add(const Duration(days: 1));
      await NotificationEngine.scheduleAppointment(
        id: 'app_test_1',
        title: '📅 Appointment Title',
        body: 'Dr. Smith - Oncology',
        date: scheduleTime,
        explicitId: 20005,
        payload: AppNotificationPayload(
          type: NotificationType.appointment,
          entityId: 'app_test_1',
          occurrenceAt: scheduleTime,
        ),
      );

      expect(fakeClient.createNotificationCallCount, 1);
      expect(fakeClient.scheduledNotifications.length, 1);

      final record = fakeClient.scheduledNotifications.first;
      expect(record['id'], 20005);
      expect(record['channelKey'], 'appointment_reminders_v2');
      expect(record['body'], 'Reminder details are hidden.');
    });

    test('6. cancelById and cancel work reliably', () async {
      await NotificationEngine.initializeCore();

      await NotificationEngine.cancelById(10005);
      expect(fakeClient.cancelCallCount, 1);
      expect(fakeClient.cancelledIds, contains(10005));

      await NotificationEngine.cancel('med_test_1');
      expect(fakeClient.cancelCallCount, 2);
    });

    test('7. cancelAll removes all scheduled notifications', () async {
      await NotificationEngine.initializeCore();

      await NotificationEngine.cancelAll();
      expect(fakeClient.cancelAllCallCount, 1);
    });

    test('8. getPendingNotificationRequests lists scheduled items', () async {
      await NotificationEngine.initializeCore();

      final scheduleTime = DateTime.now().add(const Duration(hours: 3));
      await NotificationEngine.scheduleMedication(
        id: 'med_pending_1',
        title: 'Test',
        body: 'Test Body',
        date: scheduleTime,
        explicitId: 10010,
        payload: AppNotificationPayload(
          type: NotificationType.medication,
          entityId: 'med_pending_1',
          occurrenceAt: scheduleTime,
        ),
      );

      final pending = await NotificationEngine.getPendingNotificationRequests();
      expect(pending.length, 1);
      expect(pending.first.id, 10010);
    });

    test('9. safeText reveals content when hide_sensitive_content is false', () async {
      SharedPreferences.setMockInitialValues({
        'notification_hide_sensitive_content': false,
        'app_locale': 'en',
      });
      NotificationEngine.resetForTesting();
      NotificationEngine.setClientForTesting(fakeClient);
      await NotificationEngine.initCore();

      final revealed = NotificationEngine.safeText('Aspirin 100mg');
      expect(revealed, 'Aspirin 100mg');
    });

    test('10. action handlers are triggered when action received', () async {
      await NotificationEngine.initializeCore();

      String? handledAction;
      NotificationEngine.setMedicineActionHandlers(
        onTaken: (id) async => handledAction = 'taken_$id',
        onSkipped: (id) async => handledAction = 'skipped_$id',
      );

      await NotificationEngine.startListening();
      expect(fakeClient.actionCallback, isNotNull);

      // Simulate MARK_DONE button press
      final actionDone = ReceivedAction().fromMap({
        'buttonKeyPressed': 'MARK_DONE',
        'payload': {'entityId': 'med_123', 'payload': 'test'},
      });
      await fakeClient.actionCallback!(actionDone);
      expect(handledAction, 'taken_med_123');

      // Simulate SKIP button press
      final actionSkip = ReceivedAction().fromMap({
        'buttonKeyPressed': 'SKIP',
        'payload': {'entityId': 'med_123', 'payload': 'test'},
      });
      await fakeClient.actionCallback!(actionSkip);
      expect(handledAction, 'skipped_med_123');
    });
  });
}
