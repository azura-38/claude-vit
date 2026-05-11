import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/appointment_form_model.dart';
import '../../../../../shared/domain/enums/appointment_status.dart';
import '../../../../../shared/domain/enums/common_enums.dart';
import '../../../../../core/utils/uuid_generator.dart';
import '../../../domain/entities/appointment.dart';
import '../../providers/appointment_providers.dart';

final appointmentFormProvider =
    StateNotifierProvider<AppointmentFormNotifier, AppointmentFormModel>((ref) {
      return AppointmentFormNotifier(ref);
    });

class AppointmentFormNotifier extends StateNotifier<AppointmentFormModel> {
  final Ref ref;

  AppointmentFormNotifier(this.ref)
    : super(AppointmentFormModel(date: DateTime.now()));

  void updateTitle(String value) {
    state = state.copyWith(title: value);
  }

  void updateType(AppointmentType type) {
    state = state.copyWith(type: type);
  }

  void updatePriority(AppointmentPriority priority) {
    state = state.copyWith(priority: priority);
  }

  void updateLocation(String value) {
    state = state.copyWith(location: value);
  }

  void updateReminder(String value) {
    state = state.copyWith(reminder: value);
  }

  void updateNotes(String value) {
    state = state.copyWith(notes: value);
  }

  void updateDate(DateTime value) {
    state = state.copyWith(date: value);
  }

  Future<void> submit() async {
    final importance =
        state.priority == AppointmentPriority.high
            ? ImportanceLevel.high
            : state.priority == AppointmentPriority.low
            ? ImportanceLevel.low
            : ImportanceLevel.medium;

    final appointment = Appointment(
      id: generateUuid(),
      title: state.title.isEmpty ? 'New Appointment' : state.title,
      doctor: 'Unknown Doctor', // Can be enhanced later based on UI fields
      department: 'General',
      hospital: state.location.isEmpty ? 'Unknown Location' : state.location,
      date: state.date.toIso8601String().substring(0, 10),
      time:
          '${state.date.hour.toString().padLeft(2, '0')}:${state.date.minute.toString().padLeft(2, '0')}',
      status: AppointmentStatus.upcoming,
      type: state.type.name,
      location: state.location,
      notes: state.notes,
      reminderTime: state.reminder,
      importance: importance,
      createdAt: DateTime.now(),
    );

    await ref
        .read(appointmentListProvider.notifier)
        .addAppointment(appointment);
  }
}
