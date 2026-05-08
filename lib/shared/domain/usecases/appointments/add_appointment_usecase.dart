import '../../../../core/error/either.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/error_mapper.dart';
import '../base_usecase.dart';
import '../../../../features/appointments/domain/entities/appointment.dart';
import '../../repositories/appointment_repository.dart';

class AddAppointmentUseCase implements UseCase<void, Appointment> {
  final AppointmentRepository repository;

  AddAppointmentUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(Appointment appointment) async {
    return ErrorMapper.runGuarded(() => repository.save(appointment));
  }
}
