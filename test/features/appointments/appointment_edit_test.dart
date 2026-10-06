import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitacase/features/appointments/domain/entities/appointment.dart';
import 'package:vitacase/features/appointments/presentation/screens/models/appointment_form_model.dart';
import 'package:vitacase/features/appointments/presentation/screens/providers/appointment_form_provider.dart';
import 'package:vitacase/shared/domain/enums/appointment_status.dart';

void main() {
  group('Phase 11 Appointment Create vs Edit Tests', () {
    test('Initial form state is empty with isEditing false', () {
      final form = AppointmentFormModel(date: DateTime(2026, 10, 15));
      expect(form.editingId, isNull);
      expect(form.isEditing, isFalse);
      expect(form.title, isEmpty);
      expect(form.location, isEmpty);
    });

    test('initForEdit correctly populates form and sets isEditing to true', () {
      final existingApt = Appointment(
        id: 'apt-12345',
        title: 'Checkup',
        department: 'Cardiology',
        hospital: 'City Hospital',
        doctor: 'Dr. House',
        date: '2026-10-15',
        time: '14:30',
        status: AppointmentStatus.upcoming,
        notes: 'Bring previous test results',
        createdAt: DateTime.now(),
      );

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(appointmentFormProvider.notifier);
      notifier.initForEdit(existingApt);

      final state = container.read(appointmentFormProvider);
      expect(state.editingId, equals('apt-12345'));
      expect(state.isEditing, isTrue);
      expect(state.title, equals('Checkup'));
      expect(state.location, equals('City Hospital'));
      expect(state.notes, equals('Bring previous test results'));
      expect(state.date.year, equals(2026));
      expect(state.date.month, equals(10));
      expect(state.date.day, equals(15));
      expect(state.date.hour, equals(14));
      expect(state.date.minute, equals(30));
    });

    test('Editing preserves record ID and does not generate a new one', () {
      final form = AppointmentFormModel(
        editingId: 'apt-777',
        title: 'Dermatology Follow-up',
        location: 'Central Clinic',
        date: DateTime(2026, 11, 1),
      );

      expect(form.isEditing, isTrue);
      expect(form.editingId, equals('apt-777'));

      final updated = form.copyWith(location: 'New Central Clinic');
      expect(updated.editingId, equals('apt-777'));
      expect(updated.location, equals('New Central Clinic'));
    });
  });
}
