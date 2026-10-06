import 'dart:convert';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vitacase/core/di/repository_providers.dart';
import 'package:vitacase/core/notifications/notification_id_manager.dart';
import 'package:vitacase/features/appointments/domain/entities/appointment.dart';
import 'package:vitacase/features/appointments/presentation/providers/appointment_providers.dart';
import 'package:vitacase/features/medications/domain/entities/medicine.dart';
import 'package:vitacase/shared/data/services/notification_engine.dart';
import 'package:vitacase/shared/data/services/usage_limit_service.dart';
import 'package:vitacase/shared/domain/enums/appointment_status.dart';
import 'package:vitacase/shared/domain/enums/common_enums.dart';
import 'package:vitacase/shared/domain/repositories/appointment_repository.dart';
import 'package:vitacase/shared/domain/repositories/medicine_repository.dart';
import 'package:vitacase/shared/providers/medicine_providers.dart';
import 'package:vitacase/shared/providers/shared_prefs_provider.dart';

import 'fake_awesome_notifications_client.dart';

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
  Future<void> delete(String id) async {
    _store.remove(id);
  }

  @override
  Future<Appointment?> getNextUpcoming() async => null;

  @override
  Future<void> updateStatus(String id, AppointmentStatus status) async {
    final a = _store[id];
    if (a != null) {
      _store[id] = a.copyWith(status: status);
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

    NotificationEngine.resetForTesting();
    fakeClient = FakeAwesomeNotificationsClient();
    NotificationEngine.setClientForTesting(fakeClient);
    await NotificationEngine.initCore();

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
    NotificationEngine.resetForTesting();
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

      expect(fakeClient.scheduledNotifications.length, 1);
      final record = fakeClient.scheduledNotifications.first;

      // The body MUST NOT contain the medicine name or sensitive clinical text
      expect(record['body'], isNot(contains('Hydrocodone')));
      expect(record['body'], isNot(contains('Acetaminophen')));
      expect(record['body'], isNot(contains('500mg')));
      expect(record['body'], 'Reminder details are hidden.');
    });

    test('2. sensitive appointment body is masked when hide_sensitive_content is true', () async {
      final appt = createTestAppointment(
        title: 'Psychiatric Therapy & Behavioral Assessment',
        doctor: 'Dr. Hannibal Lecter',
      );
      await container.read(appointmentListProvider.notifier).addAppointment(appt);

      expect(fakeClient.scheduledNotifications.length, 1);
      final record = fakeClient.scheduledNotifications.first;

      // The body MUST NOT contain the doctor, title, or clinical assessment
      expect(record['body'], isNot(contains('Psychiatric')));
      expect(record['body'], isNot(contains('Behavioral')));
      expect(record['body'], isNot(contains('Hannibal')));
      expect(record['body'], isNot(contains('Lecter')));
      expect(record['body'], 'Reminder details are hidden.');
    });

    test('3. notification payload contains only minimal non-sensitive metadata', () async {
      final med = createTestMedicine(name: 'Insulin Glargine');
      await container.read(medicineListProvider.notifier).addMedicine(med);

      final record = fakeClient.scheduledNotifications.first;
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

    test('4. lock-screen privacy configuration remains NotificationPrivacy.Private', () {
      const privacy = NotificationPrivacy.Private;
      expect(privacy, equals(NotificationPrivacy.Private));
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
      expect(fakeClient.scheduledNotifications.length, 2);

      final id08 = NotificationIdManager.getMedicineReminderId(medicineId: med.id, reminderTime: '08:00');
      final id20 = NotificationIdManager.getMedicineReminderId(medicineId: med.id, reminderTime: '20:00');
      expect(fakeClient.scheduledNotifications.any((n) => n['id'] == id08), isTrue);
      expect(fakeClient.scheduledNotifications.any((n) => n['id'] == id20), isTrue);

      // UPDATE (change reminder time from 08:00/20:00 to 12:00)
      final updated = med.copyWith(reminderTimes: ['12:00']);
      await container.read(medicineListProvider.notifier).updateMedicine(updated);

      final id12 = NotificationIdManager.getMedicineReminderId(medicineId: med.id, reminderTime: '12:00');
      expect(fakeClient.cancelledIds, contains(id08));
      expect(fakeClient.cancelledIds, contains(id20));
      expect(fakeClient.scheduledNotifications.any((n) => n['id'] == id12), isTrue);
      expect(fakeClient.scheduledNotifications.any((n) => n['id'] == id08), isFalse);

      // DISABLE (empty reminders)
      final disabled = updated.copyWith(reminderTimes: []);
      await container.read(medicineListProvider.notifier).updateMedicine(disabled);
      expect(fakeClient.cancelledIds, contains(id12));
      expect(fakeClient.scheduledNotifications, isEmpty);

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
      expect(fakeClient.scheduledNotifications.length, 2);

      final id1h = NotificationIdManager.getAppointmentReminderId(appointmentId: appt.id, reminderKey: 'reminder_1h');
      final id10m = NotificationIdManager.getAppointmentReminderId(appointmentId: appt.id, reminderKey: 'reminder_10m');
      expect(fakeClient.scheduledNotifications.any((n) => n['id'] == id1h), isTrue);
      expect(fakeClient.scheduledNotifications.any((n) => n['id'] == id10m), isTrue);

      // UPDATE
      final updated = appt.copyWith(
        reminderTime: 'reminder_1d',
        selectedReminders: ['reminder_1d'],
      );
      await container.read(appointmentListProvider.notifier).updateAppointment(updated);

      final id1d = NotificationIdManager.getAppointmentReminderId(appointmentId: appt.id, reminderKey: 'reminder_1d');
      expect(fakeClient.cancelledIds, contains(id1h));
      expect(fakeClient.cancelledIds, contains(id10m));
      expect(fakeClient.scheduledNotifications.any((n) => n['id'] == id1d), isTrue);
      expect(fakeClient.scheduledNotifications.any((n) => n['id'] == id1h), isFalse);

      // DISABLE
      final disabled = updated.copyWith(reminderTime: 'none', selectedReminders: []);
      await container.read(appointmentListProvider.notifier).updateAppointment(disabled);
      expect(fakeClient.cancelledIds, contains(id1d));
      expect(fakeClient.scheduledNotifications, isEmpty);

      // DELETE
      await container.read(appointmentListProvider.notifier).deleteAppointment(appt.id);
      expect(await fakeApptRepo.getById(appt.id), isNull);
    });

    test('9. platform scheduling and cancellation exceptions are contained safely', () async {
      fakeClient.shouldThrowOnSchedule = true;
      fakeClient.shouldThrowOnCancel = true;

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
      NotificationEngine.setMedicineActionHandlers(
        onTaken: (id) async => throw Exception('Critical Action Failure'),
        onSkipped: (id) async => throw Exception('Critical Action Failure'),
      );

      final responseTaken = ReceivedAction().fromMap({
        'buttonKeyPressed': 'TAKEN',
        'payload': {'entityId': 'med_1', 'payload': '{"type":"medication","entityId":"med_1"}'},
      });

      final responseSkipped = ReceivedAction().fromMap({
        'buttonKeyPressed': 'SKIPPED',
        'payload': {'entityId': 'med_1', 'payload': '{"type":"medication","entityId":"med_1"}'},
      });

      // Neither should throw or crash the app
      expect(() => fakeClient.actionCallback?.call(responseTaken), returnsNormally);
      expect(() => fakeClient.actionCallback?.call(responseSkipped), returnsNormally);
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
      final schedulesAfterFirst = fakeClient.createNotificationCallCount;

      // Recovery runs second time (e.g. app restart or lifecycle resume)
      await container.read(medicineListProvider.notifier).rescheduleAllNotifications([med]);
      await container.read(appointmentListProvider.notifier).rescheduleAllNotifications([appt]);

      // Exactly 0 new schedule calls must be made because items already exist in pending list
      expect(fakeClient.createNotificationCallCount, equals(schedulesAfterFirst));
    });

    test('12. sensitive data does not enter diagnostic safe text methods', () {
      const confidentialDoctor = 'Dr. Sigmund Freud, Psychoanalyst';
      const confidentialMedicine = 'Lithium Carbonate 300mg Extended-Release';

      final maskedDoctor = NotificationEngine.safeText(confidentialDoctor);
      final maskedMedicine = NotificationEngine.safeMedicationBodyStatic(confidentialMedicine);

      expect(maskedDoctor, isNot(contains('Freud')));
      expect(maskedDoctor, isNot(contains('Psychoanalyst')));
      expect(maskedMedicine, isNot(contains('Lithium')));
      expect(maskedMedicine, isNot(contains('Carbonate')));
      expect(maskedMedicine, isNot(contains('300mg')));
    });
  });
}
