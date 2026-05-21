// goldenTest is a Future-returning fire-and-forget — alchemist's API matches
// flutter_test's testWidgets pattern.
// ignore_for_file: discarded_futures

import 'package:alchemist/alchemist.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/features/collection/domain/entity/collection_entity.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/features/link/domain/entity/tag_entity.dart';
import 'package:linknote/features/reading_stats/domain/entity/reading_stats_entity.dart';
import 'package:linknote/features/reading_stats/presentation/provider/link_reading_stats_provider.dart';
import 'package:linknote/shared/widgets/ln/ln_collection_card.dart';
import 'package:linknote/shared/widgets/ln/ln_link_card.dart';

import '_golden_helpers.dart';

void main() {
  final link = LinkEntity(
    id: 'L1',
    url: 'https://flutter.dev/docs/cookbook',
    title: 'Flutter cookbook — async patterns and gotchas',
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
    collectionName: 'Flutter Resources',
    tags: const [
      TagEntity(id: 't1', name: 'flutter', color: '#1F6E53'),
      TagEntity(id: 't2', name: 'docs', color: '#A78BFA'),
    ],
    isFavorite: true,
  );

  // Pin id strings so toneForId hash maps to each tone deterministically.
  // forest=A, lilac=B, slate=C, amber=D mapping is not stable, but covering
  // 4 distinct ids exercises all 4 gradients across both themes.
  final collections = [
    CollectionEntity(
      id: 'col-a',
      name: 'Reading list',
      linkCount: 12,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    ),
    CollectionEntity(
      id: 'col-bb',
      name: 'Design references',
      linkCount: 7,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    ),
    CollectionEntity(
      id: 'col-ccc',
      name: 'Engineering notes',
      linkCount: 23,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    ),
    CollectionEntity(
      id: 'col-dddd',
      name: 'Recipes',
      linkCount: 4,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    ),
  ];

  group('Ln card goldens', () {
    goldenTest(
      'LnLinkCard — light/dark',
      fileName: 'ln_link_card',
      builder: () => GoldenTestGroup(
        columns: 1,
        children: [
          GoldenTestScenario(
            name: 'list / light',
            child: themedScenario(
              dark: false,
              width: 380,
              child: ProviderScope(
                overrides: [
                  linkReadingStatsProvider.overrideWith(
                    (ref, linkId) async => const ReadingStatsEntity(linkId: ''),
                  ),
                ],
                child: LnLinkCard(link: link),
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'list / dark',
            child: themedScenario(
              dark: true,
              width: 380,
              child: ProviderScope(
                overrides: [
                  linkReadingStatsProvider.overrideWith(
                    (ref, linkId) async => const ReadingStatsEntity(linkId: ''),
                  ),
                ],
                child: LnLinkCard(link: link),
              ),
            ),
          ),
        ],
      ),
    );

    goldenTest(
      'LnCollectionCard — 4 tones × light/dark',
      fileName: 'ln_collection_card',
      builder: () => GoldenTestGroup(
        columns: 4,
        children: [
          for (final c in collections)
            GoldenTestScenario(
              name: '${c.name} / light',
              child: themedScenario(
                dark: false,
                width: 180,
                child: LnCollectionCard(collection: c),
              ),
            ),
          for (final c in collections)
            GoldenTestScenario(
              name: '${c.name} / dark',
              child: themedScenario(
                dark: true,
                width: 180,
                child: LnCollectionCard(collection: c),
              ),
            ),
        ],
      ),
    );
  });
}
