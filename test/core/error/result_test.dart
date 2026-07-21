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
  });
}
