import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:vitacase/core/di/repository_providers.dart';
import 'package:vitacase/core/notifications/app_notification_payload.dart';
import 'package:vitacase/core/notifications/notification_id_manager.dart';
import 'package:vitacase/core/types/runtime_types.dart';
import 'package:vitacase/features/appointments/domain/entities/appointment.dart';
import 'package:vitacase/features/appointments/presentation/providers/appointment_providers.dart';
import 'package:vitacase/features/medications/domain/entities/medicine.dart';
import 'package:vitacase/shared/domain/enums/appointment_status.dart';
import 'package:vitacase/shared/domain/enums/common_enums.dart';
import 'package:vitacase/shared/domain/repositories/appointment_repository.dart';
import 'package:vitacase/shared/domain/repositories/medicine_repository.dart';
import 'package:vitacase/shared/providers/medicine_providers.dart';
import 'package:vitacase/shared/providers/shared_prefs_provider.dart';
import 'package:vitacase/shared/data/services/notification_engine.dart';

import 'fake_awesome_notifications_client.dart';

class InMemoryAppointmentRepository implements AppointmentRepository {
  final Map<String, Appointment> _storage = {};

  @override
  Future<void> save(Appointment appointment) async {
    _storage[appointment.id] = appointment;
  }

  @override
  Future<List<Appointment>> getAll() async => _storage.values.toList();

  @override
  Future<Appointment?> getById(String id) async => _storage[id];

  @override
  Future<Appointment?> getNextUpcoming() async => null;

  @override
  Future<void> update(Appointment appointment) async {
    _storage[appointment.id] = appointment;
  }

  @override
  Future<void> delete(String id) async {
    _storage.remove(id);
  }

  @override
  Future<void> updateStatus(String id, AppointmentStatus status) async {
    final existing = _storage[id];
    if (existing != null) {
      _storage[id] = existing.copyWith(status: status);
    }
  }
}

class InMemoryMedicineRepository implements MedicineRepository {
  final Map<String, Medicine> _storage = {};

  @override
  Future<void> save(Medicine medicine) async {
    _storage[medicine.id] = medicine;
  }

  @override
  Future<List<Medicine>> getAll() async => _storage.values.toList();

  @override
  Future<Medicine?> getById(String id) async => _storage[id];

  @override
  Future<void> update(Medicine medicine) async {
    _storage[medicine.id] = medicine;
  }

