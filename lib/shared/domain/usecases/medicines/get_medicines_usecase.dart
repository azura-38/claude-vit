import '../../../../core/error/either.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/error_mapper.dart';
import '../base_usecase.dart';
import '../../../../features/medications/domain/entities/medicine.dart';
import '../../repositories/medicine_repository.dart';

class GetMedicinesUseCase implements UseCase<List<Medicine>, NoParams> {
  final MedicineRepository repository;

  GetMedicinesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Medicine>>> call(NoParams params) async {
    return ErrorMapper.runGuarded(() => repository.getAll());
  }
}
