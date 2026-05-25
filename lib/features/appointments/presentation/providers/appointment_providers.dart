import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/repository_providers.dart';
import '../../../../core/di/service_providers.dart';
import '../../../../core/notifications/app_notification_payload.dart';
import '../../../../core/types/runtime_types.dart';
import '../../../../features/gamification/presentation/providers/achievement_providers.dart';
import '../../../../shared/data/services/analytics_service.dart';
import '../../../../shared/data/services/notification_engine.dart';
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

class AppointmentListNotifier extends AsyncNotifier<List<Appointment>> {
  @override
  Future<List<Appointment>> build() async {
    try {
      final useCase = ref.read(getAppointmentsUseCaseProvider);
      final result = await useCase.call(NoParams());
      return result.fold((l) => throw l, (r) => r);
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
    final limit = await ref.read(usageLimitServiceProvider).consumeCreate();
    if (!limit.allowed) {
      throw UsageLimitExceededException(limit.limit);
    }

    final useCase = ref.read(addAppointmentUseCaseProvider);

    if (state.hasValue) {
      final currentList = state.value!;
      state = AsyncData([appointment, ...currentList]);
    }

    final result = await useCase.call(appointment);
    result.fold(
      (l) async {
        await refresh();
        throw l;
      },
      (_) async {
        await ref.read(dailyMissionProvider.notifier).track('app_daily');
        await _trackAppointmentAchievements();
        await ref.read(seasonProvider.notifier).addXP(10);
        await _scheduleReminders(appointment);
        AnalyticsService.log(AnalyticsService.appointmentAdded);
      },
    );
  }

  Future<void> _trackAppointmentAchievements() async {
    final count = state.valueOrNull?.length ?? (await ref.read(appointmentRepositoryProvider).getAll()).length;
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

    try {
      await repo.update(appointment);
      if (oldAppointment != null) await _cancelReminders(oldAppointment);
      await _scheduleReminders(appointment);
    } catch (e) {
      await refresh();
      rethrow;
    }
  }

  Future<void> _scheduleReminders(Appointment app) async {
    final notifier = ref.read(notificationServiceProvider);
    final permissionState = await notifier.requestPermissions(requestExactAlarm: true);
    if (permissionState != NotificationPermissionState.granted) {
      AnalyticsService.log(AnalyticsService.appointmentReminderPermissionDenied);
      return;
    }

    final now = DateTime.now();
    for (final reminderDate in _generatedReminderDates(app, now: now)) {
      if (reminderDate.isAfter(now)) {
        await NotificationEngine.scheduleAppointment(
          id: app.id,
          title: '📅 VitaCase Reminder',
          body: 'Upcoming: ${app.title}',
          scheduleTime: reminderDate,
          payload: AppNotificationPayload(
            type: NotificationType.appointment,
            entityId: app.id,
            occurrenceAt: reminderDate,
          ).encode(),
        );
      }
    }
  }

  Future<void> rescheduleAllNotifications(List<Appointment> appointments) async {
    for (final appointment in appointments) {
      await _scheduleReminders(appointment);
    }
  }

  List<DateTime> _generatedReminderDates(Appointment app, {DateTime? now}) {
    final currentTime = now ?? DateTime.now();
    final appointmentTime = app.fullDateTime;
    final reminderTime = app.reminderTime;
    if (reminderTime == null || reminderTime.isEmpty) return [];
    if (!appointmentTime.isAfter(currentTime)) return [];

    final offset = _reminderOffset(reminderTime);
    final requestedReminder = appointmentTime.subtract(offset);
    if (requestedReminder.isAfter(currentTime)) return [requestedReminder];

    final oneMinuteBeforeAppointment = appointmentTime.subtract(const Duration(minutes: 1));
    if (oneMinuteBeforeAppointment.isAfter(currentTime)) return [oneMinuteBeforeAppointment];

    final oneMinuteFromNow = currentTime.add(const Duration(minutes: 1));
    if (oneMinuteFromNow.isBefore(appointmentTime)) return [oneMinuteFromNow];

    return [];
  }

  Duration _reminderOffset(String reminderTime) {
    switch (reminderTime) {
      case 'reminder_1d':
      case '1 gün önce':
      case '24 Saat':
        return const Duration(days: 1);
      case 'reminder_7d':
      case '7 gün önce':
      case '7 Gün':
        return const Duration(days: 7);
      case 'reminder_1h':
      case '1 saat önce':
      case '1 Saat':
        return const Duration(hours: 1);
      case 'reminder_10m':
      case '10 dk önce':
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

    try {
      await repo.delete(id);
      if (oldAppointment != null) await _cancelReminders(oldAppointment);
    } catch (e) {
      await refresh();
      rethrow;
    }
  }

  Future<void> _cancelReminders(Appointment app) async {
    for (final date in _generatedReminderDates(app)) {
      await NotificationEngine.cancel(app.id, date);
    }
  }
}
