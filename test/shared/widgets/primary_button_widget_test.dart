import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/shared/widgets/primary_button_widget.dart';

void main() {
  group('PrimaryButtonWidget', () {
    testWidgets('should display label text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButtonWidget(label: 'Save', onPressed: () {}),
          ),
        ),
      );

      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('should call onPressed when tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButtonWidget(
              label: 'Save',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(FilledButton));
      expect(tapped, isTrue);
    });

    testWidgets('should show CircularProgressIndicator when isLoading is true',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PrimaryButtonWidget(
              label: 'Save',
              onPressed: null,
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Save'), findsNothing);
    });

    testWidgets('should disable button when isLoading is true', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButtonWidget(
              label: 'Save',
              onPressed: () => tapped = true,
              isLoading: true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(FilledButton));
      expect(tapped, isFalse);
    });

    testWidgets('should disable button when onPressed is null',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PrimaryButtonWidget(label: 'Save', onPressed: null),
          ),
        ),
      );

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('should show icon when icon is provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButtonWidget(
              label: 'Add',
              onPressed: () {},
              icon: Icons.add,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);
    });

    testWidgets('should be full width by default', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButtonWidget(label: 'Save', onPressed: () {}),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, double.infinity);
    });

    testWidgets('should not be full width when isFullWidth is false',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButtonWidget(
              label: 'Save',
              onPressed: () {},
              isFullWidth: false,
            ),
          ),
        ),
      );

      expect(find.byType(SizedBox), findsNothing);
    });
  });
}
