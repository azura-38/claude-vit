import '../../../core/error/either.dart';
import '../../../core/error/failures.dart';
import '../../../core/error/error_mapper.dart';
import '../base_usecase.dart';
import '../../entities/appointment.dart';
import '../../repositories/appointment_repository.dart';

class GetAppointmentsUseCase implements UseCase<List<Appointment>, NoParams> {
  final AppointmentRepository repository;

  GetAppointmentsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Appointment>>> call(NoParams params) async {
    return ErrorMapper.runGuarded(() => repository.getAll());
  }
}
