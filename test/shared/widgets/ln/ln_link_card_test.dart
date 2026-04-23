import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/features/link/domain/entity/tag_entity.dart';
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

    testWidgets('renders title, host, and tag', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: LnLinkCard(link: link)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Flutter docs'), findsOneWidget);
      expect(find.text('flutter.dev'), findsOneWidget);
      expect(find.textContaining('flutter'), findsWidgets);
    });

    testWidgets('onTap is invoked', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LnLinkCard(link: link, onTap: () => tapped = true),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(LnLinkCard));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });

    testWidgets('favoriteBusy shows progress indicator', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LnLinkCard(link: link, favoriteBusy: true),
          ),
        ),
      );
      // CircularProgressIndicator animates forever; use pump(), not pumpAndSettle.
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
