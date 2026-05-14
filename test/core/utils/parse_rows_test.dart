import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/core/utils/parse_rows.dart';

void main() {
  group('parseRowsTolerant', () {
    test('returns all rows when every parse succeeds', () {
      final rows = <Map<String, dynamic>>[
        {'id': 'a', 'value': 1},
        {'id': 'b', 'value': 2},
      ];

      final items = parseRowsTolerant<String>(
        rows,
        (row) => '${row['id']}:${row['value']}',
        label: 'test',
      );

      expect(items, ['a:1', 'b:2']);
    });

    test(
      'skips rows whose parse throws and forwards each failure to onError',
      () {
        final errors = <Object>[];
        final rows = <Map<String, dynamic>>[
          {'id': 'good-1'},
          {'broken': true}, // missing 'id' → cast/null path throws
          {'id': 'good-2'},
        ];

        final items = parseRowsTolerant<String>(
          rows,
          (row) => row['id'] as String,
          label: 'test',
          onError: (e, _) => errors.add(e),
        );

        expect(items, ['good-1', 'good-2']);
        expect(errors, hasLength(1));
      },
    );

    test(
      'catches Dart Error subtypes (not just Exception) thrown by the mapper',
      () {
        final errors = <Object>[];
        final rows = <Map<String, dynamic>>[
          {'id': 'ok'},
          {'id': 'boom'},
        ];

        final items = parseRowsTolerant<String>(
          rows,
          (row) {
            if (row['id'] == 'boom') {
              // StateError is a Dart Error, NOT an Exception.
              throw StateError('mapper blew up');
            }
            return row['id'] as String;
          },
          label: 'test',
          onError: (e, _) => errors.add(e),
        );

        expect(items, ['ok']);
        expect(errors.single, isA<StateError>());
      },
    );

    test('returns empty list when input iterable is empty', () {
      final items = parseRowsTolerant<int>(
        const [],
        (row) => row['n'] as int,
        label: 'test',
      );

      expect(items, isEmpty);
    });
  });
}
