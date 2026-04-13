import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';

void main() {
  group('Result', () {
    group('success', () {
      test('should have data and no failure', () {
        final result = success(42);

        expect(result.data, equals(42));
        expect(result.failure, isNull);
        expect(result.isSuccess, isTrue);
        expect(result.isFailure, isFalse);
      });
    });

    group('error', () {
      test('should have failure and no data', () {
        const failure = Failure.server(message: 'Error');
        final result = error<int>(failure);

        expect(result.data, isNull);
        expect(result.failure, equals(failure));
        expect(result.isSuccess, isFalse);
        expect(result.isFailure, isTrue);
      });
    });

    group('when', () {
      test('should call success callback on success result', () {
        final result = success(42);

        final value = result.when(
          success: (data) => 'value: $data',
          error: (failure) => 'error',
        );

        expect(value, equals('value: 42'));
      });

      test('should call error callback on error result', () {
        const failure = Failure.network(message: 'No connection');
        final result = error<int>(failure);

        final value = result.when(
          success: (data) => 'value: $data',
          error: (f) => 'error: $f',
        );

        expect(value, startsWith('error:'));
      });

      test(
        'should pass nullable data in success callback for Result<void>',
        () {
          final result = success<void>(null);

          final value = result.when(
            success: (data) => 'ok',
            error: (failure) => 'error',
          );

          expect(value, equals('ok'));
        },
      );
    });
  });
}
