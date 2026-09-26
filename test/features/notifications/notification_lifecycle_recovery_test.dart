import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:vitacase/core/bootstrap/app_bootstrap_controller.dart';
import 'package:vitacase/core/di/repository_providers.dart';
import 'package:vitacase/core/notifications/notification_id_manager.dart';
import 'package:vitacase/core/types/runtime_types.dart';
import 'package:vitacase/features/appointments/domain/entities/appointment.dart';
import 'package:vitacase/features/appointments/presentation/providers/appointment_providers.dart';
import 'package:vitacase/features/dashboard/presentation/providers/app_lifecycle_controller.dart';
import 'package:vitacase/features/medications/domain/entities/medicine.dart';
import 'package:vitacase/shared/data/services/notification_service.dart';
import 'package:vitacase/shared/data/services/usage_limit_service.dart';
import 'package:vitacase/shared/domain/enums/appointment_status.dart';
import 'package:vitacase/shared/domain/enums/common_enums.dart';
import 'package:vitacase/shared/domain/repositories/appointment_repository.dart';
import 'package:vitacase/shared/domain/repositories/medicine_repository.dart';
import 'package:vitacase/shared/providers/medicine_providers.dart';
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

  void Function(NotificationResponse)? capturedResponseCallback;

  @override
  Future<bool> initialize({
    required void Function(NotificationResponse) onDidReceiveNotificationResponse,
    bool useFallbackIcon = false,
  }) async {
    initializeCallCount++;
    capturedResponseCallback = onDidReceiveNotificationResponse;
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
    // Remove previous schedule with identical id to emulate OS AlarmManager replacement
    scheduledNotifications.removeWhere((n) => n['id'] == id);
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
    scheduledNotifications.removeWhere((n) => n['id'] == id);
  }

  @override
  Future<void> cancelAll() async {
    cancelAllCallCount++;
    if (shouldThrowOnCancel) {
      throw Exception('Simulated platform cancelAll failure');
    }
    cancelledIds.clear();
    scheduledNotifications.clear();
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

class InMemoryMedicineRepository implements MedicineRepository {
  final Map<String, Medicine> _store = {};

  @override
  Future<void> save(Medicine medicine) async {
    _store[medicine.id] = medicine;
  }

  @override
  Future<Medicine?> getById(String id) async {
    return _store[id];
  }

  @override
  Future<List<Medicine>> getAll() async {
    return _store.values.toList();
  }

  @override
  Future<void> update(Medicine medicine) async {
    _store[medicine.id] = medicine;
  }

  @override
  Future<void> delete(String id) async {
    _store.remove(id);
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
  late InMemoryMedicineRepository fakeMedRepo;
  late InMemoryAppointmentRepository fakeApptRepo;
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

    fakeMedRepo = InMemoryMedicineRepository();
    fakeApptRepo = InMemoryAppointmentRepository();

    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(fakePrefs),
        medicineRepositoryProvider.overrideWithValue(fakeMedRepo),
        appointmentRepositoryProvider.overrideWithValue(fakeApptRepo),
        usageLimitServiceProvider.overrideWithValue(FakeUsageLimitService()),
      ],
    );
  });

  tearDown(() {
    container.dispose();
    NotificationService.resetForTesting();
  });

  Medicine createTestMedicine({
    String id = 'med_rec_1',
    String name = 'Metformin',
    List<String> reminderTimes = const ['08:00', '20:00'],
  }) {
    return Medicine(
      id: id,
      name: name,
      dosage: '500mg',
      frequency: 'daily',
      hungerStatus: HungerStatus.tok,
      startDate: '2026-09-26',
      reminderTimes: reminderTimes,
      currentStock: 30,
      totalStock: 30,
      createdAt: DateTime(2026, 9, 26, 10, 0),
    );
  }

  Appointment createTestAppointment({
    String id = 'appt_rec_1',
    String doctor = 'Dr. Gregory',
    String date = '2026-10-20',
    String time = '11:00',
    String? reminderTime = 'reminder_1h',
    List<String> selectedReminders = const ['reminder_1h'],
  }) {
    return Appointment(
      id: id,
      title: 'Consultation',
      doctor: doctor,
      department: 'General',
      hospital: 'Central Clinic',
      date: date,
      time: time,
      status: AppointmentStatus.upcoming,
      reminderTime: reminderTime,
      selectedReminders: selectedReminders,
      createdAt: DateTime(2026, 9, 26, 10, 0),
    );
  }

  group('Phase 9 — Notification Lifecycle & Recovery Tests', () {
    test('1. notification initialization is idempotent across multiple calls', () async {
      expect(NotificationService.isInitialized, isFalse);

      await NotificationService.initCore();
      expect(NotificationService.isInitialized, isTrue);
      expect(fakeAdapter.initializeCallCount, 1);

      // Subsequent calls must be no-op
      await NotificationService.initCore();
      await NotificationService.initCore();
      expect(fakeAdapter.initializeCallCount, 1);
    });

    test('2. repeated bootstrap does not duplicate initialization', () async {
      await NotificationService.initCore();
      expect(fakeAdapter.initializeCallCount, 1);

      // Simulating repeated bootstrap calls
      final bootstrapNotifier = container.read(appBootstrapProvider.notifier);
      await bootstrapNotifier.forceRescheduleNotifications();

      expect(fakeAdapter.initializeCallCount, 1);
    });

    test('3. timezone initializes before scheduling occurs', () async {
      // Timezone must be initialized and tz.local must be valid
      NotificationService.ensureTimezoneInitialized();
      expect(() => tz.local, returnsNormally);

      final scheduledDate = tz.TZDateTime.now(tz.local).add(const Duration(hours: 2));
      expect(scheduledDate.isAfter(tz.TZDateTime.now(tz.local)), isTrue);
    });

    test('4. app restart does not duplicate deterministic reminders', () async {
      final med = createTestMedicine(reminderTimes: ['09:00']);
      await container.read(medicineListProvider.notifier).addMedicine(med);

      expect(fakeAdapter.scheduledNotifications.length, 1);
      final initialScheduleCount = fakeAdapter.zonedScheduleCallCount;
      expect(initialScheduleCount, 1);

      // Simulate app restart: rescheduleAllNotifications runs during startup
      final medsFromDb = await fakeMedRepo.getAll();
      await container.read(medicineListProvider.notifier).rescheduleAllNotifications(medsFromDb);

      // Since notification is already scheduled with same payload & time, zonedSchedule is NOT called again
      expect(fakeAdapter.zonedScheduleCallCount, initialScheduleCount);
      expect(fakeAdapter.scheduledNotifications.length, 1);
    });

    test('5. recovery does not recreate deleted medicine reminders', () async {
      final med = createTestMedicine(reminderTimes: ['08:00']);
      await container.read(medicineListProvider.notifier).addMedicine(med);

      final medId = NotificationIdManager.getMedicineReminderId(medicineId: med.id, reminderTime: '08:00');
      expect(fakeAdapter.scheduledNotifications.any((n) => n['id'] == medId), isTrue);

      // Medicine is deleted from database
      await container.read(medicineListProvider.notifier).deleteMedicine(med.id);
      expect(fakeAdapter.scheduledNotifications.any((n) => n['id'] == medId), isFalse);

      // Run recovery with current database contents (which has 0 medicines)
      final medsInDb = await fakeMedRepo.getAll();
      expect(medsInDb, isEmpty);
      await container.read(medicineListProvider.notifier).rescheduleAllNotifications(medsInDb);

      // Deleted medicine reminder must NOT be recreated
      expect(fakeAdapter.scheduledNotifications.any((n) => n['id'] == medId), isFalse);
    });

    test('6. recovery does not recreate deleted appointment reminders', () async {
      final appt = createTestAppointment();
      await container.read(appointmentListProvider.notifier).addAppointment(appt);

      final apptId = NotificationIdManager.getAppointmentReminderId(
        appointmentId: appt.id,
        reminderKey: 'reminder_1h',
      );
      expect(fakeAdapter.scheduledNotifications.any((n) => n['id'] == apptId), isTrue);

      // Appointment is deleted
      await container.read(appointmentListProvider.notifier).deleteAppointment(appt.id);
      expect(fakeAdapter.scheduledNotifications.any((n) => n['id'] == apptId), isFalse);

      // Run recovery
      final apptsInDb = await fakeApptRepo.getAll();
      expect(apptsInDb, isEmpty);
      await container.read(appointmentListProvider.notifier).rescheduleAllNotifications(apptsInDb);

      // Deleted appointment reminder must NOT be recreated
      expect(fakeAdapter.scheduledNotifications.any((n) => n['id'] == apptId), isFalse);
    });

    test('7. disabled reminders are not recreated during recovery', () async {
      // Medicine with reminders disabled
      final med = createTestMedicine(reminderTimes: []);
      await container.read(medicineListProvider.notifier).addMedicine(med);
      expect(fakeAdapter.scheduledNotifications, isEmpty);

      // Recovery runs
      final meds = await fakeMedRepo.getAll();
      await container.read(medicineListProvider.notifier).rescheduleAllNotifications(meds);
      expect(fakeAdapter.scheduledNotifications, isEmpty);

      // Appointment with reminders disabled
      final appt = createTestAppointment(reminderTime: 'none', selectedReminders: []);
      await container.read(appointmentListProvider.notifier).addAppointment(appt);
      expect(fakeAdapter.scheduledNotifications, isEmpty);

      // Recovery runs
      final appts = await fakeApptRepo.getAll();
      await container.read(appointmentListProvider.notifier).rescheduleAllNotifications(appts);
      expect(fakeAdapter.scheduledNotifications, isEmpty);
    });

    test('8. updated reminders do not restore stale IDs during recovery', () async {
      final appt = createTestAppointment(reminderTime: 'reminder_1h', selectedReminders: ['reminder_1h']);
      await container.read(appointmentListProvider.notifier).addAppointment(appt);

      final oldId = NotificationIdManager.getAppointmentReminderId(
        appointmentId: appt.id,
        reminderKey: 'reminder_1h',
      );
      expect(fakeAdapter.scheduledNotifications.any((n) => n['id'] == oldId), isTrue);

      // Update reminder to 10m
      final updated = appt.copyWith(reminderTime: 'reminder_10m', selectedReminders: ['reminder_10m']);
      await container.read(appointmentListProvider.notifier).updateAppointment(updated);

      final newId = NotificationIdManager.getAppointmentReminderId(
        appointmentId: appt.id,
        reminderKey: 'reminder_10m',
      );
      expect(fakeAdapter.scheduledNotifications.any((n) => n['id'] == newId), isTrue);
      expect(fakeAdapter.scheduledNotifications.any((n) => n['id'] == oldId), isFalse);

      // Simulate recovery: oldId must NOT be restored
      final apptsInDb = await fakeApptRepo.getAll();
      await container.read(appointmentListProvider.notifier).rescheduleAllNotifications(apptsInDb);

      expect(fakeAdapter.scheduledNotifications.any((n) => n['id'] == oldId), isFalse);
      expect(fakeAdapter.scheduledNotifications.any((n) => n['id'] == newId), isTrue);
    });

    test('9. current reminders remain recoverable after state reload', () async {
      final med = createTestMedicine(reminderTimes: ['14:00']);
      await fakeMedRepo.save(med);

      final appt = createTestAppointment();
      await fakeApptRepo.save(appt);

      expect(fakeAdapter.scheduledNotifications, isEmpty);

      // Run recovery
      await container.read(medicineListProvider.notifier).rescheduleAllNotifications([med]);
      await container.read(appointmentListProvider.notifier).rescheduleAllNotifications([appt]);

      final medId = NotificationIdManager.getMedicineReminderId(medicineId: med.id, reminderTime: '14:00');
      final apptId = NotificationIdManager.getAppointmentReminderId(
        appointmentId: appt.id,
        reminderKey: 'reminder_1h',
      );

      expect(fakeAdapter.scheduledNotifications.any((n) => n['id'] == medId), isTrue);
      expect(fakeAdapter.scheduledNotifications.any((n) => n['id'] == apptId), isTrue);
    });

    test('10. background lifecycle transition does not cancel valid alarms', () async {
      final med = createTestMedicine(reminderTimes: ['08:00']);
      await container.read(medicineListProvider.notifier).addMedicine(med);

      expect(fakeAdapter.scheduledNotifications.length, 1);
      final cancelCountBefore = fakeAdapter.cancelCallCount;

      // App transitions to paused (background)
      container.read(appLifecycleProvider.notifier).handleLifecycleState(AppLifecycleState.paused);

      // Alarms must remain untouched
      expect(fakeAdapter.cancelCallCount, cancelCountBefore);
      expect(fakeAdapter.scheduledNotifications.length, 1);
    });

    test('11. resume lifecycle transition does not duplicate reminders', () async {
      final med = createTestMedicine(reminderTimes: ['08:00']);
      await container.read(medicineListProvider.notifier).addMedicine(med);

      final initialSchedules = fakeAdapter.zonedScheduleCallCount;

      // App goes to paused then resumes
      container.read(appLifecycleProvider.notifier).handleLifecycleState(AppLifecycleState.paused);
      container.read(appLifecycleProvider.notifier).handleLifecycleState(AppLifecycleState.resumed);
      await Future.delayed(const Duration(milliseconds: 50));

      // Resume must not trigger duplicate alarms
      expect(fakeAdapter.zonedScheduleCallCount, initialSchedules);
      expect(fakeAdapter.scheduledNotifications.length, 1);
    });

    test('12. notification lifecycle failures do not crash startup', () async {
      fakeAdapter.shouldThrowOnInitialize = true;

      // Should not throw or crash
      await NotificationService.initCore();
      expect(NotificationService.isInitialized, isTrue);

      fakeAdapter.shouldThrowOnSchedule = true;
      final med = createTestMedicine();
      // Should not throw or crash
      await container.read(medicineListProvider.notifier).addMedicine(med);
      expect(await fakeMedRepo.getById(med.id), isNotNull);
    });

    test('13. boot recovery logic safely handles platform error without crashing', () async {
      fakeAdapter.shouldThrowOnSchedule = true;
      final med = createTestMedicine();

      // Calling rescheduleAllNotifications must catch safely
      await container.read(medicineListProvider.notifier).rescheduleAllNotifications([med]);
      // App remains intact
      expect(container.read(medicineListProvider).hasValue, isTrue);
    });

    test('14. notification action callbacks remain safe and contain errors', () async {
      await NotificationService.initCore();

      bool callbackExecuted = false;
      NotificationService.setMedicineActionHandlers(
        onTaken: (id) async {
          callbackExecuted = true;
          throw Exception('Simulated callback failure');
        },
        onSkipped: (id) async {},
      );

      final response = const NotificationResponse(
        notificationResponseType: NotificationResponseType.selectedNotificationAction,
        id: 12345,
        actionId: 'TAKEN',
        payload: '{"type":"medication","entityId":"med_test"}',
      );

      // Firing callback should not crash
      expect(() => fakeAdapter.capturedResponseCallback?.call(response), returnsNormally);
      await Future.delayed(const Duration(milliseconds: 50));
      expect(callbackExecuted, isTrue);
    });

    test('15. provider lifecycle remains safe across async recovery operations', () async {
      await NotificationService.initCore();

      final med = createTestMedicine(reminderTimes: ['08:00']);
      await fakeMedRepo.save(med);

      final future = container.read(medicineListProvider.notifier).rescheduleAllNotifications([med]);
      // Awaiting async recovery must complete normally without provider lifecycle violation
      await expectLater(future, completes);
      expect(container.read(medicineListProvider).hasValue, isTrue);
    });

    test('16. sensitive information is masked and never exposed during recovery', () async {
      await NotificationService.initCore();

      const sensitiveNote = 'Very Private Clinical Diagnosis & Notes';
      final safeText = NotificationService.safeText(sensitiveNote);

      expect(safeText, isNot(contains(sensitiveNote)));
      expect(safeText, isNot(contains('Diagnosis')));
      expect(safeText, contains('reminder'));
    });
  });
}
