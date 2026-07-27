import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/shared/widgets/ln/ln_top_bar.dart';

void main() {
  group('LnTopBar', () {
    Future<void> pumpBar(WidgetTester tester, LnTopBar bar) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(appBar: bar, body: const SizedBox()),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('keeps the standard row when large and it has content', (
      tester,
    ) async {
      const bar = LnTopBar(
        large: true,
        displayTitle: '컬렉션',
        displaySubtitle: '컬렉션 4개',
        actions: [Icon(Icons.notifications_none_rounded)],
      );
      expect(bar.preferredSize.height, 56 + 92);

      await pumpBar(tester, bar);

      expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);
      // Display title sits below the 56px standard row.
      expect(
        tester.getTopLeft(find.text('컬렉션')).dy,
        greaterThanOrEqualTo(56),
      );
    });

    testWidgets('collapses the empty standard row on a large bar', (
      tester,
    ) async {
      const bar = LnTopBar(
        large: true,
        displayTitle: '컬렉션',
        displaySubtitle: '컬렉션 4개',
      );
      // 16px of breathing room replaces the empty 56px band.
      expect(bar.preferredSize.height, 16 + 92);

      await pumpBar(tester, bar);

      expect(find.text('컬렉션'), findsOneWidget);
      expect(tester.getTopLeft(find.text('컬렉션')).dy, lessThan(56));
    });

    testWidgets('leaves the standard (non-large) bar untouched', (
      tester,
    ) async {
      const bar = LnTopBar(title: '내 서랍');
      expect(bar.preferredSize.height, 56);

      await pumpBar(tester, bar);

      expect(find.text('내 서랍'), findsOneWidget);
      expect(tester.getSize(find.byType(LnTopBar)).height, 56);
    });

    testWidgets('keeps its height when a non-large bar has no content', (
      tester,
    ) async {
      const bar = LnTopBar();
      expect(bar.preferredSize.height, 56);

      await pumpBar(tester, bar);

      expect(tester.getSize(find.byType(LnTopBar)).height, 56);
    });
  });
}
