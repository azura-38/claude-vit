import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vitacase/core/di/repository_providers.dart';
import 'package:vitacase/core/notifications/notification_id_manager.dart';
import 'package:vitacase/features/appointments/domain/entities/appointment.dart';
import 'package:vitacase/features/appointments/presentation/providers/appointment_providers.dart';
import 'package:vitacase/shared/data/services/notification_engine.dart';
import 'package:vitacase/shared/data/services/usage_limit_service.dart';
import 'package:vitacase/shared/domain/enums/appointment_status.dart';
import 'package:vitacase/shared/domain/repositories/appointment_repository.dart';
import 'package:vitacase/shared/providers/shared_prefs_provider.dart';

import '../notifications/fake_awesome_notifications_client.dart';

class InMemoryAppointmentRepository implements AppointmentRepository {
  final Map<String, Appointment> _store = {};

  @override
  Future<void> save(Appointment appointment) async {
    _store[appointment.id] = appointment;
  }

  @override
  Future<Appointment?> getById(String id) async {
    return _store[id];
  }

  @override
  Future<List<Appointment>> getAll() async {
    return _store.values.toList();
  }

  @override
  Future<void> update(Appointment appointment) async {
    _store[appointment.id] = appointment;
  }

  @override
  Future<void> delete(String id) async {
    _store.remove(id);
  }

  @override
  Future<Appointment?> getNextUpcoming() async => null;

  @override
  Future<void> updateStatus(String id, AppointmentStatus status) async {
    final appt = _store[id];
    if (appt != null) {
      _store[id] = appt.copyWith(status: status);
    }
  }
}

