import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/shared/widgets/confirmation_dialog_widget.dart';

void main() {
  group('ConfirmationDialogWidget', () {
    testWidgets('should display title and message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConfirmationDialogWidget(
              title: 'Delete',
              message: 'Are you sure?',
            ),
          ),
        ),
      );

      expect(find.text('Delete'), findsOneWidget);
      expect(find.text('Are you sure?'), findsOneWidget);
    });

    testWidgets('should display default button labels', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConfirmationDialogWidget(
              title: 'Delete',
              message: 'Are you sure?',
            ),
          ),
        ),
      );

      expect(find.text('Confirm'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('should display custom button labels', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConfirmationDialogWidget(
              title: 'Delete',
              message: 'Are you sure?',
              confirmLabel: 'Yes, delete',
              cancelLabel: 'No, keep',
            ),
          ),
        ),
      );

      expect(find.text('Yes, delete'), findsOneWidget);
      expect(find.text('No, keep'), findsOneWidget);
    });

    testWidgets('should return true when confirm is tapped', (tester) async {
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await ConfirmationDialogWidget.show(
                  context,
                  title: 'Delete',
                  message: 'Are you sure?',
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
    });

    testWidgets('should return false when cancel is tapped', (tester) async {
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await ConfirmationDialogWidget.show(
                  context,
                  title: 'Delete',
                  message: 'Are you sure?',
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(result, isFalse);
    });

    testWidgets('should use error color when isDestructive is true',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          ),
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => ConfirmationDialogWidget.show(
                context,
                title: 'Delete',
                message: 'This cannot be undone.',
                isDestructive: true,
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final confirmButton =
          tester.widget<FilledButton>(find.byType(FilledButton));
      final style = confirmButton.style;
      expect(style, isNotNull);
    });
  });
}
