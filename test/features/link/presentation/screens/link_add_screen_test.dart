import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/features/link/presentation/screens/link_add_screen.dart';

void main() {
  Widget buildSubject({String? initialUrl}) {
    return ProviderScope(
      child: MaterialApp(
        home: LinkAddScreen(initialUrl: initialUrl),
      ),
    );
  }

  /// Scrolls until the Save Link button is visible, then taps it.
  Future<void> tapSaveButton(WidgetTester tester) async {
    await tester.ensureVisible(find.text('저장'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();
  }

  group('LinkAddScreen', () {
    testWidgets('should render URL and Title text fields', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('URL *'), findsOneWidget);
      expect(find.text('제목 *'), findsOneWidget);
    });

    testWidgets('should show error when submitting with empty URL and title', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Act
      await tapSaveButton(tester);

      // Assert
      expect(find.text('URL and title are required'), findsOneWidget);
    });

    testWidgets('should show error when URL is empty but title is filled', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Act
      await tester.enterText(
        find.widgetWithText(TextField, '제목 *'),
        'My Link',
      );
      await tester.pumpAndSettle();
      await tapSaveButton(tester);

      // Assert
      expect(find.text('URL and title are required'), findsOneWidget);
    });

    testWidgets('should show error when title is empty but URL is filled', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Act
      await tester.enterText(
        find.widgetWithText(TextField, 'URL *'),
        'https://example.com',
      );
      await tester.pumpAndSettle();
      await tapSaveButton(tester);

      // Assert
      expect(find.text('URL and title are required'), findsOneWidget);
    });

    testWidgets('should render form fields for description, notes, tags', (
      tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('설명'), findsOneWidget);
      expect(find.text('메모'), findsOneWidget);
    });

    testWidgets(
      'should seed URL field from initialUrl (share-intent prefill)',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          buildSubject(initialUrl: 'https://example.com/shared'),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('https://example.com/shared'), findsOneWidget);
      },
    );

    testWidgets(
      'should leave URL field empty when initialUrl is null',
      (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        // Assert — placeholder hint remains visible, URL text does not.
        final urlField = tester.widget<TextField>(
          find.widgetWithText(TextField, 'URL *'),
        );
        expect(urlField.controller?.text ?? '', isEmpty);
      },
    );
  });
}
