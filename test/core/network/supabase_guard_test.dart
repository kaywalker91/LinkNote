import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/core/network/supabase_guard.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('guardSupabase', () {
    test('passes a success Result from the body straight through', () async {
      final result = await guardSupabase<int>(
        () async => success(42),
        label: 'test',
      );

      expect(result.isSuccess, isTrue);
      expect(result.data, 42);
    });

    test('passes a body-returned error Result through untouched', () async {
      // Validation branches (e.g. auth check) must not be remapped to server.
      final result = await guardSupabase<int>(
        () async => error(const Failure.auth(message: 'Session expired')),
        label: 'test',
      );

      expect(result.failure, isA<AuthFailure>());
      expect(result.failure?.message, 'Session expired');
    });

    test(
      'maps PostgrestException to Failure.server with its message',
      () async {
        final result = await guardSupabase<int>(
          () async =>
              throw const PostgrestException(message: 'boom', code: '500'),
          label: 'test',
        );

        expect(result.failure, isA<ServerFailure>());
        expect(result.failure?.message, 'boom');
      },
    );

    test('maps a generic Exception to Failure.unknown', () async {
      final result = await guardSupabase<int>(
        () async => throw Exception('network'),
        label: 'test',
      );

      expect(result.failure, isA<UnknownFailure>());
    });

    test('maps a Dart Error (not an Exception) to Failure.unknown', () async {
      // `on Object` must catch Error subtypes (e.g. cast _TypeError), not just
      // Exceptions, so they never escape to AsyncValue.error as raw Errors.
      final result = await guardSupabase<int>(
        () async => throw ArgumentError('bad'),
        label: 'test',
      );

      expect(result.failure, isA<UnknownFailure>());
    });
  });
}
