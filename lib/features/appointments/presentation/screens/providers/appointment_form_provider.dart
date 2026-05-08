import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/appointment_form_model.dart';

final appointmentFormProvider = StateNotifierProvider<
    AppointmentFormNotifier,
    AppointmentFormModel>((ref) {
  return AppointmentFormNotifier();
});

class AppointmentFormNotifier
    extends StateNotifier<AppointmentFormModel> {
  AppointmentFormNotifier()
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
}
