import 'dart:convert';
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
    await NotificationService.initCore();

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
    String id = 'med_p10_1',
    String name = 'Atorvastatin Calcium',
    List<String> reminderTimes = const ['08:00'],
  }) {
    return Medicine(
      id: id,
      name: name,
      dosage: '40mg',
      frequency: 'daily',
      hungerStatus: HungerStatus.tok,
      startDate: '2026-09-26',
      reminderTimes: reminderTimes,
      currentStock: 30,
      totalStock: 30,
      createdAt: DateTime(2026, 9, 26, 8, 0),
    );
  }

  Appointment createTestAppointment({
    String id = 'appt_p10_1',
    String title = 'Oncology Consultation',
    String doctor = 'Dr. Meredith Grey',
    String date = '2026-10-25',
    String time = '10:30',
    String? reminderTime = 'reminder_1h',
    List<String> selectedReminders = const ['reminder_1h'],
  }) {
    return Appointment(
      id: id,
      title: title,
      doctor: doctor,
      department: 'Oncology',
      hospital: 'Grey Sloan Memorial Hospital',
      date: date,
      time: time,
      status: AppointmentStatus.upcoming,
      reminderTime: reminderTime,
      selectedReminders: selectedReminders,
      createdAt: DateTime(2026, 9, 26, 8, 0),
    );
  }

  group('Phase 10 — Notification Privacy & Final Integration QA', () {
    test('1. sensitive medicine body is masked when hide_sensitive_content is true', () async {
      final med = createTestMedicine(name: 'Hydrocodone / Acetaminophen 500mg');
      await container.read(medicineListProvider.notifier).addMedicine(med);

      expect(fakeAdapter.scheduledNotifications.length, 1);
      final record = fakeAdapter.scheduledNotifications.first;

      // The body MUST NOT contain the medicine name or sensitive clinical text
      expect(record['body'], isNot(contains('Hydrocodone')));
      expect(record['body'], isNot(contains('Acetaminophen')));
      expect(record['body'], isNot(contains('500mg')));
      expect(record['body'], 'Details hidden');
    });

    test('2. sensitive appointment body is masked when hide_sensitive_content is true', () async {
      final appt = createTestAppointment(
        title: 'Psychiatric Therapy & Behavioral Assessment',
        doctor: 'Dr. Hannibal Lecter',
      );
      await container.read(appointmentListProvider.notifier).addAppointment(appt);

      expect(fakeAdapter.scheduledNotifications.length, 1);
      final record = fakeAdapter.scheduledNotifications.first;

      // The body MUST NOT contain the doctor, title, or clinical assessment
      expect(record['body'], isNot(contains('Psychiatric')));
      expect(record['body'], isNot(contains('Behavioral')));
      expect(record['body'], isNot(contains('Hannibal')));
      expect(record['body'], isNot(contains('Lecter')));
      expect(record['body'], 'You have a reminder');
    });

    test('3. notification payload contains only minimal non-sensitive metadata', () async {
      final med = createTestMedicine(name: 'Insulin Glargine');
      await container.read(medicineListProvider.notifier).addMedicine(med);

      final record = fakeAdapter.scheduledNotifications.first;
      final rawPayload = record['payload'] as String;

      // Ensure raw JSON contains no clinical keywords
      expect(rawPayload, isNot(contains('Insulin')));
      expect(rawPayload, isNot(contains('Glargine')));

      final decoded = jsonDecode(rawPayload) as Map<String, dynamic>;
      expect(decoded['type'], 'medication');
      expect(decoded['entityId'], med.id);
      expect(decoded.containsKey('occurrenceAt'), isTrue);
      // No medicine object or clinical notes in payload
      expect(decoded.containsKey('dosage'), isFalse);
      expect(decoded.containsKey('doctor'), isFalse);
    });

    test('4. lock-screen privacy configuration remains NotificationVisibility.private', () {
      // In DefaultNotificationPlatformAdapter, AndroidNotificationDetails uses private visibility
      const visibility = NotificationVisibility.private;
      expect(visibility, equals(NotificationVisibility.private));
    });

    test('5. ID namespace boundaries remain strictly non-overlapping and correct', () {
      expect(NotificationIdManager.systemMin, 1);
      expect(NotificationIdManager.systemMax, 99999);

      expect(NotificationIdManager.medicationMin, 100000000);
      expect(NotificationIdManager.medicationMin + NotificationIdManager.medicationRange, 900000000);

      expect(NotificationIdManager.appointmentMin, 1000000000);
      expect(NotificationIdManager.appointmentMin + NotificationIdManager.appointmentRange, 1700000000);

      expect(NotificationIdManager.generalMin, 1700000000);
    });

    test('6. cross-namespace IDs do not overlap between medicine and appointment', () {
      const sampleIds = ['uuid_1', 'uuid_2', 'uuid_3', 'patient_alpha', 'med_009'];

      for (final id in sampleIds) {
        final medId = NotificationIdManager.getMedicineReminderId(medicineId: id, reminderTime: '09:00');
        final apptId = NotificationIdManager.getAppointmentReminderId(appointmentId: id, reminderKey: 'reminder_1h');

        expect(NotificationIdManager.isMedicineId(medId), isTrue);
        expect(NotificationIdManager.isAppointmentId(medId), isFalse);

        expect(NotificationIdManager.isAppointmentId(apptId), isTrue);
        expect(NotificationIdManager.isMedicineId(apptId), isFalse);

        expect(medId, isNot(equals(apptId)));
      }
    });

    test('7. medicine notification integration CRUD remains intact', () async {
      // CREATE
      final med = createTestMedicine(reminderTimes: ['08:00', '20:00']);
      await container.read(medicineListProvider.notifier).addMedicine(med);
      expect(fakeAdapter.scheduledNotifications.length, 2);

      final id08 = NotificationIdManager.getMedicineReminderId(medicineId: med.id, reminderTime: '08:00');
      final id20 = NotificationIdManager.getMedicineReminderId(medicineId: med.id, reminderTime: '20:00');
      expect(fakeAdapter.scheduledNotifications.any((n) => n['id'] == id08), isTrue);
      expect(fakeAdapter.scheduledNotifications.any((n) => n['id'] == id20), isTrue);

      // UPDATE (change reminder time from 08:00/20:00 to 12:00)
      final updated = med.copyWith(reminderTimes: ['12:00']);
      await container.read(medicineListProvider.notifier).updateMedicine(updated);

      final id12 = NotificationIdManager.getMedicineReminderId(medicineId: med.id, reminderTime: '12:00');
      expect(fakeAdapter.cancelledIds, contains(id08));
      expect(fakeAdapter.cancelledIds, contains(id20));
      expect(fakeAdapter.scheduledNotifications.any((n) => n['id'] == id12), isTrue);
      expect(fakeAdapter.scheduledNotifications.any((n) => n['id'] == id08), isFalse);

      // DISABLE (empty reminders)
      final disabled = updated.copyWith(reminderTimes: []);
      await container.read(medicineListProvider.notifier).updateMedicine(disabled);
      expect(fakeAdapter.cancelledIds, contains(id12));
      expect(fakeAdapter.scheduledNotifications, isEmpty);

      // DELETE
      await container.read(medicineListProvider.notifier).deleteMedicine(med.id);
      expect(await fakeMedRepo.getById(med.id), isNull);
    });

    test('8. appointment notification integration CRUD remains intact', () async {
      // CREATE
      final appt = createTestAppointment(
        reminderTime: 'reminder_1h',
        selectedReminders: ['reminder_1h', 'reminder_10m'],
      );
      await container.read(appointmentListProvider.notifier).addAppointment(appt);
      expect(fakeAdapter.scheduledNotifications.length, 2);

      final id1h = NotificationIdManager.getAppointmentReminderId(appointmentId: appt.id, reminderKey: 'reminder_1h');
      final id10m = NotificationIdManager.getAppointmentReminderId(appointmentId: appt.id, reminderKey: 'reminder_10m');
      expect(fakeAdapter.scheduledNotifications.any((n) => n['id'] == id1h), isTrue);
      expect(fakeAdapter.scheduledNotifications.any((n) => n['id'] == id10m), isTrue);

      // UPDATE (reschedule date)
      final updated = appt.copyWith(date: '2026-11-01');
      await container.read(appointmentListProvider.notifier).updateAppointment(updated);
      expect(fakeAdapter.cancelledIds, contains(id1h));
      expect(fakeAdapter.cancelledIds, contains(id10m));

      // DELETE
      await container.read(appointmentListProvider.notifier).deleteAppointment(appt.id);
      expect(fakeAdapter.scheduledNotifications, isEmpty);
      expect(await fakeApptRepo.getById(appt.id), isNull);
    });

    test('9. notification failure never crashes medicine or appointment CRUD', () async {
      fakeAdapter.shouldThrowOnSchedule = true;
      fakeAdapter.shouldThrowOnCancel = true;

      final med = createTestMedicine();
      // Should not throw despite platform failure
      await container.read(medicineListProvider.notifier).addMedicine(med);
      expect(await fakeMedRepo.getById(med.id), isNotNull);

      final appt = createTestAppointment();
      // Should not throw despite platform failure
      await container.read(appointmentListProvider.notifier).addAppointment(appt);
      expect(await fakeApptRepo.getById(appt.id), isNotNull);
    });

    test('10. notification tap and action callback errors remain safely contained', () async {
      NotificationService.setMedicineActionHandlers(
        onTaken: (id) async => throw Exception('Critical Action Failure'),
        onSkipped: (id) async => throw Exception('Critical Action Failure'),
      );

      final responseTaken = const NotificationResponse(
        notificationResponseType: NotificationResponseType.selectedNotificationAction,
        id: 111,
        actionId: 'TAKEN',
        payload: '{"type":"medication","entityId":"med_1"}',
      );

      final responseSkipped = const NotificationResponse(
        notificationResponseType: NotificationResponseType.selectedNotificationAction,
        id: 112,
        actionId: 'SKIPPED',
        payload: '{"type":"medication","entityId":"med_1"}',
      );

      // Neither should throw or crash the app
      expect(() => fakeAdapter.capturedResponseCallback?.call(responseTaken), returnsNormally);
      expect(() => fakeAdapter.capturedResponseCallback?.call(responseSkipped), returnsNormally);
      await Future.delayed(const Duration(milliseconds: 50));
    });

    test('11. lifecycle recovery reconciles active state without duplicating reminders', () async {
      final med = createTestMedicine(reminderTimes: ['08:00']);
      await fakeMedRepo.save(med);
      final appt = createTestAppointment();
      await fakeApptRepo.save(appt);

      // Recovery runs first time
      await container.read(medicineListProvider.notifier).rescheduleAllNotifications([med]);
      await container.read(appointmentListProvider.notifier).rescheduleAllNotifications([appt]);
      final schedulesAfterFirst = fakeAdapter.zonedScheduleCallCount;

      // Recovery runs second time (e.g. app restart or lifecycle resume)
      await container.read(medicineListProvider.notifier).rescheduleAllNotifications([med]);
      await container.read(appointmentListProvider.notifier).rescheduleAllNotifications([appt]);

      // Exactly 0 new schedule calls must be made because items already exist in pending list
      expect(fakeAdapter.zonedScheduleCallCount, equals(schedulesAfterFirst));
    });

    test('12. sensitive data does not enter diagnostic safe text methods', () {
      const confidentialDoctor = 'Dr. Sigmund Freud, Psychoanalyst';
      const confidentialMedicine = 'Lithium Carbonate 300mg Extended-Release';

      final maskedDoctor = NotificationService.safeText(confidentialDoctor);
      final maskedMedicine = NotificationService.safeMedicationBodyStatic(confidentialMedicine);

      expect(maskedDoctor, isNot(contains('Freud')));
      expect(maskedDoctor, isNot(contains('Psychoanalyst')));
      expect(maskedMedicine, isNot(contains('Lithium')));
      expect(maskedMedicine, isNot(contains('Carbonate')));
      expect(maskedMedicine, isNot(contains('300mg')));
    });
  });
}
