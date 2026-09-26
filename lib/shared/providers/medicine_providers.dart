import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/repository_providers.dart';
import '../../core/di/service_providers.dart';
import '../../core/notifications/app_notification_payload.dart';
import '../../core/notifications/notification_id_manager.dart';
import '../../core/types/runtime_types.dart';
import '../../features/gamification/presentation/providers/achievement_providers.dart';
import '../../features/medications/domain/entities/medicine.dart';
import '../data/services/analytics_service.dart';
import '../data/services/notification_service.dart';
import '../data/services/usage_limit_service.dart';
import '../domain/usecases/base_usecase.dart';
import '../domain/usecases/medicines/add_medicine_usecase.dart';
import '../domain/usecases/medicines/get_medicines_usecase.dart';
import 'daily_mission_providers.dart';
import 'season_providers.dart';

class _MedicineReminderScheduleItem {
  final int notificationId;
  final DateTime scheduledDate;

  const _MedicineReminderScheduleItem({
    required this.notificationId,
    required this.scheduledDate,
  });
}

final getMedicinesUseCaseProvider = Provider<GetMedicinesUseCase>((ref) {
  return GetMedicinesUseCase(ref.read(medicineRepositoryProvider));
});

final addMedicineUseCaseProvider = Provider<AddMedicineUseCase>((ref) {
  return AddMedicineUseCase(ref.read(medicineRepositoryProvider));
});

