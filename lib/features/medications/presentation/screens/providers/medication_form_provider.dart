import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/utils/uuid_generator.dart';
import '../../../../../shared/domain/enums/common_enums.dart';
import '../../../../../shared/providers/medicine_providers.dart';
import '../../../domain/entities/medicine.dart';
import '../models/medication_form_model.dart';

final medicationFormProvider = StateNotifierProvider.autoDispose<MedicationFormNotifier, MedicationFormModel>((ref) {
  return MedicationFormNotifier(ref);
});

class MedicationFormNotifier extends StateNotifier<MedicationFormModel> {
  MedicationFormNotifier(this.ref) : super(const MedicationFormModel());

  final Ref ref;

  void reset() {
    state = const MedicationFormModel();
  }

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
    final normalized = time.trim();
    if (normalized.isEmpty) return;
    final updated = {...state.reminderTimes, normalized}.toList()..sort();
    state = state.copyWith(reminderTimes: updated);
  }

  void removeTime(String time) {
    final updated = state.reminderTimes.where((e) => e != time).toList();
    state = state.copyWith(reminderTimes: updated);
  }

  /// Weekly: gün seç/kaldır (1=Pazartesi … 7=Pazar)
  void toggleDay(int weekday) {
    final current = List<int>.from(state.daysOfWeek);
    if (current.contains(weekday)) {
      current.remove(weekday);
    } else {
      current.add(weekday);
      current.sort();
    }
    state = state.copyWith(daysOfWeek: current);
  }

  /// Custom: kaç günde bir tekrarlansın
  void updateInterval(int days) {
    if (days < 1) return;
    state = state.copyWith(interval: days);
  }

  /// Stok miktarını güncelle
  void updateTotalStock(int stock) {
    if (stock < 0) return;
    state = state.copyWith(totalStock: stock);
  }

  Future<void> submit() async {
    final medicine = Medicine(
      id: generateUuid(),
      name: state.medicineName.trim().isEmpty ? 'New Medication' : state.medicineName.trim(),
      dosage: '${state.quantity} ${state.unit}',
      startDate: DateTime.now().toIso8601String().substring(0, 10),
      frequency: state.frequency.name,
      hungerStatus: HungerStatus.farketmez,
      reminderTimes: state.reminderTimes,
      // weekly için seçilen günler, boşsa [] döner
      daysOfWeek: state.frequency == MedicationFrequency.weekly
          ? (state.daysOfWeek.isNotEmpty ? state.daysOfWeek : null)
          : null,
      // custom için aralık
      interval: state.frequency == MedicationFrequency.custom ? state.interval : null,
      // stok
      totalStock: state.totalStock,
      currentStock: state.totalStock,
      createdAt: DateTime.now(),
    );

    await ref.read(medicineListProvider.notifier).addMedicine(medicine);
    reset();
  }
}
