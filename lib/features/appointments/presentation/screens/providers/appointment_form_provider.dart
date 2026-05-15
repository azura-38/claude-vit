import 'package:flutter/material.dart';
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
      date: DateTime(
        state.date.year,
        state.date.month,
        state.date.day,
        value.hour,
        value.minute,
      ),
    );
  }

  Future<void> submit() async {
    if (!state.isValid || state.isSubmitting) return;

    state = state.copyWith(isSubmitting: true);
    final importance = state.priority == AppointmentPriority.high
        ? ImportanceLevel.high
        : state.priority == AppointmentPriority.low
            ? ImportanceLevel.low
            : ImportanceLevel.medium;

    try {
      final title = state.title.trim();
      final location = state.location.trim();
      final appointment = Appointment(
        id: generateUuid(),
        title: title,
        doctor: title,
        // Do not persist the English enum label such as "Doctor Visit" or
        // "Lab Test" as the visible list title. The user-entered appointment
        // title is language-neutral and avoids hardcoded EN/TR UI leakage.
        department: title,
        hospital: location,
        person: state.subcategory.name,
        date: state.date.toIso8601String().substring(0, 10),
        time:
            '${state.date.hour.toString().padLeft(2, '0')}:${state.date.minute.toString().padLeft(2, '0')}',
        status: AppointmentStatus.upcoming,
        type: state.type.name,
        location: location,
        notes: state.notes.trim().isEmpty ? null : state.notes.trim(),
        reminderTime: state.reminder.key,
        selectedReminders: [state.reminder.key],
        importance: importance,
        createdAt: DateTime.now(),
      );

      await ref.read(appointmentListProvider.notifier).addAppointment(appointment);
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }
}