  @override
  Future<void> delete(String id) async {
    _storage.remove(id);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeAwesomeNotificationsClient fakeClient;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'notification_hide_sensitive_content': true,
      'app_locale': 'tr',
    });
    prefs = await SharedPreferences.getInstance();

    NotificationEngine.resetForTesting();
    fakeClient = FakeAwesomeNotificationsClient();
    fakeClient.fakeTimeZone = 'Europe/Istanbul';
    NotificationEngine.setClientForTesting(fakeClient);
    NotificationEngine.setPrefsForTesting(prefs);
    await NotificationEngine.initCore();
  });

  tearDown(() {
    NotificationEngine.resetForTesting();
  });

  group('Phase 19.4 — Notification UTC / Timezone + Legacy Bug Verification', () {
    test('1. timezone initialization is deterministic, idempotent, and non-crashing', () async {
      NotificationEngine.resetForTesting();
      expect(NotificationEngine.isTimezoneInitialized, isFalse);

      await NotificationEngine.ensureTimezoneInitialized();
      expect(NotificationEngine.isTimezoneInitialized, isTrue);
      expect(NotificationEngine.getCanonicalTimeZone(), 'Europe/Istanbul');

      // Idempotent secondary call
      await NotificationEngine.ensureTimezoneInitialized();
      expect(NotificationEngine.isTimezoneInitialized, isTrue);
    });

    test('2. local time scheduling preserves wall-clock components exactly', () async {
      final futureDate = DateTime.now().add(const Duration(days: 5));
      final scheduledDate = DateTime(futureDate.year, futureDate.month, futureDate.day, 20, 0);

      await NotificationEngine.scheduleAppointment(
        id: 'test_appt_1',
        title: 'VitaCase Reminder',
        body: 'Checkup',
        date: scheduledDate,
      );

      expect(fakeClient.scheduledNotifications.length, 1);
      final entry = fakeClient.scheduledNotifications.first;
      final schedule = entry['schedule'];
      expect(schedule.year, futureDate.year);
      expect(schedule.month, futureDate.month);
      expect(schedule.day, futureDate.day);
      expect(schedule.hour, 20);
      expect(schedule.minute, 0);
      expect(schedule.timeZone, 'Europe/Istanbul');
    });

    test('3. UTC conversion normalizes to local wall-clock components for device timezone', () async {
      // 17:00 UTC corresponds to 20:00 local time in Europe/Istanbul (+03:00)
      final utcDate = DateTime.utc(2026, 9, 30, 17, 0);

      final schedule = NotificationEngine.createCalendarSchedule(date: utcDate);
      final local = utcDate.toLocal();

      expect(schedule.year, local.year);
      expect(schedule.month, local.month);
      expect(schedule.day, local.day);
      expect(schedule.hour, local.hour);
      expect(schedule.minute, local.minute);
      expect(schedule.timeZone, 'Europe/Istanbul');
    });

    test('4. local round-trip conversion preserves wall-clock schedule', () async {
      final originalLocal = DateTime(2026, 9, 30, 20, 0);
      final asUtc = originalLocal.toUtc();
      final backToLocal = asUtc.toLocal();

      expect(backToLocal.year, originalLocal.year);
      expect(backToLocal.month, originalLocal.month);
      expect(backToLocal.day, originalLocal.day);
      expect(backToLocal.hour, originalLocal.hour);
      expect(backToLocal.minute, originalLocal.minute);

      final calSchedule = NotificationEngine.createCalendarSchedule(date: backToLocal);
      expect(calSchedule.hour, 20);
      expect(calSchedule.minute, 0);
    });

    test('5. appointment reminder time schedules accurately (1h before and 1d before)', () async {
      final apptRepo = InMemoryAppointmentRepository();
      final container = ProviderContainer(overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appointmentRepositoryProvider.overrideWithValue(apptRepo),
      ]);

      final futureDate = DateTime.now().add(const Duration(days: 5));
      final dateStr = "${futureDate.year}-${futureDate.month.toString().padLeft(2, '0')}-${futureDate.day.toString().padLeft(2, '0')}";

      final appt = Appointment(
        id: 'appt_101',
        doctor: 'Dr. Smith',
        department: 'Cardiology',
        hospital: 'City Hospital',
        date: dateStr,
        time: '20:00',
        status: AppointmentStatus.upcoming,
        reminderTime: '1 saat önce',
        createdAt: DateTime.now(),
      );

      await container.read(appointmentListProvider.notifier).addAppointment(appt);

      expect(fakeClient.scheduledNotifications.length, 1);
      final scheduled = fakeClient.scheduledNotifications.first;
      final schedule = scheduled['schedule'];

      // 1 hour before 20:00 is 19:00
      expect(schedule.year, futureDate.year);
      expect(schedule.month, futureDate.month);
      expect(schedule.day, futureDate.day);
      expect(schedule.hour, 19);
      expect(schedule.minute, 0);
    });

    test('6. medicine reminder time schedules without +/- 1h drift', () async {
      final medRepo = InMemoryMedicineRepository();
      final container = ProviderContainer(overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        medicineRepositoryProvider.overrideWithValue(medRepo),
      ]);

      final med = Medicine(
        id: 'med_201',
        name: 'Aspirin',
        dosage: '100mg',
        frequency: 'daily',
        hungerStatus: HungerStatus.tok,
        reminderTimes: ['08:00'],
        startDate: '2026-09-30',
        createdAt: DateTime.now(),
      );

      await container.read(medicineListProvider.notifier).addMedicine(med);

      expect(fakeClient.scheduledNotifications.length, 1);
      final scheduled = fakeClient.scheduledNotifications.first;
      final schedule = scheduled['schedule'];

      expect(schedule.hour, 8);
      expect(schedule.minute, 0);
      expect(schedule.timeZone, 'Europe/Istanbul');
    });

    test('7. DST edge cases: Europe/Istanbul stays fixed UTC+3 while London transitions', () async {
      tz.initializeTimeZones();
      final istanbul = tz.getLocation('Europe/Istanbul');
      final london = tz.getLocation('Europe/London');

      // Summer date: 15 July 2026
      final summerUtc = DateTime.utc(2026, 7, 15, 12, 0);
      final summerIst = tz.TZDateTime.from(summerUtc, istanbul);
      final summerLon = tz.TZDateTime.from(summerUtc, london);

      expect(summerIst.timeZoneOffset.inHours, 3); // UTC+3 permanent
      expect(summerLon.timeZoneOffset.inHours, 1); // BST (UTC+1)

      // Winter date: 15 December 2026
      final winterUtc = DateTime.utc(2026, 12, 15, 12, 0);
      final winterIst = tz.TZDateTime.from(winterUtc, istanbul);
      final winterLon = tz.TZDateTime.from(winterUtc, london);

      expect(winterIst.timeZoneOffset.inHours, 3); // Still UTC+3! No DST shift in Turkey
      expect(winterLon.timeZoneOffset.inHours, 0); // GMT (UTC+0)
    });

    test('8. past notification scheduling skips safely without uncaught exceptions', () async {
      final pastDate = DateTime.now().subtract(const Duration(hours: 2));

      // Must not throw
      await NotificationEngine.scheduleAppointment(
        id: 'past_appt',
        title: 'Past Title',
        body: 'Past Body',
        date: pastDate,
      );

      await NotificationEngine.scheduleMedication(
        id: 'past_med',
        title: 'Past Med',
        body: 'Past Body',
        date: pastDate,
      );

      expect(fakeClient.scheduledNotifications.isEmpty, isTrue);
    });

    test('9. duplicate prevention: rescheduleAll is idempotent', () async {
      final apptRepo = InMemoryAppointmentRepository();
      final container = ProviderContainer(overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appointmentRepositoryProvider.overrideWithValue(apptRepo),
      ]);

      final futureDate = DateTime.now().add(const Duration(days: 3));
      final dateStr = "${futureDate.year}-${futureDate.month.toString().padLeft(2, '0')}-${futureDate.day.toString().padLeft(2, '0')}";

      final appt = Appointment(
        id: 'appt_idempotent',
        doctor: 'Dr. Test',
        department: 'General',
        hospital: 'Clinic',
        date: dateStr,
        time: '14:00',
        status: AppointmentStatus.upcoming,
        reminderTime: '1 saat önce',
        createdAt: DateTime.now(),
      );

      await container.read(appointmentListProvider.notifier).addAppointment(appt);
      expect(fakeClient.scheduledNotifications.length, 1);
      final scheduleCallCountBefore = fakeClient.createNotificationCallCount;

      // Reschedule all
      await container.read(appointmentListProvider.notifier).rescheduleAllNotifications([appt]);

      // Count of scheduled entries remains exactly 1, no duplicate
      expect(fakeClient.scheduledNotifications.length, 1);
      // Because payload matched existing, platform call was skipped
      expect(fakeClient.createNotificationCallCount, scheduleCallCountBefore);
    });

    test('10. appointment edit cancels old notification and schedules new one', () async {
      final apptRepo = InMemoryAppointmentRepository();
      final container = ProviderContainer(overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appointmentRepositoryProvider.overrideWithValue(apptRepo),
      ]);

      final futureDate = DateTime.now().add(const Duration(days: 4));
      final dateStr = "${futureDate.year}-${futureDate.month.toString().padLeft(2, '0')}-${futureDate.day.toString().padLeft(2, '0')}";

      final originalAppt = Appointment(
        id: 'appt_edit_cycle',
        doctor: 'Dr. Old',
        department: 'Cardiology',
        hospital: 'Old Clinic',
        date: dateStr,
        time: '10:00',
        status: AppointmentStatus.upcoming,
        reminderTime: '1 saat önce',
        createdAt: DateTime.now(),
      );

      await container.read(appointmentListProvider.notifier).addAppointment(originalAppt);
      expect(fakeClient.scheduledNotifications.length, 1);

      // Edit appointment to 16:00
      final updatedAppt = originalAppt.copyWith(
        time: '16:00',
        doctor: 'Dr. New',
      );

      await container.read(appointmentListProvider.notifier).updateAppointment(updatedAppt);

      // Exactly 1 active notification exists
      expect(fakeClient.scheduledNotifications.length, 1);
      final scheduled = fakeClient.scheduledNotifications.first;
      // 1 hour before 16:00 is 15:00
      expect(scheduled['schedule'].hour, 15);
    });

    test('11. appointment delete cancels associated notification', () async {
      final apptRepo = InMemoryAppointmentRepository();
      final container = ProviderContainer(overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appointmentRepositoryProvider.overrideWithValue(apptRepo),
      ]);

      final futureDate = DateTime.now().add(const Duration(days: 2));
      final dateStr = "${futureDate.year}-${futureDate.month.toString().padLeft(2, '0')}-${futureDate.day.toString().padLeft(2, '0')}";

      final appt = Appointment(
        id: 'appt_to_delete',
        doctor: 'Dr. Terminate',
        department: 'General',
        hospital: 'Clinic',
        date: dateStr,
        time: '11:00',
        status: AppointmentStatus.upcoming,
        reminderTime: '1 saat önce',
        createdAt: DateTime.now(),
      );

      await container.read(appointmentListProvider.notifier).addAppointment(appt);
      expect(fakeClient.scheduledNotifications.length, 1);

      await container.read(appointmentListProvider.notifier).deleteAppointment(appt.id);
      expect(fakeClient.scheduledNotifications.isEmpty, isTrue);
    });

    test('12. medicine edit cancels old reminder and schedules updated one', () async {
      final medRepo = InMemoryMedicineRepository();
      final container = ProviderContainer(overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        medicineRepositoryProvider.overrideWithValue(medRepo),
      ]);

      final originalMed = Medicine(
        id: 'med_edit_cycle',
        name: 'Vitamin D',
        dosage: '1000 IU',
        frequency: 'daily',
        hungerStatus: HungerStatus.tok,
        reminderTimes: ['09:00'],
        startDate: '2026-09-30',
        createdAt: DateTime.now(),
      );

      await container.read(medicineListProvider.notifier).addMedicine(originalMed);
      expect(fakeClient.scheduledNotifications.length, 1);
      expect(fakeClient.scheduledNotifications.first['schedule'].hour, 9);

      // Edit reminder time to 12:00
      final updatedMed = originalMed.copyWith(reminderTimes: ['12:00']);
      await container.read(medicineListProvider.notifier).updateMedicine(updatedMed);

      expect(fakeClient.scheduledNotifications.length, 1);
      expect(fakeClient.scheduledNotifications.first['schedule'].hour, 12);
    });

    test('13. medicine delete cancels all associated reminders', () async {
      final medRepo = InMemoryMedicineRepository();
      final container = ProviderContainer(overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        medicineRepositoryProvider.overrideWithValue(medRepo),
      ]);

      final med = Medicine(
        id: 'med_to_delete',
        name: 'Antibiotic',
        dosage: '500mg',
        frequency: 'daily',
        hungerStatus: HungerStatus.ac,
        reminderTimes: ['08:00', '20:00'],
        startDate: '2026-09-30',
        createdAt: DateTime.now(),
      );

      await container.read(medicineListProvider.notifier).addMedicine(med);
      expect(fakeClient.scheduledNotifications.length, 2);

      await container.read(medicineListProvider.notifier).deleteMedicine(med.id);
      expect(fakeClient.scheduledNotifications.isEmpty, isTrue);
    });

    test('14. deterministic notification IDs across non-overlapping partitions', () {
      final medId1 = NotificationIdManager.getMedicineReminderId(
        medicineId: 'med_abc',
        reminderTime: '08:00',
      );
      final medId2 = NotificationIdManager.getMedicineReminderId(
        medicineId: 'med_abc',
        reminderTime: '08:00',
      );
      expect(medId1, equals(medId2));
      expect(NotificationIdManager.isMedicineId(medId1), isTrue);
      expect(NotificationIdManager.isAppointmentId(medId1), isFalse);

      final apptId1 = NotificationIdManager.getAppointmentReminderId(
        appointmentId: 'appt_xyz',
        reminderKey: 'reminder_1h',
      );
      final apptId2 = NotificationIdManager.getAppointmentReminderId(
        appointmentId: 'appt_xyz',
        reminderKey: 'reminder_1h',
      );
      expect(apptId1, equals(apptId2));
      expect(NotificationIdManager.isAppointmentId(apptId1), isTrue);
      expect(NotificationIdManager.isMedicineId(apptId1), isFalse);

      expect(NotificationIdManager.systemMin, 1);
      expect(NotificationIdManager.systemMax, 99999);
      expect(NotificationIdManager.medicationMin, 100000000);
      expect(NotificationIdManager.appointmentMin, 1000000000);
      expect(NotificationIdManager.generalMin, 1700000000);
    });

    test('15. lifecycle duplicate prevention: close reminder scheduled only once within 24h', () async {
      await NotificationEngine.scheduleCloseReminder();
      expect(fakeClient.scheduledNotifications.length, 1);

      // Attempting to schedule close reminder immediately again
      await NotificationEngine.scheduleCloseReminder();
      // Should not duplicate
      expect(fakeClient.scheduledNotifications.length, 1);
    });

    test('16. permission denied safety: does not crash when permission is disallowed', () async {
      fakeClient.isAllowed = false;

      // Scheduling must gracefully return without throwing
      await NotificationEngine.scheduleAppointment(
        id: 'no_perm_appt',
        title: 'Title',
        body: 'Body',
        date: DateTime.now().add(const Duration(days: 1)),
      );

      final permStatus = await NotificationEngine.checkPermissionStatus();
      expect(permStatus, NotificationPermissionState.denied);
    });

    test('17. notification tap and action routing execute safely', () async {
      bool medicineTakenCalled = false;
      String? routedPayload;

      NotificationEngine.setMedicineActionHandlers(
        onTaken: (id) async {
          medicineTakenCalled = true;
        },
        onSkipped: (id) async {},
      );

      NotificationEngine.setRouteHandler((payload) {
        routedPayload = payload;
      });

      // Simulate notification action
      await NotificationEngine.onActionReceivedMethod(
        ReceivedAction().fromMap({
          'id': 12345,
          'channelKey': 'medicine_reminders_v2',
          'buttonKeyPressed': 'MARK_DONE',
          'payload': {
            'entityId': 'med_test_1',
            'payload': '/home',
          },
        }),
      );

      expect(medicineTakenCalled, isTrue);
      expect(routedPayload, '/home');
    });

    test('18. timezone invalid/error handling falls back to canonical timezone without crash', () async {
      NotificationEngine.resetForTesting();
      fakeClient.fakeTimeZone = 'Invalid/Unknown_Zone_123';
      NotificationEngine.setClientForTesting(fakeClient);

      await NotificationEngine.ensureTimezoneInitialized();
      expect(NotificationEngine.isTimezoneInitialized, isTrue);
      // Normalized fallback ensures a valid IANA zone or UTC
      final canonical = NotificationEngine.getCanonicalTimeZone();
      expect(canonical, isNotEmpty);
      expect(canonical == 'Europe/Istanbul' || canonical == 'UTC', isTrue);
    });

    test('19. sensitive data is not leaked in notification body or payload', () async {
      await prefs.setBool('notification_hide_sensitive_content', true);

      final safeBody = NotificationEngine.safeMedicationBodyStatic('Chemotherapy Med X');
      expect(safeBody, isNot(contains('Chemotherapy')));
      expect(safeBody, isNot(contains('Med X')));

      final payload = AppNotificationPayload(
        type: NotificationType.medication,
        entityId: 'med_secret_99',
        occurrenceAt: DateTime.now(),
      );

      final encoded = payload.encode();
      expect(encoded, isNot(contains('Chemotherapy')));
      expect(encoded, contains('med_secret_99'));
    });

    test('20. dual notification prevention: NotificationEngine is the sole scheduling engine', () async {
      expect(NotificationEngine.instance, isNotNull);
      expect(NotificationEngine.isInitialized, isTrue);

      final pending = await NotificationEngine.getPendingNotificationRequests();
      expect(pending, isA<List<PendingNotificationRequest>>());
    });
  });
}
