import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/features/reading_stats/domain/entity/reading_stats_entity.dart';
import 'package:linknote/features/reading_stats/presentation/provider/link_reading_stats_provider.dart';
import 'package:linknote/features/reading_stats/presentation/widget/reading_stats_badge.dart';

void main() {
  group('ReadingStatsBadge — AC-7 three-state rendering', () {
    testWidgets(
      '(a) loading state: should show keyed skeleton widget',
      (tester) async {
        // Arrange
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              linkReadingStatsProvider.overrideWith(
                (ref, linkId) => Completer<ReadingStatsEntity>().future,
              ),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: ReadingStatsBadge(linkId: 'x'),
              ),
            ),
          ),
        );
        await tester.pump();

        // Assert — SOLE acceptable finder for loading branch
        expect(
          find.byKey(const ValueKey('reading_stats_badge_skeleton')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '(b) data state: should show totalReads and lastReadAt text',
      (tester) async {
        // Arrange
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              linkReadingStatsProvider.overrideWith(
                (ref, linkId) async => ReadingStatsEntity(
                  linkId: 'x',
                  totalReads: 5,
                  lastReadAt: DateTime(2026, 5, 10),
                ),
              ),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: ReadingStatsBadge(linkId: 'x'),
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(Duration.zero);

        // Assert
        expect(find.textContaining('5회 읽음'), findsOneWidget);
        expect(find.textContaining('최근'), findsOneWidget);
      },
    );

    testWidgets(
      '(c) silent-fallback: should show 아직 읽지 않음 when stats are empty',
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
                body: ReadingStatsBadge(linkId: 'x'),
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(Duration.zero);

        expect(find.text('아직 읽지 않음'), findsOneWidget);
      },
    );
  });
}
