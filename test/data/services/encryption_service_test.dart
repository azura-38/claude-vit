import 'package:flutter_test/flutter_test.dart';
import 'package:vitacase/core/error/error_mapper.dart';
import 'package:vitacase/core/error/failures.dart';

void main() {
  group('ErrorMapper', () {
    test('should return Right on success', () async {
      final result = await ErrorMapper.runGuarded(() async => 42);

      expect(result.isRight, true);
      result.fold(
        (l) => fail('Should not be Left'),
        (r) => expect(r, 42),
      );
    });

    test('should return Left with UnknownFailure on generic exception', () async {
      final result = await ErrorMapper.runGuarded<int>(() async {
        throw Exception('Something went wrong');
      });

      expect(result.isLeft, true);
      result.fold(
        (l) {
          expect(l, isA<UnknownFailure>());
          expect(l.message, contains('Something went wrong'));
        },
        (r) => fail('Should not be Right'),
      );
    });

    test('should return Left with CryptoFailure on crypto-related error', () async {
      final result = await ErrorMapper.runGuarded<String>(() async {
        throw Exception('mac check in CCM failed');
      });

      expect(result.isLeft, true);
      result.fold(
        (l) => expect(l, isA<CryptoFailure>()),
        (r) => fail('Should not be Right'),
      );
    });

    test('should use customMapper when provided', () async {
      final result = await ErrorMapper.runGuarded<String>(
        () async {
          throw FormatException('bad input');
        },
        customMapper: (e) => const ValidationFailure('Custom: bad input'),
      );

      expect(result.isLeft, true);
      result.fold(
        (l) {
          expect(l, isA<ValidationFailure>());
          expect(l.message, 'Custom: bad input');
        },
        (r) => fail('Should not be Right'),
      );
    });
  });
}
