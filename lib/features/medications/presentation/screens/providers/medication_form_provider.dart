import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/medication_form_model.dart';
import '../../../../../shared/domain/enums/common_enums.dart';
import '../../../../../shared/providers/medicine_providers.dart';
import '../../../../../core/utils/uuid_generator.dart';
import '../../../domain/entities/medicine.dart';

final medicationFormProvider =
    StateNotifierProvider<MedicationFormNotifier, MedicationFormModel>((ref) {
      return MedicationFormNotifier(ref);
    });

class MedicationFormNotifier extends StateNotifier<MedicationFormModel> {
  final Ref ref;

  MedicationFormNotifier(this.ref) : super(const MedicationFormModel());

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

  Future<void> submit() async {
    final medicine = Medicine(
      id: generateUuid(),
      name: state.medicineName.isEmpty ? 'New Medication' : state.medicineName,
      dosage: '${state.quantity} ${state.unit}',
      startDate: DateTime.now().toIso8601String().substring(0, 10),
      frequency: state.frequency.name,
      hungerStatus: HungerStatus.farketmez,
      reminderTimes: state.reminderTimes,
      createdAt: DateTime.now(),
    );

    await ref.read(medicineListProvider.notifier).addMedicine(medicine);
  }
}
