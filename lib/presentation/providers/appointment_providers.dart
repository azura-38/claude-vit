import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/repository_providers.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/enums/appointment_status.dart';
import '../../core/l10n/translations.dart';
import '../../domain/usecases/base_usecase.dart';
import '../../domain/usecases/appointments/get_appointments_usecase.dart';
import '../../domain/usecases/appointments/add_appointment_usecase.dart';
import 'locale_provider.dart';
import '../../core/di/service_providers.dart';
import '../../core/types/runtime_types.dart';
import '../../data/services/analytics_service.dart';
import '../../data/services/notification_service.dart';

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
      await _cancelReminders(appointment.id);
      await repo.update(appointment);
      await _scheduleReminders(appointment);
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
    
    DateTime? appDateTime;
    try {
      appDateTime = DateTime.parse('${app.date} ${app.time}');
    } catch (e) {
      return;
    }

    final locale = ref.read(localeProvider);
    final lang = locale.languageCode;
    final trans = Translations.data[lang] ?? Translations.data['en']!;

    final intervals = {
      '24 Saat': const Duration(hours: 24),
      '1 Saat': const Duration(hours: 1),
    };

    int i = 0;
    for (var entry in intervals.entries) {
      final scheduledDate = appDateTime.subtract(entry.value);
      if (scheduledDate.isAfter(now)) {
        final notificationId = NotificationService.getStableId(app.id, (i + 1) * 10000);
        final timeLabel = entry.key == '24 Saat' ? (lang == 'tr' ? '24 saat' : '24 hours') : (lang == 'tr' ? '1 saat' : '1 hour');
        
        await NotificationService.scheduleAppointment(
          id: "${app.id}_$i",
          title: app.doctor,
          date: scheduledDate,
        );
      }
      i++;
    }
  }

  Future<void> _cancelReminders(String appointmentId) async {
    final notifier = ref.read(notificationServiceProvider);
    for (int i = 0; i < 3; i++) {
        final notificationId = NotificationService.getStableId(appointmentId, (i + 1) * 10000);
        await notifier.cancelNotification(notificationId);
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
      await _cancelReminders(id);
      await repo.delete(id);
    } catch (e) {
      await refresh();
      rethrow;
    }
  }
}
