import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:vitacase/core/di/repository_providers.dart';
import 'package:vitacase/core/notifications/notification_id_manager.dart';
import 'package:vitacase/core/types/runtime_types.dart';
import 'package:vitacase/features/appointments/domain/entities/appointment.dart';
import 'package:vitacase/features/appointments/presentation/providers/appointment_providers.dart';
import 'package:vitacase/shared/data/services/notification_service.dart';
import 'package:vitacase/shared/data/services/usage_limit_service.dart';
import 'package:vitacase/shared/domain/enums/appointment_status.dart';
import 'package:vitacase/shared/domain/repositories/appointment_repository.dart';
import 'package:vitacase/shared/providers/shared_prefs_provider.dart';

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
  Future<void> updateStatus(String id, AppointmentStatus status) async {
    final existing = _store[id];
    if (existing != null) {
      _store[id] = existing.copyWith(status: status);
    }
  }

  @override
  Future<void> delete(String id) async {
    _store.remove(id);
  }

  @override
  Future<Appointment?> getNextUpcoming() async {
    return _store.values.firstOrNull;
  }
}

class FakeUsageLimitService extends Fake implements UsageLimitService {
  @override
  Future<UsageLimitResult> consumeCreate() async =>
      const UsageLimitResult(allowed: true, used: 0, limit: 100);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeNotificationPlatformAdapter fakeAdapter;
  late InMemoryAppointmentRepository fakeRepo;
  late SharedPreferences fakePrefs;
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'notification_hide_sensitive_content': true,
      'app_locale': 'en',
    });
    fakePrefs = await SharedPreferences.getInstance();

    NotificationService.resetForTesting();
    fakeAdapter = FakeNotificationPlatformAdapter();
    NotificationService.setAdapterForTesting(fakeAdapter);
    await NotificationService.initCore();

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
    NotificationService.resetForTesting();
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

      expect(fakeAdapter.zonedScheduleCallCount, 1);
      final record = fakeAdapter.scheduledNotifications.first;

      expect(record['isMedication'], isFalse);
      expect(record['channelId'], 'vitacase_channel');
      // Sensitive body is masked when hide_sensitive_content is true
      expect(record['body'], 'You have a reminder');

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
      expect(fakeAdapter.scheduledNotifications.any((n) => n['id'] == oldId), isTrue);

      // Change reminder from 1 day to 1 hour
      final updated = initial.copyWith(reminderTime: 'reminder_1h', selectedReminders: ['reminder_1h']);
      await container.read(appointmentListProvider.notifier).updateAppointment(updated);

      // Old notification cancelled
      expect(fakeAdapter.cancelledIds, contains(oldId));

      // New notification scheduled
      final newId = NotificationIdManager.getAppointmentReminderId(
        appointmentId: initial.id,
        reminderKey: 'reminder_1h',
      );
      expect(fakeAdapter.scheduledNotifications.any((n) => n['id'] == newId), isTrue);
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

      expect(fakeAdapter.cancelledIds, contains(id));

      final latestSchedule = fakeAdapter.scheduledNotifications.last;
      expect(latestSchedule['id'], id);
      final scheduledDate = latestSchedule['scheduledDate'] as tz.TZDateTime;
      final expectedReminder = updated.fullDateTime.subtract(const Duration(hours: 1));
      expect(scheduledDate.isAtSameMomentAs(expectedReminder), isTrue);
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

      expect(fakeAdapter.cancelledIds, contains(id));

      final latestSchedule = fakeAdapter.scheduledNotifications.last;
      final scheduledDate = latestSchedule['scheduledDate'] as tz.TZDateTime;
      final expectedReminder = updated.fullDateTime.subtract(const Duration(hours: 1));
      expect(scheduledDate.isAtSameMomentAs(expectedReminder), isTrue);
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

      expect(fakeAdapter.cancelledIds, contains(id10m));
      expect(fakeAdapter.cancelledIds, contains(id1h));
      expect(await fakeRepo.getById(app.id), isNull);
    });

    test('10. disabling reminder cancels notification without deleting appointment', () async {
      final app = createTestAppointment(reminderTime: 'reminder_1h', selectedReminders: ['reminder_1h']);
      await container.read(appointmentListProvider.notifier).addAppointment(app);

      final id = NotificationIdManager.getAppointmentReminderId(appointmentId: app.id, reminderKey: 'reminder_1h');
      final countBefore = fakeAdapter.zonedScheduleCallCount;

      // Disable reminder by clearing reminderTime and selectedReminders
      final disabled = app.copyWith(reminderTime: 'none', selectedReminders: []);
      await container.read(appointmentListProvider.notifier).updateAppointment(disabled);

      expect(fakeAdapter.cancelledIds, contains(id));
      expect(fakeAdapter.zonedScheduleCallCount, countBefore); // No new schedule
      expect(await fakeRepo.getById(app.id), isNotNull); // Appointment preserved
    });

    test('11. re-enabling reminder schedules notification again', () async {
      final disabledApp = createTestAppointment(reminderTime: 'none', selectedReminders: []);
      await container.read(appointmentListProvider.notifier).addAppointment(disabledApp);
      expect(fakeAdapter.zonedScheduleCallCount, 0);

      // Re-enable reminder
      final reEnabled = disabledApp.copyWith(reminderTime: 'reminder_1d', selectedReminders: ['reminder_1d']);
      await container.read(appointmentListProvider.notifier).updateAppointment(reEnabled);

      final id = NotificationIdManager.getAppointmentReminderId(appointmentId: reEnabled.id, reminderKey: 'reminder_1d');
      expect(fakeAdapter.scheduledNotifications.any((n) => n['id'] == id), isTrue);
    });

    test('12. scheduling failure does not crash appointment CRUD', () async {
      fakeAdapter.shouldThrowOnSchedule = true;

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

      fakeAdapter.shouldThrowOnCancel = true;
      // Must complete normally without throwing
      await container.read(appointmentListProvider.notifier).deleteAppointment(app.id);

      final saved = await fakeRepo.getById(app.id);
      expect(saved, isNull);
    });

    test('14. sensitive appointment information is masked and never exposed in logs', () async {
      await fakePrefs.setBool('notification_hide_sensitive_content', true);

      final masked = NotificationService.safeText('Appointment with Dr. Oncologist at Cancer Clinic');
      expect(masked, 'You have a reminder');
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

      expect(fakeAdapter.scheduledNotifications.length, 3);
      final list = await container.read(appointmentListProvider.future);
      expect(list.length, 1);
      expect(list.first.id, app.id);
    });
  });
}
