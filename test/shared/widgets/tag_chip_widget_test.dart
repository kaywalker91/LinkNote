import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/shared/widgets/tag_chip_widget.dart';

void main() {
  group('TagChipWidget', () {
    testWidgets('should display label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: TagChipWidget(label: 'Flutter')),
        ),
      );

      expect(find.text('Flutter'), findsOneWidget);
    });

    testWidgets('should render as FilterChip when onDelete is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: TagChipWidget(label: 'Flutter')),
        ),
      );

      expect(find.byType(FilterChip), findsOneWidget);
      expect(find.byType(InputChip), findsNothing);
    });

    testWidgets('should render as InputChip when onDelete is provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TagChipWidget(label: 'Flutter', onDelete: () {}),
          ),
        ),
      );

      expect(find.byType(InputChip), findsOneWidget);
      expect(find.byType(FilterChip), findsNothing);
    });

    testWidgets('should call onTap when FilterChip is tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TagChipWidget(label: 'Flutter', onTap: () => tapped = true),
          ),
        ),
      );

      await tester.tap(find.byType(FilterChip));
      expect(tapped, isTrue);
    });

    testWidgets('should call onDelete when delete icon is tapped', (
      tester,
    ) async {
      var deleted = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TagChipWidget(
              label: 'Flutter',
              onDelete: () => deleted = true,
            ),
          ),
        ),
      );

      // InputChip renders a delete icon button — invoke callback directly
      final chip = tester.widget<InputChip>(find.byType(InputChip));
      chip.onDeleted!();
      expect(deleted, isTrue);
    });

    testWidgets('should show selected state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TagChipWidget(label: 'Flutter', isSelected: true),
          ),
        ),
      );

      final chip = tester.widget<FilterChip>(find.byType(FilterChip));
      expect(chip.selected, isTrue);
    });

    testWidgets('should show unselected state by default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: TagChipWidget(label: 'Flutter')),
        ),
      );

      final chip = tester.widget<FilterChip>(find.byType(FilterChip));
      expect(chip.selected, isFalse);
    });
  });
}
