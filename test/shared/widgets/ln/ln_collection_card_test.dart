import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/features/collection/domain/entity/collection_entity.dart';
import 'package:linknote/shared/widgets/ln/ln_collection_card.dart';

CollectionEntity _make({
  String id = 'c1',
  String name = 'Flutter Resources',
  int linkCount = 12,
  String? description,
}) {
  return CollectionEntity(
    id: id,
    name: name,
    linkCount: linkCount,
    description: description,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );
}

void main() {
  group('LnCollectionCard', () {
    testWidgets('renders name and link count', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LnCollectionCard(collection: _make(linkCount: 7)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Flutter Resources'), findsOneWidget);
      expect(find.text('링크 7개'), findsOneWidget);
    });

    testWidgets('onTap fires', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LnCollectionCard(
              collection: _make(),
              onTap: () => tapped = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(LnCollectionCard));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('shows folder icon in gradient header', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LnCollectionCard(collection: _make()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.folder_rounded), findsOneWidget);
    });

    testWidgets('renders deterministic tone for same id', (tester) async {
      // Same id should always pick the same tone.
      final tone1 = LnCollectionCard.toneForId('stable-id');
      final tone2 = LnCollectionCard.toneForId('stable-id');
      expect(tone1, equals(tone2));
    });

    testWidgets('toneForId distributes across palette', (tester) async {
      // Multiple distinct ids should not collapse to a single tone.
      final tones = <String>{};
      for (var i = 0; i < 20; i++) {
        tones.add(LnCollectionCard.toneForId('id-$i').name);
      }
      expect(tones.length, greaterThan(1));
    });
  });
}
