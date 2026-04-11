import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/shared/widgets/app_snack_bar.dart';

void main() {
  Widget buildApp({required Widget child}) {
    return MaterialApp(home: Scaffold(body: child));
  }

  group('AppSnackBar', () {
    testWidgets('should show success snackbar with green background', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildApp(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => AppSnackBar.show(
                context,
                message: 'Success!',
                type: SnackBarType.success,
              ),
              child: const Text('Trigger'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Trigger'));
      await tester.pumpAndSettle();

      expect(find.text('Success!'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });

    testWidgets('should show error snackbar with red background', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildApp(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => AppSnackBar.show(
                context,
                message: 'Error!',
                type: SnackBarType.error,
              ),
              child: const Text('Trigger'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Trigger'));
      await tester.pumpAndSettle();

      expect(find.text('Error!'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should show info snackbar with info icon', (tester) async {
      await tester.pumpWidget(
        buildApp(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => AppSnackBar.show(
                context,
                message: 'Info!',
              ),
              child: const Text('Trigger'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Trigger'));
      await tester.pumpAndSettle();

      expect(find.text('Info!'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('should show action button when actionLabel is provided', (
      tester,
    ) async {
      var actionPressed = false;

      await tester.pumpWidget(
        buildApp(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => AppSnackBar.show(
                context,
                message: 'With action',
                actionLabel: 'Undo',
                onAction: () => actionPressed = true,
              ),
              child: const Text('Trigger'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Trigger'));
      await tester.pumpAndSettle();

      expect(find.text('Undo'), findsOneWidget);
      await tester.tap(find.text('Undo'));
      expect(actionPressed, isTrue);
    });

    testWidgets('should default to info type when no type specified', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildApp(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => AppSnackBar.show(
                context,
                message: 'Default info',
              ),
              child: const Text('Trigger'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Trigger'));
      await tester.pumpAndSettle();

      expect(find.text('Default info'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });
  });
}
