// goldenTest is a Future-returning fire-and-forget — alchemist's API matches
// flutter_test's testWidgets pattern.
// ignore_for_file: discarded_futures

import 'package:alchemist/alchemist.dart';
import 'package:flutter/widgets.dart';
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

  // Pill variants: the base `link` is private + unlocked, so neither pill
  // renders. These cover the Globe (public) and Lock (lockedAt) render paths.
  final publicLink = link.copyWith(
    collectionVisibility: CollectionVisibility.public,
  );
  final lockedLink = link.copyWith(
    collectionLockedAt: DateTime.utc(2026),
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

    Widget pillScenario({required bool dark, required LinkEntity card}) =>
        themedScenario(
          dark: dark,
          width: 380,
          child: ProviderScope(
            overrides: [
              linkReadingStatsProvider.overrideWith(
                (ref, linkId) async => const ReadingStatsEntity(linkId: ''),
              ),
            ],
            child: LnLinkCard(link: card),
          ),
        );

    goldenTest(
      'LnLinkCard pills — public/locked × light/dark',
      fileName: 'ln_link_card_pills',
      builder: () => GoldenTestGroup(
        columns: 1,
        children: [
          GoldenTestScenario(
            name: 'public (Globe) / light',
            child: pillScenario(dark: false, card: publicLink),
          ),
          GoldenTestScenario(
            name: 'public (Globe) / dark',
            child: pillScenario(dark: true, card: publicLink),
          ),
          GoldenTestScenario(
            name: 'locked (Lock) / light',
            child: pillScenario(dark: false, card: lockedLink),
          ),
          GoldenTestScenario(
            name: 'locked (Lock) / dark',
            child: pillScenario(dark: true, card: lockedLink),
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

    // Pill variants: base `collections` are private + unlocked (no pill).
    // These cover the Globe (public) and Lock (lockedAt) render paths.
    final publicCollection = collections.first.copyWith(
      name: 'Public picks',
      visibility: CollectionVisibility.public,
    );
    final lockedCollection = collections.first.copyWith(
      name: 'Locked vault',
      lockedAt: DateTime.utc(2026),
    );

    Widget collectionPillScenario({
      required bool dark,
      required CollectionEntity card,
    }) => themedScenario(
      dark: dark,
      width: 180,
      child: LnCollectionCard(collection: card),
    );

    goldenTest(
      'LnCollectionCard pills — public/locked × light/dark',
      fileName: 'ln_collection_card_pills',
      builder: () => GoldenTestGroup(
        columns: 2,
        children: [
          GoldenTestScenario(
            name: 'public (Globe) / light',
            child: collectionPillScenario(dark: false, card: publicCollection),
          ),
          GoldenTestScenario(
            name: 'public (Globe) / dark',
            child: collectionPillScenario(dark: true, card: publicCollection),
          ),
          GoldenTestScenario(
            name: 'locked (Lock) / light',
            child: collectionPillScenario(dark: false, card: lockedCollection),
          ),
          GoldenTestScenario(
            name: 'locked (Lock) / dark',
            child: collectionPillScenario(dark: true, card: lockedCollection),
          ),
        ],
      ),
    );
  });
}
