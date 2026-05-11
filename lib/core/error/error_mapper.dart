import 'dart:async';
import 'package:sembast/sembast_io.dart';
import 'failures.dart';
import 'either.dart';

class ErrorMapper {
  static Future<Either<Failure, T>> runGuarded<T>(
    Future<T> Function() block, {
    Failure Function(Object error)? customMapper,
  }) async {
    try {
      final result = await block();
      return Right(result);
    } catch (e) {
      if (customMapper != null) {
        return Left(customMapper(e));
      }
      return Left(_mapExceptionToFailure(e));
    }
  }

  static Failure _mapExceptionToFailure(Object exception) {
    if (exception is DatabaseException) {
      return DatabaseFailure(exception.message);
    }
    // Note: Sembast sometimes throws normal exceptions for missing Codec etc.
    final exceptionStr = exception.toString().toLowerCase();

    if (exceptionStr.contains('crypto') || exceptionStr.contains('mac check')) {
      return const CryptoFailure('Failed to encrypt or decrypt data');
    }

    if (exceptionStr.contains('format') || exceptionStr.contains('type')) {
      return const ValidationFailure('Validation or formatting error occurred');
    }

    return UnknownFailure(exception.toString());
  }
}
