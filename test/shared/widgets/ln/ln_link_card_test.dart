import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/features/collection/domain/entity/collection_entity.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/features/link/domain/entity/tag_entity.dart';
import 'package:linknote/features/reading_stats/domain/entity/reading_stats_entity.dart';
import 'package:linknote/features/reading_stats/presentation/provider/link_reading_stats_provider.dart';
import 'package:linknote/shared/widgets/ln/ln_link_card.dart';

void main() {
  group('LnLinkCard (list variant)', () {
    final link = LinkEntity(
      id: '1',
      url: 'https://flutter.dev/docs',
      title: 'Flutter docs',
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
      tags: const [
        TagEntity(id: 't1', name: 'flutter', color: '#1F6E53'),
      ],
    );

    // Provides zero-stats so mini badge stays un-rendered (AC-9).
    Widget wrapWithZeroStats(Widget child) {
      return ProviderScope(
        overrides: [
          linkReadingStatsProvider.overrideWith(
            (ref, linkId) async => const ReadingStatsEntity(linkId: ''),
          ),
        ],
        child: MaterialApp(home: Scaffold(body: child)),
      );
    }

    testWidgets('renders title, host, and tag', (tester) async {
      await tester.pumpWidget(wrapWithZeroStats(LnLinkCard(link: link)));
      await tester.pumpAndSettle();

      expect(find.text('Flutter docs'), findsOneWidget);
      expect(find.text('flutter.dev'), findsOneWidget);
      expect(find.textContaining('flutter'), findsWidgets);
    });

    testWidgets('onTap is invoked', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        wrapWithZeroStats(LnLinkCard(link: link, onTap: () => tapped = true)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(LnLinkCard));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });

    testWidgets('favoriteBusy shows progress indicator', (tester) async {
      await tester.pumpWidget(
        wrapWithZeroStats(LnLinkCard(link: link, favoriteBusy: true)),
      );
      // CircularProgressIndicator animates forever; use pump(), not pumpAndSettle.
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('LnLinkCard visibility pills', () {
    Widget wrapWithZeroStats(Widget child) {
      return ProviderScope(
        overrides: [
          linkReadingStatsProvider.overrideWith(
            (ref, linkId) async => const ReadingStatsEntity(linkId: ''),
          ),
        ],
        child: MaterialApp(home: Scaffold(body: child)),
      );
    }

    LinkEntity linkWith({
      required CollectionVisibility visibility,
      DateTime? lockedAt,
      String? collectionName = 'Dev',
    }) {
      return LinkEntity(
        id: '1',
        url: 'https://flutter.dev/docs',
        title: 'Flutter docs',
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
        collectionName: collectionName,
        collectionVisibility: visibility,
        collectionLockedAt: lockedAt,
      );
    }

    testWidgets('public collection renders a Globe pill', (tester) async {
      await tester.pumpWidget(
        wrapWithZeroStats(
          LnLinkCard(link: linkWith(visibility: CollectionVisibility.public)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.public), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsNothing);
    });

    testWidgets('locked collection renders a Lock pill', (tester) async {
      await tester.pumpWidget(
        wrapWithZeroStats(
          LnLinkCard(
            link: linkWith(
              visibility: CollectionVisibility.private,
              lockedAt: DateTime(2026, 5),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      expect(find.byIcon(Icons.public), findsNothing);
    });

    testWidgets('private unlocked collection renders no pill', (tester) async {
      await tester.pumpWidget(
        wrapWithZeroStats(
          LnLinkCard(link: linkWith(visibility: CollectionVisibility.private)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.public), findsNothing);
      expect(find.byIcon(Icons.lock_outline), findsNothing);
    });
  });
}
