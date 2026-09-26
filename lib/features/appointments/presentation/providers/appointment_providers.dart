import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/repository_providers.dart';
import '../../../../core/di/service_providers.dart';
import '../../../../core/notifications/app_notification_payload.dart';
import '../../../../core/notifications/notification_id_manager.dart';
import '../../../../core/types/runtime_types.dart';
import '../../../../features/gamification/presentation/providers/achievement_providers.dart';
import '../../../../shared/data/services/analytics_service.dart';
import '../../../../shared/data/services/notification_service.dart';
import '../../../../shared/data/services/usage_limit_service.dart';
import '../../../../shared/domain/enums/appointment_status.dart';
import '../../../../shared/domain/usecases/appointments/add_appointment_usecase.dart';
import '../../../../shared/domain/usecases/appointments/get_appointments_usecase.dart';
import '../../../../shared/domain/usecases/base_usecase.dart';
import '../../../../shared/providers/daily_mission_providers.dart';
import '../../../../shared/providers/season_providers.dart';
import '../../domain/entities/appointment.dart';

enum CalendarViewType { monthly, weekly }

final calendarViewTypeProvider = NotifierProvider<CalendarViewTypeNotifier, CalendarViewType>(CalendarViewTypeNotifier.new);

class CalendarViewTypeNotifier extends Notifier<CalendarViewType> {
  @override
  CalendarViewType build() => CalendarViewType.monthly;

  void set(CalendarViewType val) => state = val;
}

final getAppointmentsUseCaseProvider = Provider<GetAppointmentsUseCase>((ref) {
  return GetAppointmentsUseCase(ref.read(appointmentRepositoryProvider));
});

final addAppointmentUseCaseProvider = Provider<AddAppointmentUseCase>((ref) {
  return AddAppointmentUseCase(ref.read(appointmentRepositoryProvider));
});

final appointmentListProvider = AsyncNotifierProvider<AppointmentListNotifier, List<Appointment>>(AppointmentListNotifier.new);

final nextAppointmentProvider = FutureProvider<Appointment?>((ref) async {
  final repo = ref.read(appointmentRepositoryProvider);
  return repo.getNextUpcoming();
});

class _AppointmentReminderItem {
  final int notificationId;
  final DateTime scheduledDate;
  final String reminderKey;

  const _AppointmentReminderItem({
    required this.notificationId,
    required this.scheduledDate,
    required this.reminderKey,
  });
}

class AppointmentListNotifier extends AsyncNotifier<List<Appointment>> {
  @override
  Future<List<Appointment>> build() async {
    try {
      final useCase = ref.read(getAppointmentsUseCaseProvider);
      final result = await useCase.call(NoParams());
      final appointments = result.fold((l) => throw l, (r) => r);
      return appointments;
    } catch (e) {
      debugPrint('[Appointments] DB not ready or error: $e');
      return <Appointment>[];
    }
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(() {
      final useCase = ref.read(getAppointmentsUseCaseProvider);
      return useCase.call(NoParams()).then((value) => value.fold((l) => throw l, (r) => r));
    });
  }

  Future<void> addAppointment(Appointment appointment) async {
    // Capture dependencies synchronously before awaiting
    final limitService = ref.read(usageLimitServiceProvider);
    final useCase = ref.read(addAppointmentUseCaseProvider);
    final dailyMissionNotifier = ref.read(dailyMissionProvider.notifier);
    final seasonNotifier = ref.read(seasonProvider.notifier);

    final limit = await limitService.consumeCreate();
    if (!limit.allowed) {
      throw UsageLimitExceededException(limit.limit);
    }

    if (state.hasValue) {
      final currentList = state.value!;
      state = AsyncData([appointment, ...currentList]);
    }

    final result = await useCase.call(appointment);
    if (result.isLeft) {
      await refresh();
      result.fold((l) => throw l, (_) {});
      return;
    }

    await dailyMissionNotifier.track('app_daily');
    await _trackAppointmentAchievements();
    await seasonNotifier.addXP(10);
    AnalyticsService.log(AnalyticsService.appointmentAdded);

    await _scheduleReminders(appointment);
  }

