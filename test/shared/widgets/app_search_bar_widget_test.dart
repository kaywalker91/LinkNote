import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/shared/widgets/app_search_bar_widget.dart';

void main() {
  group('AppSearchBarWidget', () {
    late TextEditingController controller;

    setUp(() {
      controller = TextEditingController();
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('should display hint text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppSearchBarWidget(
              controller: controller,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Search links, notes, tags'), findsOneWidget);
    });

    testWidgets('should display custom hint text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppSearchBarWidget(
              controller: controller,
              onChanged: (_) {},
              hintText: 'Custom hint',
            ),
          ),
        ),
      );

      expect(find.text('Custom hint'), findsOneWidget);
    });

    testWidgets('should show search icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppSearchBarWidget(
              controller: controller,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('should call onChanged with debounce when text is entered', (
      tester,
    ) async {
      String? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppSearchBarWidget(
              controller: controller,
              onChanged: (value) => changedValue = value,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'flutter');
      // Wait for debounce (300ms)
      await tester.pump(const Duration(milliseconds: 350));

      expect(changedValue, 'flutter');
    });

    testWidgets('should show clear button when text is not empty', (
      tester,
    ) async {
      controller.text = 'flutter';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppSearchBarWidget(
              controller: controller,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('should hide clear button when text is empty', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppSearchBarWidget(
              controller: controller,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.clear), findsNothing);
    });

    testWidgets('should clear text and call onClear when clear button tapped', (
      tester,
    ) async {
      var cleared = false;
      controller.text = 'flutter';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppSearchBarWidget(
              controller: controller,
              onChanged: (_) {},
              onClear: () => cleared = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      expect(controller.text, isEmpty);
      expect(cleared, isTrue);
    });
  });
}
