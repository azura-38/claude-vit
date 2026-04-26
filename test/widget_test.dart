import 'package:flutter_test/flutter_test.dart';
import 'package:vitacase/core/error/either.dart';
import 'package:vitacase/core/error/failures.dart';

void main() {
  group('Either', () {
    test('Right should return isRight = true', () {
      const result = Right<Failure, int>(42);
      expect(result.isRight, true);
      expect(result.isLeft, false);
    });

    test('Left should return isLeft = true', () {
      const result = Left<Failure, int>(UnknownFailure('test'));
      expect(result.isLeft, true);
      expect(result.isRight, false);
    });

    test('fold on Right executes right branch', () {
      const result = Right<Failure, String>('success');
      final output = result.fold(
        (l) => 'failure',
        (r) => r,
      );
      expect(output, 'success');
    });

    test('fold on Left executes left branch', () {
      const result = Left<Failure, String>(DatabaseFailure('db crashed'));
      final output = result.fold(
        (l) => l.message,
        (r) => r,
      );
      expect(output, 'db crashed');
    });
  });

  group('Failures', () {
    test('DatabaseFailure stores message', () {
      const f = DatabaseFailure('connection lost');
      expect(f.message, 'connection lost');
      expect(f.toString(), 'connection lost');
    });

    test('CryptoFailure stores message', () {
      const f = CryptoFailure('MAC check failed');
      expect(f.message, 'MAC check failed');
    });

    test('ValidationFailure stores message', () {
      const f = ValidationFailure('invalid format');
      expect(f.message, 'invalid format');
    });
  });
}