  Future<void> _trackAppointmentAchievements() async {
    final repo = ref.read(appointmentRepositoryProvider);
    final count = state.valueOrNull?.length ?? (await repo.getAll()).length;
    final achievement = ref.read(achievementProvider.notifier);
    for (final id in const ['app_1', 'app_3', 'app_5', 'app_10', 'app_20', 'app_30']) {
      await achievement.track(id, setAbsolute: count);
    }
  }

  Future<void> updateAppointment(Appointment appointment) async {
    final repo = ref.read(appointmentRepositoryProvider);

    Appointment? oldAppointment;
    if (state.hasValue) {
      final currentList = state.value!;
      oldAppointment = currentList.where((a) => a.id == appointment.id).firstOrNull;
      state = AsyncData(currentList.map((a) => a.id == appointment.id ? appointment : a).toList());
    }

    oldAppointment ??= await repo.getById(appointment.id);

    try {
      await repo.update(appointment);
      if (oldAppointment != null) {
        await _cancelReminders(oldAppointment);
      }
      await _scheduleReminders(appointment);
    } catch (e) {
      await refresh();
      rethrow;
    }
  }

  Future<void> _scheduleReminders(Appointment app) async {
    try {
      final keys = _extractReminderKeys(app);
      if (keys.isEmpty) return;

      final notifier = ref.read(notificationServiceProvider);
      final permissionState = await notifier.requestPermissions(requestExactAlarm: true);
      if (permissionState != NotificationPermissionState.granted) {
        AnalyticsService.log(AnalyticsService.appointmentReminderPermissionDenied);
        return;
      }

      final items = _getReminderItems(app);
      for (final item in items) {
        await NotificationService.scheduleAppointment(
          id: app.id,
          title: '📅 VitaCase Reminder',
          body: (app.title != null && app.title!.isNotEmpty) ? app.title! : app.doctor,
          date: item.scheduledDate,
          explicitId: item.notificationId,
          payload: AppNotificationPayload(
            type: NotificationType.appointment,
            entityId: app.id,
            occurrenceAt: item.scheduledDate,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AppointmentListNotifier] Safe error scheduling reminders: $e');
      }
    }
  }

  Future<void> rescheduleAllNotifications(List<Appointment> appointments) async {
    try {
      final notifier = ref.read(notificationServiceProvider);
      final permissionState = await notifier.requestPermissions(requestExactAlarm: true);
      if (permissionState != NotificationPermissionState.granted) {
        AnalyticsService.log(AnalyticsService.appointmentReminderPermissionDenied);
        return;
      }

      final pending = await NotificationService.getPendingNotificationRequests();
      final pendingMap = {for (final p in pending) p.id: p};
      final activeIds = <int>{};

      for (final appointment in appointments) {
        final items = _getReminderItems(appointment);
        for (final item in items) {
          activeIds.add(item.notificationId);
          final existing = pendingMap[item.notificationId];
          final expectedPayload = AppNotificationPayload(
            type: NotificationType.appointment,
            entityId: appointment.id,
            occurrenceAt: item.scheduledDate,
          ).encode();

          // Idempotency: if already scheduled with matching payload/time, skip redundant platform schedule call
          if (existing != null && existing.payload == expectedPayload) {
            continue;
          }

          await NotificationService.scheduleAppointment(
            id: appointment.id,
            title: '📅 VitaCase Reminder',
            body: (appointment.title != null && appointment.title!.isNotEmpty)
                ? appointment.title!
                : appointment.doctor,
            date: item.scheduledDate,
            explicitId: item.notificationId,
            payload: AppNotificationPayload(
              type: NotificationType.appointment,
              entityId: appointment.id,
              occurrenceAt: item.scheduledDate,
            ),
          );
        }
      }

      // Stale cleanup: Clean up orphaned appointment notifications that are no longer active
      for (final p in pending) {
        if (NotificationIdManager.isAppointmentId(p.id) && !activeIds.contains(p.id)) {
          await NotificationService.cancelById(p.id);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AppointmentListNotifier] Safe error in rescheduleAllNotifications: $e');
      }
    }
  }

  List<String> _extractReminderKeys(Appointment app) {
    final keys = <String>{};
    if (app.reminderTime != null &&
        app.reminderTime!.isNotEmpty &&
        app.reminderTime != 'none') {
      keys.add(app.reminderTime!);
    }
    for (final r in app.selectedReminders) {
      final trimmed = r.trim();
      if (trimmed.isNotEmpty && trimmed != 'none') {
        keys.add(trimmed);
      }
    }
    return keys.toList();
  }

  List<_AppointmentReminderItem> _getReminderItems(Appointment app, {DateTime? now}) {
    final currentTime = now ?? DateTime.now();
    final appointmentTime = app.fullDateTime;
    if (!appointmentTime.isAfter(currentTime)) return [];

    final keys = _extractReminderKeys(app);
    final items = <_AppointmentReminderItem>[];

    for (final key in keys) {
      final offset = _reminderOffset(key);
      DateTime? reminderDate = appointmentTime.subtract(offset);

      if (!reminderDate.isAfter(currentTime)) {
        // If preferred offset has passed, attempt 1 minute before appointment if still in future
        final oneMinBefore = appointmentTime.subtract(const Duration(minutes: 1));
        if (oneMinBefore.isAfter(currentTime)) {
          reminderDate = oneMinBefore;
        } else {
          // If even that has passed, skip this reminder
          continue;
        }
      }

      final notifId = NotificationIdManager.getAppointmentReminderId(
        appointmentId: app.id,
        reminderKey: key,
      );

      items.add(_AppointmentReminderItem(
        notificationId: notifId,
        scheduledDate: reminderDate,
        reminderKey: key,
      ));
    }

    return items;
  }

  Duration _reminderOffset(String reminderTime) {
    switch (reminderTime) {
      case 'reminder_7d':
      case '7 gün önce':
      case '7 Gün':
      case '7 days before':
        return const Duration(days: 7);
      case 'reminder_1d':
      case '1 gün önce':
      case '24 Saat':
      case '1 day before':
        return const Duration(days: 1);
      case 'reminder_1h':
      case '1 saat önce':
      case '1 Saat':
      case '1 hour before':
        return const Duration(hours: 1);
      case 'reminder_10m':
      case '10 dk önce':
      case '10 minutes before':
      default:
        return const Duration(minutes: 10);
    }
  }

  Future<void> updateStatus(String id, AppointmentStatus status) async {
    final repo = ref.read(appointmentRepositoryProvider);

    if (state.hasValue) {
      final currentList = state.value!;
      state = AsyncData(currentList.map((a) => a.id == id ? a.copyWith(status: status) : a).toList());
    }

    try {
      await repo.updateStatus(id, status);
    } catch (e) {
      await refresh();
      rethrow;
    }
  }

  Future<void> deleteAppointment(String id) async {
    final repo = ref.read(appointmentRepositoryProvider);

    Appointment? oldAppointment;
    if (state.hasValue) {
      final currentList = state.value!;
      oldAppointment = currentList.where((a) => a.id == id).firstOrNull;
      state = AsyncData(currentList.where((a) => a.id != id).toList());
    }

    oldAppointment ??= await repo.getById(id);

    try {
      await repo.delete(id);
      if (oldAppointment != null) {
        await _cancelReminders(oldAppointment);
      }
    } catch (e) {
      await refresh();
      rethrow;
    }
  }

  Future<void> _cancelReminders(Appointment app) async {
    try {
      final keys = _extractReminderKeys(app);
      final ids = NotificationIdManager.getAppointmentNotificationIds(
        appointmentId: app.id,
        reminderKeys: keys,
      );

      for (final id in ids) {
        await NotificationService.cancelById(id);
      }

      // Also cancel by legacy key to ensure no orphaned legacy reminders
      await NotificationService.cancel(app.id);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AppointmentListNotifier] Safe error cancelling reminders: $e');
      }
    }
  }
}
