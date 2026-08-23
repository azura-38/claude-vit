import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/appointment_form_model.dart';
import '../../../../../shared/domain/enums/appointment_status.dart';
import '../../../../../shared/domain/enums/common_enums.dart';
import '../../../../../core/utils/uuid_generator.dart';

import '../../../domain/entities/appointment.dart';
import '../../providers/appointment_providers.dart';

final appointmentFormProvider = StateNotifierProvider.autoDispose<AppointmentFormNotifier, AppointmentFormModel>((ref) {
  return AppointmentFormNotifier(ref);
});

class AppointmentFormNotifier extends StateNotifier<AppointmentFormModel> {
  AppointmentFormNotifier(this.ref) : super(AppointmentFormModel(date: DateTime.now()));

  final Ref ref;

  AppointmentFormModel _freshState() => AppointmentFormModel(date: DateTime.now());

  void reset() {
    state = _freshState();
  }

  void updateTitle(String value) {
    state = state.copyWith(title: value);
  }

  void updateType(AppointmentType type) {
    final subs = subcategoriesForAppointmentType(type);
    state = state.copyWith(type: type, subcategory: subs.first);
  }

  void updateSubcategory(AppointmentSubcategory subcategory) {
    state = state.copyWith(subcategory: subcategory);
  }

  void updatePriority(AppointmentPriority priority) {
    state = state.copyWith(priority: priority);
  }

  void updateLocation(String value) {
    state = state.copyWith(location: value);
  }

  void updateReminder(AppointmentReminder value) {
    state = state.copyWith(reminder: value);
  }

  void updateNotes(String value) {
    state = state.copyWith(notes: value);
  }

  void updateDate(DateTime value) {
    state = state.copyWith(date: value);
  }

  void updateTime(TimeOfDay value) {
    state = state.copyWith(
      date: DateTime(state.date.year, state.date.month, state.date.day, value.hour, value.minute),
    );
  }

  Future<void> submit() async {
    if (!state.isValid || state.isSubmitting) return;

    final form = state;
    state = state.copyWith(isSubmitting: true);
    final importance = form.priority == AppointmentPriority.high
        ? ImportanceLevel.high
        : form.priority == AppointmentPriority.low
            ? ImportanceLevel.low
            : ImportanceLevel.medium;

    try {
      final title = form.title.trim();
      final location = form.location.trim();
      final appointment = Appointment(
        id: generateUuid(),
        title: title,
        doctor: title,
        department: title,
        hospital: location,
        person: form.subcategory.name,
        date: form.date.toIso8601String().substring(0, 10),
        time: '${form.date.hour.toString().padLeft(2, '0')}:${form.date.minute.toString().padLeft(2, '0')}',
        status: AppointmentStatus.upcoming,
        type: form.type.name,
        location: location,
        notes: form.notes.trim().isEmpty ? null : form.notes.trim(),
        reminderTime: form.reminder.key,
        selectedReminders: [form.reminder.key],
        importance: importance,
        createdAt: DateTime.now(),
      );

      await ref.read(appointmentListProvider.notifier).addAppointment(appointment);
      reset();
    } catch (e, st) {
      debugPrint('[AppointmentFormNotifier] Submit error: $e');
      debugPrintStack(stackTrace: st);
      state = form.copyWith(isSubmitting: false);
      rethrow;
    }
  }
}
