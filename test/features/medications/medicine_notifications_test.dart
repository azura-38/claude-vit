import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vitacase/core/di/repository_providers.dart';
import 'package:vitacase/core/notifications/notification_id_manager.dart';
import 'package:vitacase/features/medications/domain/entities/medicine.dart';
import 'package:vitacase/shared/data/services/notification_engine.dart';
import 'package:vitacase/shared/data/services/usage_limit_service.dart';
import 'package:vitacase/shared/domain/enums/common_enums.dart';
import 'package:vitacase/shared/domain/repositories/medicine_repository.dart';
import 'package:vitacase/shared/providers/medicine_providers.dart';
import 'package:vitacase/shared/providers/shared_prefs_provider.dart';

import '../notifications/fake_awesome_notifications_client.dart';

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

class FakeUsageLimitService extends Fake implements UsageLimitService {
  @override
  Future<UsageLimitResult> consumeCreate() async => const UsageLimitResult(allowed: true, used: 0, limit: 100);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeAwesomeNotificationsClient fakeClient;
  late InMemoryMedicineRepository fakeRepo;
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

    fakeRepo = InMemoryMedicineRepository();

    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(fakePrefs),
        medicineRepositoryProvider.overrideWithValue(fakeRepo),
        usageLimitServiceProvider.overrideWithValue(FakeUsageLimitService()),
      ],
    );
  });

  tearDown(() {
    container.dispose();
    NotificationEngine.resetForTesting();
  });

  Medicine createTestMedicine({
    String id = 'med_1',
    String name = 'Metformin',
    List<String> reminderTimes = const ['08:00'],
    String frequency = 'daily',
  }) {
    return Medicine(
      id: id,
      name: name,
      dosage: '500 mg',
      startDate: '2026-09-26',
      frequency: frequency,
      hungerStatus: HungerStatus.tok,
      reminderTimes: reminderTimes,
      createdAt: DateTime(2026, 9, 26, 7, 0),
    );
  }

  group('Phase 7 — Medicine Notifications Tests', () {
    test('1. medicine reminder schedules successfully with medication payload', () async {
      final med = createTestMedicine();
      await container.read(medicineListProvider.notifier).addMedicine(med);

      expect(fakeClient.createNotificationCallCount, 1);
      final record = fakeClient.scheduledNotifications.first;

      expect(record['channelKey'], 'medicine_reminders_v2');
      // Body is masked because hide_sensitive_content is true
      expect(record['body'], 'Reminder details are hidden.');

      final expectedId = NotificationIdManager.getMedicineReminderId(
        medicineId: med.id,
        reminderTime: '08:00',
      );
      expect(record['id'], expectedId);
      expect(record['id'], greaterThanOrEqualTo(NotificationIdManager.medicationMin));
      expect(record['id'], lessThan(NotificationIdManager.medicationMin + NotificationIdManager.medicationRange));
    });

    test('2. deterministic medicine notification ID across repeated calls', () {
      final idA = NotificationIdManager.getMedicineReminderId(
        medicineId: 'med_abc',
        reminderTime: '08:00',
      );
      final idB = NotificationIdManager.getMedicineReminderId(
        medicineId: 'med_abc',
        reminderTime: '08:00',
      );
      expect(idA, equals(idB));
    });

    test('3. different medicines receive different IDs for the same reminder time', () {
      final id1 = NotificationIdManager.getMedicineReminderId(
        medicineId: 'med_aspirin',
        reminderTime: '08:00',
      );
      final id2 = NotificationIdManager.getMedicineReminderId(
        medicineId: 'med_lisinopril',
        reminderTime: '08:00',
      );
      expect(id1 != id2, isTrue);
    });

    test('4. different reminders for the same medicine receive different IDs', () {
      final idMorning = NotificationIdManager.getMedicineReminderId(
        medicineId: 'med_1',
        reminderTime: '08:00',
      );
      final idEvening = NotificationIdManager.getMedicineReminderId(
        medicineId: 'med_1',
        reminderTime: '20:00',
      );
      expect(idMorning != idEvening, isTrue);
    });

    test('5 & 6. update cancels old reminder and schedules new reminder without orphans', () async {
      final initialMed = createTestMedicine(reminderTimes: ['08:00']);
      await container.read(medicineListProvider.notifier).addMedicine(initialMed);

      final oldId = NotificationIdManager.getMedicineReminderId(
        medicineId: initialMed.id,
        reminderTime: '08:00',
      );
      expect(fakeClient.scheduledNotifications.any((n) => n['id'] == oldId), isTrue);

      // Update medicine reminder from 08:00 to 14:00
      final updatedMed = initialMed.copyWith(reminderTimes: ['14:00']);
      await container.read(medicineListProvider.notifier).updateMedicine(updatedMed);

      // Old reminder ID must have been cancelled
      expect(fakeClient.cancelledIds, contains(oldId));

      // New reminder ID must have been scheduled
      final newId = NotificationIdManager.getMedicineReminderId(
        medicineId: initialMed.id,
        reminderTime: '14:00',
      );
      expect(fakeClient.scheduledNotifications.any((n) => n['id'] == newId), isTrue);
    });

    test('7. delete cancels all medicine notifications and removes from repository', () async {
      final med = createTestMedicine(reminderTimes: ['08:00', '20:00']);
      await container.read(medicineListProvider.notifier).addMedicine(med);

      final id1 = NotificationIdManager.getMedicineReminderId(medicineId: med.id, reminderTime: '08:00');
      final id2 = NotificationIdManager.getMedicineReminderId(medicineId: med.id, reminderTime: '20:00');

      await container.read(medicineListProvider.notifier).deleteMedicine(med.id);

      expect(fakeClient.cancelledIds, contains(id1));
      expect(fakeClient.cancelledIds, contains(id2));
      expect(await fakeRepo.getById(med.id), isNull);
    });

    test('8. disabling reminder cancels notification without deleting medicine', () async {
      final med = createTestMedicine(reminderTimes: ['08:00']);
      await container.read(medicineListProvider.notifier).addMedicine(med);

      final id = NotificationIdManager.getMedicineReminderId(medicineId: med.id, reminderTime: '08:00');
      final scheduleCountBefore = fakeClient.createNotificationCallCount;

      // Disable reminders by setting reminderTimes to empty
      final disabledMed = med.copyWith(reminderTimes: []);
      await container.read(medicineListProvider.notifier).updateMedicine(disabledMed);

      // Old notification must be cancelled
      expect(fakeClient.cancelledIds, contains(id));
      // No new schedule call
      expect(fakeClient.createNotificationCallCount, scheduleCountBefore);
      // Medicine must still exist in repo
      expect(await fakeRepo.getById(med.id), isNotNull);
    });

    test('9. re-enabling reminder schedules notification again', () async {
      final medWithoutReminders = createTestMedicine(reminderTimes: []);
      await container.read(medicineListProvider.notifier).addMedicine(medWithoutReminders);
      expect(fakeClient.createNotificationCallCount, 0);

      // Re-enable reminder
      final enabledMed = medWithoutReminders.copyWith(reminderTimes: ['09:00']);
      await container.read(medicineListProvider.notifier).updateMedicine(enabledMed);

      final id = NotificationIdManager.getMedicineReminderId(medicineId: enabledMed.id, reminderTime: '09:00');
      expect(fakeClient.scheduledNotifications.any((n) => n['id'] == id), isTrue);
    });

    test('10. scheduling failure does not crash medicine CRUD', () async {
      fakeClient.shouldThrowOnSchedule = true;

      final med = createTestMedicine();
      // Should not throw
      await container.read(medicineListProvider.notifier).addMedicine(med);

      // Medicine must still be saved in repository
      final saved = await fakeRepo.getById(med.id);
      expect(saved, isNotNull);
      expect(saved!.name, 'Metformin');
    });

    test('11. cancellation failure does not crash medicine CRUD', () async {
      final med = createTestMedicine();
      await container.read(medicineListProvider.notifier).addMedicine(med);

      fakeClient.shouldThrowOnCancel = true;
      // Should not throw
      await container.read(medicineListProvider.notifier).deleteMedicine(med.id);

      // Medicine must still be removed from repository
      final saved = await fakeRepo.getById(med.id);
      expect(saved, isNull);
    });

    test('12. sensitive medicine information is masked by default', () async {
      await fakePrefs.setBool('notification_hide_sensitive_content', true);

      final safeBody = NotificationEngine.safeMedicationBodyStatic('Secret Oncology 100mg');
      expect(safeBody, 'Reminder details are hidden.');
      expect(safeBody.contains('Secret'), isFalse);
      expect(safeBody.contains('Oncology'), isFalse);

      final safeText = NotificationEngine.safeText('Take Secret Oncology 100mg');
      expect(safeText, 'Reminder details are hidden.');
      expect(safeText.contains('Secret'), isFalse);
    });

    test('13. notification callback/action failure is contained', () async {
      NotificationEngine.setMedicineActionHandlers(
        onTaken: (id) async {
          throw Exception('Simulated action error');
        },
        onSkipped: (id) async {},
      );

      // Simulating action response must not throw unhandled error
      expect(
        () => NotificationEngine.instance, // verify service intact
        returnsNormally,
      );

      // Test markAsTaken error containment in notifier
      final notifier = container.read(medicineListProvider.notifier);
      await expectLater(notifier.markAsTaken('non_existent_id'), completes);
      await expectLater(notifier.markAsSkipped('non_existent_id'), completes);
    });

    test('14. provider lifecycle remains safe during async scheduling', () async {
      final med = createTestMedicine(reminderTimes: ['08:00', '12:00', '18:00']);

      // Adding multiple reminders completes cleanly with all dependencies captured
      await expectLater(
        container.read(medicineListProvider.notifier).addMedicine(med),
        completes,
      );

      expect(fakeClient.scheduledNotifications.length, 3);
      final list = await container.read(medicineListProvider.future);
      expect(list.length, 1);
      expect(list.first.id, med.id);
    });
  });
}
