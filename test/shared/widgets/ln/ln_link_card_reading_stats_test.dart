import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/features/reading_stats/domain/entity/reading_stats_entity.dart';
import 'package:linknote/features/reading_stats/presentation/provider/link_reading_stats_provider.dart';
import 'package:linknote/shared/widgets/ln/ln_link_card.dart';

void main() {
  final tLink = LinkEntity(
    id: 'x',
    url: 'https://flutter.dev',
    title: 'Flutter',
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );

  group('LnLinkCard integration — AC-8 mini badge visibility', () {
    testWidgets(
      'totalReads > 0: mini badge compact text findable, no 읽음 text',
      (tester) async {
        final now = DateTime.now();
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              linkReadingStatsProvider.overrideWith(
                (ref, linkId) async => ReadingStatsEntity(
                  linkId: 'x',
                  totalReads: 2,
                  lastReadAt: now,
                ),
              ),
            ],
            child: MaterialApp(
              home: Scaffold(body: LnLinkCard(link: tLink)),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(Duration.zero);

        // compact text matching regex ^\d+회( · .+)?$
        expect(find.textContaining('2회'), findsOneWidget);
        // wording-drift safety net
        expect(find.textContaining('읽음'), findsNothing);
      },
    );

    testWidgets(
      'totalReads == 0: mini badge absent, existing card fields still render',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              linkReadingStatsProvider.overrideWith(
                (ref, linkId) async => const ReadingStatsEntity(linkId: 'x'),
              ),
            ],
            child: MaterialApp(
              home: Scaffold(body: LnLinkCard(link: tLink)),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(Duration.zero);

        // no reading count shown
        expect(find.textContaining('회'), findsNothing);
        // existing card fields unaffected
        expect(find.text('Flutter'), findsOneWidget);
        expect(find.text('flutter.dev'), findsOneWidget);
      },
    );
  });
}