class FakeUsageLimitService extends Fake implements UsageLimitService {
  @override
  Future<UsageLimitResult> consumeCreate() async => const UsageLimitResult(allowed: true, used: 0, limit: 100);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeAwesomeNotificationsClient fakeClient;
  late InMemoryAppointmentRepository fakeRepo;
  late SharedPreferences fakePrefs;
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'notification_hide_sensitive_content': true,
      'app_locale': 'en',
    });
    fakePrefs = await SharedPreferences.getInstance();

    NotificationEngine.resetForTesting();
    fakeClient = FakeAwesomeNotificationsClient();
    NotificationEngine.setClientForTesting(fakeClient);
    await NotificationEngine.initCore();

    fakeRepo = InMemoryAppointmentRepository();

    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(fakePrefs),
        appointmentRepositoryProvider.overrideWithValue(fakeRepo),
        usageLimitServiceProvider.overrideWithValue(FakeUsageLimitService()),
      ],
    );
  });

  tearDown(() {
    container.dispose();
    NotificationEngine.resetForTesting();
  });

  Appointment createTestAppointment({
    String id = 'app_1',
    String title = 'Cardiology Consultation',
    String doctor = 'Dr. House',
    String date = '2026-10-15',
    String time = '14:30',
    String? reminderTime = 'reminder_1h',
    List<String> selectedReminders = const ['reminder_1h'],
  }) {
    return Appointment(
      id: id,
      title: title,
      doctor: doctor,
      department: 'Cardiology',
      hospital: 'Central Hospital',
      date: date,
      time: time,
      status: AppointmentStatus.upcoming,
      reminderTime: reminderTime,
      selectedReminders: selectedReminders,
      createdAt: DateTime(2026, 9, 26, 12, 0),
    );
  }

  group('Phase 8 — Appointment Notifications Tests', () {
    test('1. appointment reminder schedules successfully within appointment namespace', () async {
      final app = createTestAppointment();
      await container.read(appointmentListProvider.notifier).addAppointment(app);

      expect(fakeClient.createNotificationCallCount, 1);
      final record = fakeClient.scheduledNotifications.first;

      expect(record['channelKey'], 'appointment_reminders_v2');
      // Sensitive body is masked when hide_sensitive_content is true
      expect(record['body'], 'Reminder details are hidden.');

      final expectedId = NotificationIdManager.getAppointmentReminderId(
        appointmentId: app.id,
        reminderKey: 'reminder_1h',
      );
      expect(record['id'], expectedId);
      expect(record['id'], greaterThanOrEqualTo(NotificationIdManager.appointmentMin));
      expect(record['id'], lessThan(NotificationIdManager.appointmentMin + NotificationIdManager.appointmentRange));
    });

    test('2. appointment notification ID is deterministic across repeated invocations', () {
      final id1 = NotificationIdManager.getAppointmentReminderId(
        appointmentId: 'app_100',
        reminderKey: 'reminder_1h',
      );
      final id2 = NotificationIdManager.getAppointmentReminderId(
        appointmentId: 'app_100',
        reminderKey: 'reminder_1h',
      );
      expect(id1, equals(id2));
    });

    test('3. different appointments receive different IDs for the same reminder offset', () {
      final idA = NotificationIdManager.getAppointmentReminderId(
        appointmentId: 'app_cardio',
        reminderKey: 'reminder_1d',
      );
      final idB = NotificationIdManager.getAppointmentReminderId(
        appointmentId: 'app_dental',
        reminderKey: 'reminder_1d',
      );
      expect(idA != idB, isTrue);
    });

    test('4. different reminder offsets for the same appointment receive different IDs', () {
      final id10m = NotificationIdManager.getAppointmentReminderId(
        appointmentId: 'app_1',
        reminderKey: 'reminder_10m',
      );
      final id1h = NotificationIdManager.getAppointmentReminderId(
        appointmentId: 'app_1',
        reminderKey: 'reminder_1h',
      );
      final id1d = NotificationIdManager.getAppointmentReminderId(
        appointmentId: 'app_1',
        reminderKey: 'reminder_1d',
      );
      final id7d = NotificationIdManager.getAppointmentReminderId(
        appointmentId: 'app_1',
        reminderKey: 'reminder_7d',
      );

      expect({id10m, id1h, id1d, id7d}.length, 4);
    });

    test('5 & 6. updating appointment cancels old notification and schedules new reminder without orphans', () async {
      final initial = createTestAppointment(reminderTime: 'reminder_1d', selectedReminders: ['reminder_1d']);
      await container.read(appointmentListProvider.notifier).addAppointment(initial);

      final oldId = NotificationIdManager.getAppointmentReminderId(
        appointmentId: initial.id,
        reminderKey: 'reminder_1d',
      );
      expect(fakeClient.scheduledNotifications.any((n) => n['id'] == oldId), isTrue);

      // Change reminder from 1 day to 1 hour
      final updated = initial.copyWith(reminderTime: 'reminder_1h', selectedReminders: ['reminder_1h']);
      await container.read(appointmentListProvider.notifier).updateAppointment(updated);

      // Old notification cancelled
      expect(fakeClient.cancelledIds, contains(oldId));

      // New notification scheduled
      final newId = NotificationIdManager.getAppointmentReminderId(
        appointmentId: initial.id,
        reminderKey: 'reminder_1h',
      );
      expect(fakeClient.scheduledNotifications.any((n) => n['id'] == newId), isTrue);
    });

    test('7. changing appointment time removes old schedule and schedules at new time', () async {
      final initial = createTestAppointment(time: '10:00', reminderTime: 'reminder_1h', selectedReminders: ['reminder_1h']);
      await container.read(appointmentListProvider.notifier).addAppointment(initial);

      final id = NotificationIdManager.getAppointmentReminderId(
        appointmentId: initial.id,
        reminderKey: 'reminder_1h',
      );

      // Change appointment time from 10:00 to 16:00
      final updated = initial.copyWith(time: '16:00');
      await container.read(appointmentListProvider.notifier).updateAppointment(updated);

      expect(fakeClient.cancelledIds, contains(id));

      final latestSchedule = fakeClient.scheduledNotifications.last;
      expect(latestSchedule['id'], id);
      final schedule = latestSchedule['schedule'] as NotificationCalendar;
      final expectedReminder = updated.fullDateTime.subtract(const Duration(hours: 1));
      expect(schedule.year, expectedReminder.year);
      expect(schedule.month, expectedReminder.month);
      expect(schedule.day, expectedReminder.day);
      expect(schedule.hour, expectedReminder.hour);
      expect(schedule.minute, expectedReminder.minute);
    });

    test('8. changing appointment date removes old schedule and schedules on new date', () async {
      final initial = createTestAppointment(date: '2026-10-15', reminderTime: 'reminder_1h', selectedReminders: ['reminder_1h']);
      await container.read(appointmentListProvider.notifier).addAppointment(initial);

      final id = NotificationIdManager.getAppointmentReminderId(
        appointmentId: initial.id,
        reminderKey: 'reminder_1h',
      );

      // Change appointment date to 2026-10-25
      final updated = initial.copyWith(date: '2026-10-25');
      await container.read(appointmentListProvider.notifier).updateAppointment(updated);

      expect(fakeClient.cancelledIds, contains(id));

      final latestSchedule = fakeClient.scheduledNotifications.last;
      final schedule = latestSchedule['schedule'] as NotificationCalendar;
      final expectedReminder = updated.fullDateTime.subtract(const Duration(hours: 1));
      expect(schedule.year, expectedReminder.year);
      expect(schedule.month, expectedReminder.month);
      expect(schedule.day, expectedReminder.day);
      expect(schedule.hour, expectedReminder.hour);
      expect(schedule.minute, expectedReminder.minute);
    });

    test('9. deleting appointment cancels all associated notifications and deletes from repo', () async {
      final app = createTestAppointment(
        selectedReminders: ['reminder_10m', 'reminder_1h'],
        reminderTime: 'reminder_1h',
      );
      await container.read(appointmentListProvider.notifier).addAppointment(app);

      final id10m = NotificationIdManager.getAppointmentReminderId(appointmentId: app.id, reminderKey: 'reminder_10m');
      final id1h = NotificationIdManager.getAppointmentReminderId(appointmentId: app.id, reminderKey: 'reminder_1h');

      await container.read(appointmentListProvider.notifier).deleteAppointment(app.id);

      expect(fakeClient.cancelledIds, contains(id10m));
      expect(fakeClient.cancelledIds, contains(id1h));
      expect(await fakeRepo.getById(app.id), isNull);
    });

    test('10. disabling reminder cancels notification without deleting appointment', () async {
      final app = createTestAppointment(reminderTime: 'reminder_1h', selectedReminders: ['reminder_1h']);
      await container.read(appointmentListProvider.notifier).addAppointment(app);

      final id = NotificationIdManager.getAppointmentReminderId(appointmentId: app.id, reminderKey: 'reminder_1h');
      final countBefore = fakeClient.createNotificationCallCount;

      // Disable reminder by clearing reminderTime and selectedReminders
      final disabled = app.copyWith(reminderTime: 'none', selectedReminders: []);
      await container.read(appointmentListProvider.notifier).updateAppointment(disabled);

      expect(fakeClient.cancelledIds, contains(id));
      expect(fakeClient.createNotificationCallCount, countBefore); // No new schedule
      expect(await fakeRepo.getById(app.id), isNotNull); // Appointment preserved
    });

    test('11. re-enabling reminder schedules notification again', () async {
      final disabledApp = createTestAppointment(reminderTime: 'none', selectedReminders: []);
      await container.read(appointmentListProvider.notifier).addAppointment(disabledApp);
      expect(fakeClient.createNotificationCallCount, 0);

      // Re-enable reminder
      final reEnabled = disabledApp.copyWith(reminderTime: 'reminder_1d', selectedReminders: ['reminder_1d']);
      await container.read(appointmentListProvider.notifier).updateAppointment(reEnabled);

      final id = NotificationIdManager.getAppointmentReminderId(appointmentId: reEnabled.id, reminderKey: 'reminder_1d');
      expect(fakeClient.scheduledNotifications.any((n) => n['id'] == id), isTrue);
    });

    test('12. scheduling failure does not crash appointment CRUD', () async {
      fakeClient.shouldThrowOnSchedule = true;

      final app = createTestAppointment();
      // Must complete normally without throwing
      await container.read(appointmentListProvider.notifier).addAppointment(app);

      final saved = await fakeRepo.getById(app.id);
      expect(saved, isNotNull);
      expect(saved!.title, 'Cardiology Consultation');
    });

    test('13. cancellation failure does not crash appointment CRUD', () async {
      final app = createTestAppointment();
      await container.read(appointmentListProvider.notifier).addAppointment(app);

      fakeClient.shouldThrowOnCancel = true;
      // Must complete normally without throwing
      await container.read(appointmentListProvider.notifier).deleteAppointment(app.id);

      final saved = await fakeRepo.getById(app.id);
      expect(saved, isNull);
    });

    test('14. sensitive appointment information is masked and never exposed in logs', () async {
      await fakePrefs.setBool('notification_hide_sensitive_content', true);

      final masked = NotificationEngine.safeText('Appointment with Dr. Oncologist at Cancer Clinic');
      expect(masked, 'Reminder details are hidden.');
      expect(masked.contains('Dr. Oncologist'), isFalse);
      expect(masked.contains('Cancer Clinic'), isFalse);
    });

    test('15. provider lifecycle remains safe during async notification operations', () async {
      final app = createTestAppointment(
        selectedReminders: ['reminder_10m', 'reminder_1h', 'reminder_1d'],
      );

      await expectLater(
        container.read(appointmentListProvider.notifier).addAppointment(app),
        completes,
      );

      expect(fakeClient.scheduledNotifications.length, 3);
      final list = await container.read(appointmentListProvider.future);
      expect(list.length, 1);
      expect(list.first.id, app.id);
    });
  });
}
