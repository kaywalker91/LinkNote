import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/shared/widgets/ln/ln_segmented.dart';

void main() {
  group('LnSegmented', () {
    testWidgets('renders all labels', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LnSegmented(
              labels: const ['전체', '★ 즐겨찾기', '안 읽음'],
              selectedIndex: 0,
              onChanged: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('전체'), findsOneWidget);
      expect(find.text('★ 즐겨찾기'), findsOneWidget);
      expect(find.text('안 읽음'), findsOneWidget);
    });

    testWidgets('onChanged fires with tapped index', (tester) async {
      var lastIndex = -1;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LnSegmented(
              labels: const ['A', 'B'],
              selectedIndex: 0,
              onChanged: (i) => lastIndex = i,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('B'));
      await tester.pumpAndSettle();
      expect(lastIndex, 1);
    });
  });
}
