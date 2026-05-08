import '../../../../core/error/either.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/error_mapper.dart';
import '../base_usecase.dart';
import '../../../../features/medications/domain/entities/medicine.dart';
import '../../repositories/medicine_repository.dart';

class AddMedicineUseCase implements UseCase<void, Medicine> {
  final MedicineRepository repository;

  AddMedicineUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(Medicine medicine) async {
    return ErrorMapper.runGuarded(() => repository.save(medicine));
  }
}
