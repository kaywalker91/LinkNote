import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/app/theme/app_palette.dart';
import 'package:linknote/app/theme/app_theme.dart';
import 'package:linknote/features/collection/domain/entity/collection_entity.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/features/link/domain/entity/tag_entity.dart';
import 'package:linknote/features/reading_stats/domain/entity/reading_stats_entity.dart';
import 'package:linknote/features/reading_stats/presentation/provider/link_reading_stats_provider.dart';
import 'package:linknote/shared/widgets/ln/ln_brand.dart';
import 'package:linknote/shared/widgets/ln/ln_collection_card.dart';
import 'package:linknote/shared/widgets/ln/ln_icon_btn.dart';
import 'package:linknote/shared/widgets/ln/ln_link_card.dart';
import 'package:linknote/shared/widgets/ln/ln_segmented.dart';
import 'package:linknote/shared/widgets/ln/ln_tag.dart';
import 'package:linknote/shared/widgets/ln/ln_top_bar.dart';

/// Structural dark-mode regression tests for Ln widgets.
///
/// Verifies that each widget renders without throwing under [AppTheme.dark]
/// and pulls colors from the dark [AppPalette] (not hardcoded light tokens).
///
/// Visual goldens are deferred — `golden_toolkit` adoption is Phase 4.5+.
void main() {
  Future<void> pumpDark(WidgetTester tester, Widget child) {
    return tester.pumpWidget(
      ProviderScope(
        overrides: [
          linkReadingStatsProvider.overrideWith(
            (ref, linkId) async => const ReadingStatsEntity(linkId: ''),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(body: Center(child: child)),
        ),
      ),
    );
  }

  final link = LinkEntity(
    id: '1',
    url: 'https://flutter.dev/docs',
    title: 'Flutter docs',
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
    tags: const [TagEntity(id: 't1', name: 'flutter', color: '#1F6E53')],
  );

  final collection = CollectionEntity(
    id: 'c1',
    name: 'Flutter Resources',
    linkCount: 12,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );

  group('Ln widgets render under AppTheme.dark', () {
    testWidgets('LnLinkCard renders and uses dark ink for title', (
      tester,
    ) async {
      await pumpDark(tester, LnLinkCard(link: link));
      await tester.pumpAndSettle();

      expect(find.text('Flutter docs'), findsOneWidget);
      final titleStyle = tester.widget<Text>(find.text('Flutter docs')).style;
      expect(titleStyle?.color, AppPalette.dark().ink);
    });

    testWidgets('LnCollectionCard renders with dark bg', (tester) async {
      await pumpDark(tester, LnCollectionCard(collection: collection));
      await tester.pumpAndSettle();

      expect(find.text('Flutter Resources'), findsOneWidget);
      final material = tester.widget<Material>(
        find.descendant(
          of: find.byType(LnCollectionCard),
          matching: find.byType(Material),
        ),
      );
      expect(material.color, AppPalette.dark().bg);
    });

    testWidgets('LnTopBar renders with dark surface', (tester) async {
      await pumpDark(tester, const LnTopBar(title: 'Title'));
      await tester.pumpAndSettle();

      expect(find.text('Title'), findsOneWidget);
      final titleStyle = tester.widget<Text>(find.text('Title')).style;
      expect(titleStyle?.color, AppPalette.dark().ink);
    });

    testWidgets('LnIconBtn renders with dark ink', (tester) async {
      await pumpDark(tester, const LnIconBtn(icon: Icons.star_rounded));
      await tester.pumpAndSettle();

      final icon = tester.widget<Icon>(
        find.descendant(
          of: find.byType(LnIconBtn),
          matching: find.byIcon(Icons.star_rounded),
        ),
      );
      expect(icon.color, AppPalette.dark().ink);
    });

    testWidgets('LnSegmented renders selected state with dark bg', (
      tester,
    ) async {
      await pumpDark(
        tester,
        LnSegmented(
          labels: const ['One', 'Two'],
          selectedIndex: 0,
          onChanged: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('One'), findsOneWidget);
      expect(find.text('Two'), findsOneWidget);
    });

    testWidgets('LnTag uses dark forestSoft background for #flutter', (
      tester,
    ) async {
      await pumpDark(tester, const LnTag(name: 'flutter'));
      await tester.pumpAndSettle();

      // Find the inner pill Container (decorated with tone background).
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(LnTag),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration as BoxDecoration?;
      expect(decoration?.color, AppPalette.dark().forestSoft);
    });

    testWidgets('LinkNoteWordmark renders without crashing in dark theme', (
      tester,
    ) async {
      await pumpDark(tester, const LinkNoteWordmark());
      await tester.pumpAndSettle();

      expect(find.byType(LinkNoteWordmark), findsOneWidget);
      expect(find.byType(Semantics), findsWidgets);
    });

    testWidgets('LinkNoteMark uses dark forest accent on filled square', (
      tester,
    ) async {
      await pumpDark(tester, const LinkNoteMark());
      await tester.pumpAndSettle();

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(LinkNoteMark),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration as BoxDecoration?;
      expect(decoration?.color, AppPalette.dark().forest);
    });
  });
}
