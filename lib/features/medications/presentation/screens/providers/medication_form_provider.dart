import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/medication_form_model.dart';

final medicationFormProvider =
    StateNotifierProvider<MedicationFormNotifier, MedicationFormModel>((ref) {
  return MedicationFormNotifier();
});

class MedicationFormNotifier extends StateNotifier<MedicationFormModel> {
  MedicationFormNotifier() : super(const MedicationFormModel());

  void updateName(String value) {
    state = state.copyWith(medicineName: value);
  }

  void updateFrequency(MedicationFrequency frequency) {
    state = state.copyWith(frequency: frequency);
  }

  void increaseQuantity() {
    state = state.copyWith(quantity: state.quantity + 1);
  }

  void decreaseQuantity() {
    if (state.quantity <= 1) return;
    state = state.copyWith(quantity: state.quantity - 1);
  }

  void addTime(String time) {
    final updated = [...state.reminderTimes, time];
    state = state.copyWith(reminderTimes: updated);
  }

  void removeTime(String time) {
    final updated = state.reminderTimes.where((e) => e != time).toList();
    state = state.copyWith(reminderTimes: updated);
  }
}
