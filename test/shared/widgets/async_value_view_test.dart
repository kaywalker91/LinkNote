import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/shared/widgets/async_value_view.dart';

void main() {
  group('AsyncValueView', () {
    testWidgets('should show loading widget when state is loading', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AsyncValueView<String>(
              value: const AsyncLoading(),
              loading: const CircularProgressIndicator(),
              dataBuilder: (data) => Text(data),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show data widget when state is data', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AsyncValueView<String>(
              value: const AsyncData('Hello'),
              loading: const CircularProgressIndicator(),
              dataBuilder: (data) => Text(data),
            ),
          ),
        ),
      );

      expect(find.text('Hello'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('should show default ErrorStateWidget when state is error', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AsyncValueView<String>(
              value: AsyncError(Exception('fail'), StackTrace.current),
              loading: const CircularProgressIndicator(),
              dataBuilder: (data) => Text(data),
            ),
          ),
        ),
      );

      expect(find.text('오류가 발생했습니다'), findsOneWidget);
    });

    testWidgets('should show retry button when onRetry is provided', (
      tester,
    ) async {
      var retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AsyncValueView<String>(
              value: AsyncError(Exception('fail'), StackTrace.current),
              loading: const CircularProgressIndicator(),
              dataBuilder: (data) => Text(data),
              onRetry: () => retried = true,
            ),
          ),
        ),
      );

      expect(find.text('다시 시도'), findsOneWidget);
      await tester.tap(find.text('다시 시도'));
      expect(retried, isTrue);
    });

    testWidgets('should use custom errorBuilder when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AsyncValueView<String>(
              value: AsyncError(Exception('custom'), StackTrace.current),
              loading: const CircularProgressIndicator(),
              dataBuilder: (data) => Text(data),
              errorBuilder: (error, stack) => Text('Custom: $error'),
            ),
          ),
        ),
      );

      expect(find.textContaining('Custom:'), findsOneWidget);
      expect(find.text('오류가 발생했습니다'), findsNothing);
    });
  });
}
