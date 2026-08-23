import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/di/repository_providers.dart';
import '../../core/di/service_providers.dart';
import '../../core/notifications/app_notification_payload.dart';
import '../../core/types/runtime_types.dart';
import '../../features/gamification/presentation/providers/achievement_providers.dart';
import '../../features/medications/domain/entities/medicine.dart';
import '../data/services/analytics_service.dart';
import '../data/services/notification_engine.dart';
import '../data/services/usage_limit_service.dart';
import '../domain/usecases/base_usecase.dart';
import '../domain/usecases/medicines/add_medicine_usecase.dart';
import '../domain/usecases/medicines/get_medicines_usecase.dart';
import 'daily_mission_providers.dart';
import 'season_providers.dart';

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
    
    return result.fold(
      (l) => throw l, 
      (medicines) async {
        final nowStr = DateTime.now().toIso8601String().substring(0, 10);
        var changed = false;
        
        final updatedMedicines = medicines.map((m) {
          if (m.isTaken && m.lastTakenDate != nowStr) {
            changed = true;
            return m.copyWith(isTaken: false);
          }
          return m;
        }).toList();

        if (changed) {
          final repo = ref.read(medicineRepositoryProvider);
          for (final m in updatedMedicines) {
             if (!m.isTaken && medicines.firstWhere((x) => x.id == m.id).isTaken) {
               await repo.update(m);
             }
          }
        }
        
        return updatedMedicines;
      },
    );
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(() {
      final useCase = ref.read(getMedicinesUseCaseProvider);
      return useCase.call(NoParams()).then((value) => value.fold((l) => throw l, (r) => r));
    });
  }

  Future<void> addMedicine(Medicine medicine) async {
    final limit = await ref.read(usageLimitServiceProvider).consumeCreate();
    if (!limit.allowed) {
      throw UsageLimitExceededException(limit.limit);
    }

    final useCase = ref.read(addMedicineUseCaseProvider);

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

    await ref.read(dailyMissionProvider.notifier).track('med_daily');
    await _trackMedicineAchievements();
    await ref.read(seasonProvider.notifier).addXP(15);
    AnalyticsService.log(AnalyticsService.medicineAdded);

    await _scheduleNotifications(medicine);
  }

  Future<void> _trackMedicineAchievements() async {
    final count = state.valueOrNull?.length ?? (await ref.read(medicineRepositoryProvider).getAll()).length;
    final achievement = ref.read(achievementProvider.notifier);
    for (final id in const ['med_1', 'med_3', 'med_5', 'med_10', 'med_25', 'med_50']) {
      await achievement.track(id, setAbsolute: count);
    }
  }

  Future<void> markAsTaken(String id) async {
    final repo = ref.read(medicineRepositoryProvider);
    Medicine? updatedMedicine;
    final nowStr = DateTime.now().toIso8601String().substring(0, 10);

    if (state.hasValue) {
      final currentList = state.value!;
      final updatedList = currentList.map((m) {
        if (m.id != id) return m;
        // currentStock azalt
        final newStock = (m.currentStock != null && m.currentStock! > 0)
            ? m.currentStock! - 1
            : m.currentStock;
        updatedMedicine = m.copyWith(
          isTaken: true, 
          currentStock: newStock,
          lastTakenDate: nowStr,
        );
        return updatedMedicine!;
      }).toList();
      state = AsyncData(updatedList);
    }

    updatedMedicine ??= (await repo.getById(id))?.copyWith(isTaken: true, lastTakenDate: nowStr);
    if (updatedMedicine != null) {
      await repo.update(updatedMedicine!);
      // Stok azalınca uyarı
      await _checkAndNotifyLowStock(updatedMedicine!);
    }
  }

  Future<void> markAsSkipped(String id) async {
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
    if (kDebugMode) print('Medicine $id marked as skipped');
  }

  Future<void> _scheduleNotifications(Medicine medicine) async {
    final notifier = ref.read(notificationServiceProvider);
    final permissionState = await notifier.requestPermissions(requestExactAlarm: true);
    if (permissionState != NotificationPermissionState.granted) {
      AnalyticsService.log(AnalyticsService.medicineReminderPermissionDenied);
      return;
    }

    for (final date in _generatedDates(medicine)) {
      await NotificationEngine.scheduleMedicine(
        id: medicine.id,
        title: '💊 VitaCase Reminder',
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

  /// Stok azalınca uyarı bildirimi gönder
  Future<void> _checkAndNotifyLowStock(Medicine medicine) async {
    final current = medicine.currentStock;
    final total = medicine.totalStock;
    if (current == null || total == null || total == 0) return;
    final ratio = current / total;
    if (ratio < 0.2) {
      // %20'nin altına düştüyse 5 saniye sonra uyarı bildirimi zamanla
      final isTr = (await _getLang()) == 'tr';
      await NotificationEngine.scheduleMedicine(
        id: 'low_stock_${medicine.id}',
        title: isTr ? '⚠️ İlaç stoğu azalıyor' : '⚠️ Low medication stock',
        body: isTr
            ? '${medicine.name} için yalnızca $current adet kaldı. Yenilemeyi unutmayın!'
            : 'Only $current ${medicine.name} left. Don\'t forget to refill!',
        scheduleTime: DateTime.now().add(const Duration(seconds: 5)),
      );
    }
  }

  Future<String> _getLang() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('app_locale') ?? 'en';
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

      if (medicine.frequency == 'weekly' && medicine.daysOfWeek != null && medicine.daysOfWeek!.isNotEmpty) {
        // Haftalık: her seçili gün için önümüzdeki 8 haftayı zamanla
        for (final day in medicine.daysOfWeek!) {
          var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
          // Bu haftanın doğru gününe git
          while (scheduledDate.weekday != day) {
            scheduledDate = scheduledDate.add(const Duration(days: 1));
          }
          if (!scheduledDate.isAfter(now)) {
            scheduledDate = scheduledDate.add(const Duration(days: 7));
          }
          for (int w = 0; w < 8; w++) {
            dates.add(scheduledDate.add(Duration(days: 7 * w)));
          }
        }
      } else if (medicine.frequency == 'custom' && medicine.interval != null) {
        // Custom: belirli aralıklarla 10 tekrar
        var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
        if (!scheduledDate.isAfter(now)) {
          scheduledDate = scheduledDate.add(Duration(days: medicine.interval!));
        }
        for (int i = 0; i < 10; i++) {
          dates.add(scheduledDate);
          scheduledDate = scheduledDate.add(Duration(days: medicine.interval!));
        }
      } else {
        // Daily: önümüzdeki 30 günü zamanla
        for (int i = 0; i < 30; i++) {
          final scheduledDate = DateTime(now.year, now.month, now.day, hour, minute)
              .add(Duration(days: i));
          if (scheduledDate.isAfter(now)) {
            dates.add(scheduledDate);
          }
        }
      }
    }

    return dates;
  }

  Future<void> updateMedicine(Medicine medicine) async {
    final repo = ref.read(medicineRepositoryProvider);

    Medicine? oldMedicine;
    if (state.hasValue) {
      final currentList = state.value!;
      oldMedicine = currentList.where((m) => m.id == medicine.id).firstOrNull;
      state = AsyncData(currentList.map((m) => m.id == medicine.id ? medicine : m).toList());
    }

    try {
      await repo.update(medicine);
      if (oldMedicine != null) await _cancelNotifications(oldMedicine);
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

    try {
      await repo.delete(id);
      if (oldMedicine != null) await _cancelNotifications(oldMedicine);
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
