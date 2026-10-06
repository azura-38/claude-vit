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

  void initForEdit(Appointment appointment) {
    AppointmentType resolvedType = AppointmentType.medical;
    for (final t in AppointmentType.values) {
      if (appointment.type != null && t.name.toLowerCase() == appointment.type!.toLowerCase()) {
        resolvedType = t;
        break;
      }
    }

    final subcategories = subcategoriesForAppointmentType(resolvedType);
    AppointmentSubcategory resolvedSub = subcategories.first;
    for (final s in subcategories) {
      if (appointment.person != null && s.name.toLowerCase() == appointment.person!.toLowerCase()) {
        resolvedSub = s;
        break;
      }
    }

    AppointmentPriority priority = AppointmentPriority.normal;
    if (appointment.importance == ImportanceLevel.high) {
      priority = AppointmentPriority.high;
    } else if (appointment.importance == ImportanceLevel.low) {
      priority = AppointmentPriority.low;
    }

    AppointmentReminder reminder = AppointmentReminder.oneHour;
    for (final r in AppointmentReminder.values) {
      if (r.key == appointment.reminderTime) {
        reminder = r;
        break;
      }
    }

    DateTime parsedDate = DateTime.now();
    try {
      final dateParts = appointment.date.split('-');
      if (dateParts.length == 3) {
        int year = int.parse(dateParts[0]);
        int month = int.parse(dateParts[1]);
        int day = int.parse(dateParts[2]);
        int hour = 9;
        int minute = 0;
        final timeParts = appointment.time.split(':');
        if (timeParts.length >= 2) {
          hour = int.tryParse(timeParts[0]) ?? 9;
          minute = int.tryParse(timeParts[1]) ?? 0;
        }
        parsedDate = DateTime(year, month, day, hour, minute);
      }
    } catch (_) {}

    state = AppointmentFormModel(
      editingId: appointment.id,
      title: appointment.title ?? appointment.department,
      type: resolvedType,
      subcategory: resolvedSub,
      priority: priority,
      date: parsedDate,
      location: appointment.location ?? appointment.hospital,
      reminder: reminder,
      notes: appointment.notes ?? '',
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
      final isEdit = form.editingId != null;

      final appointment = Appointment(
        id: isEdit ? form.editingId! : generateUuid(),
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

      if (isEdit) {
        await ref.read(appointmentListProvider.notifier).updateAppointment(appointment);
      } else {
        await ref.read(appointmentListProvider.notifier).addAppointment(appointment);
      }
      reset();
    } catch (_) {
      state = form.copyWith(isSubmitting: false);
      rethrow;
    }
  }
}
