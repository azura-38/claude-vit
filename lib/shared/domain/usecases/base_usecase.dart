import '../../../core/error/failures.dart';
import '../../../core/error/either.dart';

abstract class UseCase<ResultType, Params> {
  Future<Either<Failure, ResultType>> call(Params params);
}

class NoParams {}
