import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/features/reading_stats/domain/entity/reading_stats_entity.dart';
import 'package:linknote/features/reading_stats/presentation/provider/link_reading_stats_provider.dart';
import 'package:linknote/features/reading_stats/presentation/widget/reading_stats_badge.dart';

void main() {
  group('ReadingStatsBadge compact mode — AC-7 three-state rendering', () {
    testWidgets(
      '(a) data state totalReads > 0: should render compact text matching regex, no 읽음 or 최근',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              linkReadingStatsProvider.overrideWith(
                (ref, linkId) async => ReadingStatsEntity(
                  linkId: 'x',
                  totalReads: 3,
                  lastReadAt: DateTime(2026, 5, 14),
                ),
              ),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: ReadingStatsBadge(linkId: 'x', compact: true),
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(Duration.zero);

        // Compact text must contain "3회"
        expect(find.textContaining('3회'), findsOneWidget);
        // Negative assertions: no full-size suffixes
        expect(find.textContaining('읽음'), findsNothing);
        expect(find.textContaining('최근'), findsNothing);
      },
    );

    testWidgets(
      '(b) data state totalReads == 0: should render SizedBox.shrink, no 회 text, no skeleton key',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              linkReadingStatsProvider.overrideWith(
                (ref, linkId) async => const ReadingStatsEntity(linkId: 'x'),
              ),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: ReadingStatsBadge(linkId: 'x', compact: true),
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(Duration.zero);

        expect(find.textContaining('회'), findsNothing);
        expect(
          find.byKey(const ValueKey('reading_stats_badge_skeleton')),
          findsNothing,
        );
      },
    );

    testWidgets(
      '(c) loading state: should render SizedBox.shrink, no 회 text, no skeleton key',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              linkReadingStatsProvider.overrideWith(
                (ref, linkId) => Completer<ReadingStatsEntity>().future,
              ),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: ReadingStatsBadge(linkId: 'x', compact: true),
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.textContaining('회'), findsNothing);
        expect(
          find.byKey(const ValueKey('reading_stats_badge_skeleton')),
          findsNothing,
        );
      },
    );
  });
}
