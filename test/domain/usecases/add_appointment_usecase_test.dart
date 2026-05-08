import 'package:flutter_test/flutter_test.dart';
import 'package:vitacase/features/appointments/domain/entities/appointment.dart';
import 'package:vitacase/shared/domain/enums/common_enums.dart';
import 'package:vitacase/shared/domain/enums/appointment_status.dart';
import 'package:vitacase/shared/domain/repositories/appointment_repository.dart';
import 'package:vitacase/shared/domain/usecases/appointments/add_appointment_usecase.dart';

class MockAppointmentRepository implements AppointmentRepository {
  bool didThrowError = false;
  List<Appointment> savedAppointments = [];

  @override
  Future<void> save(Appointment appointment) async {
    if (didThrowError) {
      throw Exception('Database Error Simulated');
    }
    savedAppointments.add(appointment);
  }

  @override
  Future<List<Appointment>> getAll() async => savedAppointments;

  @override
  Future<Appointment?> getById(String id) async => null;
  
  @override
  Future<void> delete(String id) async {}

  @override
  Future<Appointment?> getNextUpcoming() async => null;

  @override
  Future<void> update(Appointment appointment) async {}

  @override
  Future<void> updateStatus(String id, AppointmentStatus status) async {}
}

void main() {
  late MockAppointmentRepository mockRepo;
  late AddAppointmentUseCase usecase;

  setUp(() {
    mockRepo = MockAppointmentRepository();
    usecase = AddAppointmentUseCase(mockRepo);
  });

  group('AddAppointmentUseCase', () {
    test('should add appointment successfully', () async {
      final appointment = Appointment(
        id: '1',
        doctor: 'Dr. John',
        department: 'Cardiology',
        hospital: 'City Hospital',
        date: '2027-01-01',
        time: '10:00',
        status: AppointmentStatus.upcoming,
        importance: ImportanceLevel.high,
        createdAt: DateTime.now(),
      );

      final result = await usecase(appointment);

      expect(result.isRight, true);
      expect(mockRepo.savedAppointments.length, 1);
      expect(mockRepo.savedAppointments.first.id, '1');
    });

    test('should return Failure when repository throws an error', () async {
      final appointment = Appointment(
        id: '1',
        doctor: 'Dr. John',
        department: 'Cardiology',
        hospital: 'City Hospital',
        date: '2027-01-01',
        time: '10:00',
        status: AppointmentStatus.upcoming,
        importance: ImportanceLevel.high,
        createdAt: DateTime.now(),
      );

      // Simulate a DB crash
      mockRepo.didThrowError = true;

      final result = await usecase(appointment);

      expect(result.isLeft, true);
      result.fold(
        (failure) {
          expect(failure.message.isNotEmpty, true);
          expect(failure.toString(), contains('Database Error Simulated'));
        },
        (r) => fail('Should not succeed'),
      );
    });
  });
}
