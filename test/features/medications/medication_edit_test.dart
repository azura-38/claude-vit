import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitacase/features/medications/domain/entities/medicine.dart';
import 'package:vitacase/features/medications/presentation/screens/models/medication_form_model.dart';
import 'package:vitacase/features/medications/presentation/screens/providers/medication_form_provider.dart';
import 'package:vitacase/shared/domain/enums/common_enums.dart';

void main() {
  group('Phase 11 Medication Create vs Edit Tests', () {
    test('Initial form state is empty with isEditing false', () {
      const form = MedicationFormModel();
      expect(form.editingId, isNull);
      expect(form.isEditing, isFalse);
      expect(form.medicineName, isEmpty);
    });

    test('initForEdit correctly populates form and sets isEditing to true', () {
      final existingMed = Medicine(
        id: 'med-999',
        name: 'Paracetamol',
        dosage: '500mg',
        startDate: '2026-01-01',
        frequency: 'daily',
        hungerStatus: HungerStatus.tok,
        reminderTimes: ['08:00', '20:00'],
        currentStock: 30,
        createdAt: DateTime.now(),
      );

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(medicationFormProvider.notifier);
      notifier.initForEdit(existingMed);

      final state = container.read(medicationFormProvider);
      expect(state.editingId, equals('med-999'));
      expect(state.isEditing, isTrue);
      expect(state.medicineName, equals('Paracetamol'));
      expect(state.quantity, equals(30));
      expect(state.reminderTimes, equals(['08:00', '20:00']));
    });

    test('Editing preserves medicine ID across copyWith updates', () {
      const form = MedicationFormModel(
        editingId: 'med-555',
        medicineName: 'Aspirin',
      );

      expect(form.isEditing, isTrue);
      expect(form.editingId, equals('med-555'));

      final updated = form.copyWith(medicineName: 'Aspirin Cardio');
      expect(updated.editingId, equals('med-555'));
      expect(updated.medicineName, equals('Aspirin Cardio'));
    });
  });
}
