import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/repository_providers.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/enums/appointment_status.dart';
import '../../domain/usecases/base_usecase.dart';
import '../../domain/usecases/appointments/get_appointments_usecase.dart';
import '../../domain/usecases/appointments/add_appointment_usecase.dart';
import '../../core/di/service_providers.dart';
import '../../core/types/runtime_types.dart';
import '../../data/services/analytics_service.dart';
import '../../data/services/notification_service.dart';
import 'medicine_providers.dart';

final calendarViewTypeProvider = NotifierProvider<CalendarViewTypeNotifier, String>(CalendarViewTypeNotifier.new);

class CalendarViewTypeNotifier extends Notifier<String> {
  @override
  String build() => 'Aylık';
  
  void set(String val) => state = val;
}

// documentRepositoryProvider and appointmentRepositoryProvider are now in core/di/repository_providers.dart

final getAppointmentsUseCaseProvider = Provider<GetAppointmentsUseCase>((ref) {
  return GetAppointmentsUseCase(ref.read(appointmentRepositoryProvider));
});

final addAppointmentUseCaseProvider = Provider<AddAppointmentUseCase>((ref) {
  return AddAppointmentUseCase(ref.read(appointmentRepositoryProvider));
});

final appointmentListProvider =
    AsyncNotifierProvider<AppointmentListNotifier, List<Appointment>>(
  AppointmentListNotifier.new,
);

final nextAppointmentProvider = FutureProvider<Appointment?>((ref) async {
  final repo = ref.read(appointmentRepositoryProvider);
  return repo.getNextUpcoming();
});

class AppointmentListNotifier extends AsyncNotifier<List<Appointment>> {
  @override
  Future<List<Appointment>> build() async {
    final useCase = ref.read(getAppointmentsUseCaseProvider);
    final result = await useCase.call(NoParams());
    return result.fold((l) => throw l, (r) => r);
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(() {
      final useCase = ref.read(getAppointmentsUseCaseProvider);
      return useCase.call(NoParams()).then((value) => value.fold((l) => throw l, (r) => r));
    });
  }

  Future<void> addAppointment(Appointment appointment) async {
    final useCase = ref.read(addAppointmentUseCaseProvider);
    
    // ⚡ OPTIMISTIC UPDATE
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
        await _scheduleReminders(appointment);
        AnalyticsService.log(AnalyticsService.appointmentAdded);
        // Refresh called locally to sync any ID changes from repo if needed, 
        // but the optimistic update already handled UI.
      },
    );
  }

  Future<void> updateAppointment(Appointment appointment) async {
    final repo = ref.read(appointmentRepositoryProvider);
    
    // ⚡ OPTIMISTIC UPDATE
    if (state.hasValue) {
      final currentList = state.value!;
      state = AsyncData(currentList.map((a) => a.id == appointment.id ? appointment : a).toList());
    }

    try {
      await repo.update(appointment);
      await _rebuildAllNotifications();
    } catch (e) {
      await refresh();
      rethrow;
    }
  }

  Future<void> _scheduleReminders(Appointment app) async {
    final notifier = ref.read(notificationServiceProvider);
    
    // PERMISSION UX FIX (Moment of Need)
    // Request permission here before scheduling if not already granted.
    final permissionState = await notifier.requestPermissions(requestExactAlarm: true);
    if (permissionState != NotificationPermissionState.granted) {
      AnalyticsService.log(AnalyticsService.appointmentReminderPermissionDenied);
      return;
    }

    final now = DateTime.now();
    for (final reminderDate in _generatedReminderDates(app)) {
      if (reminderDate.isAfter(now)) {
        await NotificationService.schedule(
          id: app.id,
          title: "📅 Appointment",
          body: "📅 Upcoming appointment",
          date: reminderDate,
        );
      }
    }
  }

  Future<void> rescheduleAllNotifications(List<Appointment> appointments) async {
    for (final appointment in appointments) {
      await _scheduleReminders(appointment);
    }
  }

  List<DateTime> _generatedReminderDates(Appointment app) {
    final reminderTime = app.reminderTime;
    if (reminderTime == null || reminderTime.isEmpty) return [];

    final offset = _reminderOffset(reminderTime);
    final reminderDate = app.fullDateTime.subtract(offset);
    return [reminderDate];
  }

  Duration _reminderOffset(String reminderTime) {
    switch (reminderTime) {
      case 'reminder_1d':
      case '1 gün önce':
      case '24 Saat':
        return const Duration(days: 1);
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
    
    // ⚡ OPTIMISTIC UPDATE
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

    // ⚡ OPTIMISTIC UPDATE
    if (state.hasValue) {
      state = AsyncData(state.value!.where((a) => a.id != id).toList());
    }

    try {
      await repo.delete(id);
      await _rebuildAllNotifications();
    } catch (e) {
      await refresh();
      rethrow;
    }
  }

  Future<void> _rebuildAllNotifications() async {
    await NotificationService.cancelAll();

    final appointments = state.hasValue
        ? state.value!
        : await ref.read(appointmentListProvider.future);
    final medicines = await ref.read(medicineListProvider.future);

    await ref
        .read(medicineListProvider.notifier)
        .rescheduleAllNotifications(medicines);
    await rescheduleAllNotifications(appointments);
  }
}