final medicineListProvider = AsyncNotifierProvider<MedicineListNotifier, List<Medicine>>(
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
    // Capture dependencies synchronously before awaiting
    final limitService = ref.read(usageLimitServiceProvider);
    final useCase = ref.read(addMedicineUseCaseProvider);
    final dailyMissionNotifier = ref.read(dailyMissionProvider.notifier);
    final seasonNotifier = ref.read(seasonProvider.notifier);

    final limit = await limitService.consumeCreate();
    if (!limit.allowed) {
      throw UsageLimitExceededException(limit.limit);
    }

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

    await dailyMissionNotifier.track('med_daily');
    await _trackMedicineAchievements();
    await seasonNotifier.addXP(15);
    AnalyticsService.log(AnalyticsService.medicineAdded);

    await _scheduleNotifications(medicine);
  }

  Future<void> _trackMedicineAchievements() async {
    final repo = ref.read(medicineRepositoryProvider);
    final count = state.valueOrNull?.length ?? (await repo.getAll()).length;
    final achievement = ref.read(achievementProvider.notifier);
    for (final id in const ['med_1', 'med_3', 'med_5', 'med_10', 'med_25', 'med_50']) {
      await achievement.track(id, setAbsolute: count);
    }
  }

  Future<void> markAsTaken(String id) async {
    try {
      final repo = ref.read(medicineRepositoryProvider);
      Medicine? updatedMedicine;

      if (state.hasValue) {
        final currentList = state.value!;
        final updatedList = currentList.map((m) {
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
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[MedicineListNotifier] Safe error in markAsTaken: $e');
      }
    }
  }

  Future<void> markAsSkipped(String id) async {
    try {
      final repo = ref.read(medicineRepositoryProvider);
      Medicine? updatedMedicine;

      if (state.hasValue) {
        final currentList = state.value!;
        final updatedList = currentList.map((m) {
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
      if (kDebugMode) {
        debugPrint('[MedicineListNotifier] Medicine marked as skipped');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[MedicineListNotifier] Safe error in markAsSkipped: $e');
      }
    }
  }

  Future<void> _scheduleNotifications(Medicine medicine) async {
    try {
      if (medicine.reminderTimes.isEmpty) return;

      final notifier = ref.read(notificationServiceProvider);
      final permissionState = await notifier.requestPermissions(requestExactAlarm: true);
      if (permissionState != NotificationPermissionState.granted) {
        AnalyticsService.log(AnalyticsService.medicineReminderPermissionDenied);
        return;
      }

      final items = _getReminderItems(medicine);
      for (final item in items) {
        await NotificationService.scheduleMedication(
          id: medicine.id,
          title: '💊 VitaCase Reminder',
          body: medicine.name,
          date: item.scheduledDate,
          explicitId: item.notificationId,
          payload: AppNotificationPayload(
            type: NotificationType.medication,
            entityId: medicine.id,
            occurrenceAt: item.scheduledDate,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[MedicineListNotifier] Safe error scheduling notifications: $e');
      }
    }
  }

  Future<void> rescheduleAllNotifications(List<Medicine> medicines) async {
    try {
      final notifier = ref.read(notificationServiceProvider);
      final permissionState = await notifier.requestPermissions(requestExactAlarm: true);
      if (permissionState != NotificationPermissionState.granted) {
        AnalyticsService.log(AnalyticsService.medicineReminderPermissionDenied);
        return;
      }

      final pending = await NotificationService.getPendingNotificationRequests();
      final pendingMap = {for (final p in pending) p.id: p};
      final activeIds = <int>{};

      for (final medicine in medicines) {
        if (medicine.reminderTimes.isEmpty) continue;
        final items = _getReminderItems(medicine);
        for (final item in items) {
          activeIds.add(item.notificationId);
          final existing = pendingMap[item.notificationId];
          final expectedPayload = AppNotificationPayload(
            type: NotificationType.medication,
            entityId: medicine.id,
            occurrenceAt: item.scheduledDate,
          ).encode();

          // Idempotency: if already scheduled with matching payload/time, skip redundant platform schedule call
          if (existing != null && existing.payload == expectedPayload) {
            continue;
          }

          await NotificationService.scheduleMedication(
            id: medicine.id,
            title: '💊 VitaCase Reminder',
            body: medicine.name,
            date: item.scheduledDate,
            explicitId: item.notificationId,
            payload: AppNotificationPayload(
              type: NotificationType.medication,
              entityId: medicine.id,
              occurrenceAt: item.scheduledDate,
            ),
          );
        }
      }

      // Stale cleanup: Clean up orphaned medicine notifications that are no longer active
      for (final p in pending) {
        if (NotificationIdManager.isMedicineId(p.id) && !activeIds.contains(p.id)) {
          await NotificationService.cancelById(p.id);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[MedicineListNotifier] Safe error in rescheduleAllNotifications: $e');
      }
    }
  }

  List<_MedicineReminderScheduleItem> _getReminderItems(Medicine medicine) {
    final now = DateTime.now();
    final items = <_MedicineReminderScheduleItem>[];

    for (final reminderTime in medicine.reminderTimes) {
      final parts = reminderTime.split(':');
      if (parts.length != 2) continue;

      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);
      if (hour == null || minute == null) continue;

      if (medicine.frequency == 'weekly' && medicine.daysOfWeek != null && medicine.daysOfWeek!.isNotEmpty) {
        for (final day in medicine.daysOfWeek!) {
          var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
          while (scheduledDate.weekday != day) {
            scheduledDate = scheduledDate.add(const Duration(days: 1));
          }
          if (!scheduledDate.isAfter(now)) {
            scheduledDate = scheduledDate.add(const Duration(days: 7));
          }
          final notifId = NotificationIdManager.getMedicineReminderId(
            medicineId: medicine.id,
            reminderTime: reminderTime,
            dayOfWeek: day,
          );
          items.add(_MedicineReminderScheduleItem(
            notificationId: notifId,
            scheduledDate: scheduledDate,
          ));
        }
      } else if (medicine.frequency == 'custom' && medicine.interval != null) {
        var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
        if (!scheduledDate.isAfter(now)) {
          scheduledDate = scheduledDate.add(Duration(days: medicine.interval!));
        }
        for (int i = 0; i < 10; i++) {
          final notifId = NotificationIdManager.getMedicineReminderId(
            medicineId: medicine.id,
            reminderTime: reminderTime,
            intervalIndex: i,
          );
          items.add(_MedicineReminderScheduleItem(
            notificationId: notifId,
            scheduledDate: scheduledDate,
          ));
          scheduledDate = scheduledDate.add(Duration(days: medicine.interval!));
        }
      } else {
        var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
        if (!scheduledDate.isAfter(now)) {
          scheduledDate = scheduledDate.add(const Duration(days: 1));
        }
        final notifId = NotificationIdManager.getMedicineReminderId(
          medicineId: medicine.id,
          reminderTime: reminderTime,
        );
        items.add(_MedicineReminderScheduleItem(
          notificationId: notifId,
          scheduledDate: scheduledDate,
        ));
      }
    }

    return items;
  }

  Future<void> updateMedicine(Medicine medicine) async {
    final repo = ref.read(medicineRepositoryProvider);

    Medicine? oldMedicine;
    if (state.hasValue) {
      final currentList = state.value!;
      oldMedicine = currentList.where((m) => m.id == medicine.id).firstOrNull;
      state = AsyncData(currentList.map((m) => m.id == medicine.id ? medicine : m).toList());
    }

    oldMedicine ??= await repo.getById(medicine.id);

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
    if (state.hasValue) {
      final currentList = state.value!;
      oldMedicine = currentList.where((m) => m.id == id).firstOrNull;
      state = AsyncData(currentList.where((m) => m.id != id).toList());
    }

    oldMedicine ??= await repo.getById(id);

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
    try {
      final ids = NotificationIdManager.getMedicineNotificationIds(
        medicineId: medicine.id,
        reminderTimes: medicine.reminderTimes,
        frequency: medicine.frequency,
        daysOfWeek: medicine.daysOfWeek,
        interval: medicine.interval,
      );

      for (final id in ids) {
        await NotificationService.cancelById(id);
      }

      await NotificationService.cancel(medicine.id);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[MedicineListNotifier] Safe error cancelling notifications: $e');
      }
    }
  }
}
