import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/repository_providers.dart';
import '../../domain/entities/medicine.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../core/l10n/translations.dart';
import '../../domain/usecases/base_usecase.dart';
import '../../domain/usecases/medicines/get_medicines_usecase.dart';
import '../../domain/usecases/medicines/add_medicine_usecase.dart';
import 'locale_provider.dart';
import 'daily_mission_providers.dart';
import 'season_providers.dart';
import '../../core/di/service_providers.dart';
import '../../data/services/notification_service.dart';
import '../../core/types/runtime_types.dart';
import '../../data/services/analytics_service.dart';
import 'package:flutter/foundation.dart';


// REPOSITORY PROVIDER REMOVED - Using centralized repository_providers.dart

final getMedicinesUseCaseProvider = Provider<GetMedicinesUseCase>((ref) {
  return GetMedicinesUseCase(ref.read(medicineRepositoryProvider));
});

final addMedicineUseCaseProvider = Provider<AddMedicineUseCase>((ref) {
  return AddMedicineUseCase(ref.read(medicineRepositoryProvider));
});

final medicineListProvider =
    AsyncNotifierProvider<MedicineListNotifier, List<Medicine>>(
  MedicineListNotifier.new,
);

class MedicineListNotifier extends AsyncNotifier<List<Medicine>> {
  @override
  Future<List<Medicine>> build() async {
    final useCase = ref.read(getMedicinesUseCaseProvider);
    final result = await useCase.call(NoParams());
    return result.fold((l) => throw l, (r) => r);
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(() {
      final useCase = ref.read(getMedicinesUseCaseProvider);
      return useCase.call(NoParams()).then((value) => value.fold((l) => throw l, (r) => r));
    });
  }

  Future<void> addMedicine(Medicine medicine) async {
    final useCase = ref.read(addMedicineUseCaseProvider);
    
    // ⚡ OPTIMISTIC UPDATE
    if (state.hasValue) {
      final currentList = state.value!;
      state = AsyncData([medicine, ...currentList]);
    }

    final result = await useCase.call(medicine);
    
    if (result.isLeft) {
      await refresh();
      result.fold((l) => throw l, (_) {});
      return;
    }
    
    // Track mission & XP
    ref.read(dailyMissionProvider.notifier).track("med_daily");
    ref.read(seasonProvider.notifier).addXP(15);
    AnalyticsService.log(AnalyticsService.medicineAdded);

    await _scheduleNotifications(medicine);
  }

  Future<void> markAsTaken(String id) async {
    final repo = ref.read(medicineRepositoryProvider);
    if (state.hasValue) {
      final currentList = state.value!;
      state = AsyncData(currentList.map((m) => m.id == id ? m.copyWith(isTaken: true) : m).toList());
    }
    // Update DB logic here if repository supports it
  }

  Future<void> markAsSkipped(String id) async {
    // Similar logic for skipping
    if (kDebugMode) print("Medicine $id marked as skipped");
  }

  Future<void> _scheduleNotifications(Medicine medicine) async {
    final notifier = ref.read(notificationServiceProvider);
    final permissionState = await notifier.requestPermissions(requestExactAlarm: true);
    if (permissionState != NotificationPermissionState.granted) {
      AnalyticsService.log(AnalyticsService.medicineReminderPermissionDenied);
      return;
    }

    final locale = ref.read(localeProvider);
    final trans = Translations.data[locale.languageCode] ?? Translations.data['en']!;
    final title = trans['medication_reminder'] ?? 'Medicine Time';

    for (int t = 0; t < medicine.reminderTimes.length; t++) {
      final timeParts = medicine.reminderTimes[t].split(':');
      if (timeParts.length != 2) continue;
      
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      final now = DateTime.now();

      if (medicine.frequency == 'daily') {
        var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
        if (scheduledDate.isBefore(now)) {
          scheduledDate = scheduledDate.add(const Duration(days: 1));
        }

        await NotificationService.scheduleMedication(
          id: "${medicine.id}_$t",
          medicineName: medicine.name,
          date: scheduledDate,
        );
      } else if (medicine.frequency == 'weekly' && medicine.daysOfWeek != null) {
        for (final day in medicine.daysOfWeek!) {
          // day is 1 (Mon) to 7 (Sun)
          // DateTime.monday is 1
          var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
          
          while (scheduledDate.weekday != day) {
            scheduledDate = scheduledDate.add(const Duration(days: 1));
          }
          
          if (scheduledDate.isBefore(now)) {
            scheduledDate = scheduledDate.add(const Duration(days: 7));
          }

          await notifier.scheduleMedicineReminder(
            id: NotificationService.getStableId(medicine.id, (day * 100) + t),
            title: title,
            body: notifier.safeMedicationBody(medicine.name),
            scheduledDate: scheduledDate,
            matchComponents: DateTimeComponents.dayOfWeekAndTime,
          );
        }
      } else if (medicine.frequency == 'custom' && medicine.interval != null) {
        // For custom interval, we schedule the next 10 occurrences
        // Since zonedSchedule doesn't support "every X days" repeating
        var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
        if (scheduledDate.isBefore(now)) {
          scheduledDate = scheduledDate.add(Duration(days: medicine.interval!));
        }

        for (int i = 0; i < 10; i++) {
          await NotificationService.scheduleMedication(
            id: "${medicine.id}_${i}_$t",
            medicineName: medicine.name,
            date: scheduledDate,
          );
          scheduledDate = scheduledDate.add(Duration(days: medicine.interval!));
        }
      }
    }
  }


  Future<void> updateMedicine(Medicine medicine) async {
    final repo = ref.read(medicineRepositoryProvider);
    
    // ⚡ OPTIMISTIC UPDATE
    if (state.hasValue) {
      final currentList = state.value!;
      state = AsyncData(currentList.map((m) => m.id == medicine.id ? medicine : m).toList());
    }

    try {
      final oldMedicine = (state.value ?? []).firstWhere((m) => m.id == medicine.id);
      await _cancelNotifications(oldMedicine);

      await repo.update(medicine);
      await _scheduleNotifications(medicine);
    } catch (e) {
      await refresh();
      rethrow;
    }
  }

  Future<void> deleteMedicine(String id) async {
    final repo = ref.read(medicineRepositoryProvider);
    
    // ⚡ OPTIMISTIC UPDATE
    if (state.hasValue) {
      final currentList = state.value!;
      final medicineToDelete = currentList.firstWhere((m) => m.id == id);
      await _cancelNotifications(medicineToDelete);
      state = AsyncData(currentList.where((m) => m.id != id).toList());
    }

    try {
      await repo.delete(id);
    } catch (e) {
      await refresh();
      rethrow;
    }
  }

  Future<void> _cancelNotifications(Medicine medicine) async {
    final notifier = ref.read(notificationServiceProvider);
    for (int t = 0; t < medicine.reminderTimes.length; t++) {
      // Cancel Daily
      await notifier.cancelNotification(NotificationService.getStableId(medicine.id, t));
      
      // Cancel Weekly (Days 1-7)
      for (int day = 1; day <= 7; day++) {
        await notifier.cancelNotification(NotificationService.getStableId(medicine.id, (day * 100) + t));
      }
      
      // Cancel Custom (Up to 10 instances)
      for (int i = 0; i < 10; i++) {
        await notifier.cancelNotification(NotificationService.getStableId(medicine.id, (i * 1000) + t));
      }
    }
  }
}
