import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/repository_providers.dart';
import '../../features/medications/domain/entities/medicine.dart';
import '../domain/usecases/base_usecase.dart';
import '../domain/usecases/medicines/get_medicines_usecase.dart';
import '../domain/usecases/medicines/add_medicine_usecase.dart';
import 'daily_mission_providers.dart';
import 'season_providers.dart';
import '../../core/di/service_providers.dart';
import '../data/services/notification_engine.dart';
import '../../core/types/runtime_types.dart';
import '../../core/notifications/app_notification_payload.dart';
import '../data/services/analytics_service.dart';
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
      return useCase
          .call(NoParams())
          .then((value) => value.fold((l) => throw l, (r) => r));
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
    Medicine? updatedMedicine;

    if (state.hasValue) {
      final currentList = state.value!;
      final updatedList =
          currentList.map((m) {
            if (m.id != id) return m;
            updatedMedicine = m.copyWith(isTaken: true);
            return updatedMedicine!;
          }).toList();
      state = AsyncData(updatedList);
    }

    updatedMedicine ??= (await repo.getById(id))?.copyWith(isTaken: true);
    if (updatedMedicine != null) {
      await repo.update(updatedMedicine!);
    }
  }

  Future<void> markAsSkipped(String id) async {
    final repo = ref.read(medicineRepositoryProvider);
    Medicine? updatedMedicine;

    if (state.hasValue) {
      final currentList = state.value!;
      final updatedList =
          currentList.map((m) {
            if (m.id != id) return m;
            updatedMedicine = m.copyWith(isTaken: false);
            return updatedMedicine!;
          }).toList();
      state = AsyncData(updatedList);
    }

    updatedMedicine ??= (await repo.getById(id))?.copyWith(isTaken: false);
    if (updatedMedicine != null) {
      await repo.update(updatedMedicine!);
    }
    if (kDebugMode) print("Medicine $id marked as skipped");
  }

  Future<void> _scheduleNotifications(Medicine medicine) async {
    final notifier = ref.read(notificationServiceProvider);
    final permissionState = await notifier.requestPermissions(
      requestExactAlarm: true,
    );
    if (permissionState != NotificationPermissionState.granted) {
      AnalyticsService.log(AnalyticsService.medicineReminderPermissionDenied);
      return;
    }

    for (final date in _generatedDates(medicine)) {
      await NotificationEngine.scheduleMedicine(
        id: medicine.id,
        title: "💊 Medication Reminder",
        body: medicine.name,
        scheduleTime: date,
        payload: AppNotificationPayload(
          type: NotificationType.medication,
          entityId: medicine.id,
          occurrenceAt: date,
        ).encode(),
      );
    }
  }

  Future<void> rescheduleAllNotifications(List<Medicine> medicines) async {
    for (final medicine in medicines) {
      await _scheduleNotifications(medicine);
    }
  }

  List<DateTime> _generatedDates(Medicine medicine) {
    final now = DateTime.now();
    final dates = <DateTime>[];

    for (final reminderTime in medicine.reminderTimes) {
      final timeParts = reminderTime.split(':');
      if (timeParts.length != 2) continue;

      final hour = int.tryParse(timeParts[0]);
      final minute = int.tryParse(timeParts[1]);
      if (hour == null || minute == null) continue;

      if (medicine.frequency == 'weekly' && medicine.daysOfWeek != null) {
        for (final day in medicine.daysOfWeek!) {
          var scheduledDate = DateTime(
            now.year,
            now.month,
            now.day,
            hour,
            minute,
          );
          while (scheduledDate.weekday != day) {
            scheduledDate = scheduledDate.add(const Duration(days: 1));
          }
          if (!scheduledDate.isAfter(now)) {
            scheduledDate = scheduledDate.add(const Duration(days: 7));
          }
          dates.add(scheduledDate);
        }
      } else if (medicine.frequency == 'custom' && medicine.interval != null) {
        var scheduledDate = DateTime(
          now.year,
          now.month,
          now.day,
          hour,
          minute,
        );
        if (!scheduledDate.isAfter(now)) {
          scheduledDate = scheduledDate.add(Duration(days: medicine.interval!));
        }
        for (int i = 0; i < 10; i++) {
          dates.add(scheduledDate);
          scheduledDate = scheduledDate.add(Duration(days: medicine.interval!));
        }
      } else {
        var scheduledDate = DateTime(
          now.year,
          now.month,
          now.day,
          hour,
          minute,
        );
        if (!scheduledDate.isAfter(now)) {
          scheduledDate = scheduledDate.add(const Duration(days: 1));
        }
        dates.add(scheduledDate);
      }
    }

    return dates;
  }

  Future<void> updateMedicine(Medicine medicine) async {
    final repo = ref.read(medicineRepositoryProvider);

    Medicine? oldMedicine;
    // ⚡ OPTIMISTIC UPDATE
    if (state.hasValue) {
      final currentList = state.value!;
      oldMedicine = currentList.where((m) => m.id == medicine.id).firstOrNull;
      state = AsyncData(
        currentList.map((m) => m.id == medicine.id ? medicine : m).toList(),
      );
    }

    try {
      await repo.update(medicine);
      if (oldMedicine != null) {
        await _cancelNotifications(oldMedicine);
      }
      await _scheduleNotifications(medicine);
    } catch (e) {
      await refresh();
      rethrow;
    }
  }

  Future<void> deleteMedicine(String id) async {
    final repo = ref.read(medicineRepositoryProvider);

    Medicine? oldMedicine;
    // ⚡ OPTIMISTIC UPDATE
    if (state.hasValue) {
      final currentList = state.value!;
      oldMedicine = currentList.where((m) => m.id == id).firstOrNull;
      state = AsyncData(currentList.where((m) => m.id != id).toList());
    }

    try {
      await repo.delete(id);
      if (oldMedicine != null) {
        await _cancelNotifications(oldMedicine);
      }
    } catch (e) {
      await refresh();
      rethrow;
    }
  }

  Future<void> _cancelNotifications(Medicine medicine) async {
    for (final date in _generatedDates(medicine)) {
      await NotificationEngine.cancel(medicine.id, date);
    }
  }
}
