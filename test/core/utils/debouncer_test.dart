import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/core/utils/debouncer.dart';

void main() {
  group('Debouncer', () {
    test('should execute action after duration', () async {
      final debouncer = Debouncer(
        duration: const Duration(milliseconds: 50),
      );
      var called = false;

      debouncer.call(() => called = true);

      expect(called, isFalse);
      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(called, isTrue);

      debouncer.dispose();
    });

    test('should cancel previous action when called again', () async {
      final debouncer = Debouncer(
        duration: const Duration(milliseconds: 50),
      );
      var callCount = 0;

      debouncer.call(() => callCount++);
      await Future<void>.delayed(const Duration(milliseconds: 30));
      debouncer.call(() => callCount++);
      await Future<void>.delayed(const Duration(milliseconds: 80));

      expect(callCount, equals(1));

      debouncer.dispose();
    });

    test('should not execute action after dispose', () async {
      final debouncer = Debouncer(
        duration: const Duration(milliseconds: 50),
      );
      var called = false;

      debouncer
        ..call(() => called = true)
        ..dispose();
      await Future<void>.delayed(const Duration(milliseconds: 80));

      expect(called, isFalse);
    });

    test('should use default duration from AppConstants', () {
      final debouncer = Debouncer();
      expect(debouncer.duration, const Duration(milliseconds: 300));
      debouncer.dispose();
    });
  });
}
