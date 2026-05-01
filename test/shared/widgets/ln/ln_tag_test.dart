import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/app/theme/app_colors.dart';
import 'package:linknote/shared/widgets/ln/ln_tag.dart';
import 'package:linknote/shared/widgets/ln/ln_tags.dart';

void main() {
  group('LnTagTone', () {
    test('known name maps to expected tone', () {
      expect(lnTagToneFor('flutter'), LnTagTone.forest);
      expect(lnTagToneFor('Design'), LnTagTone.rose);
      expect(lnTagToneFor(' AI '), LnTagTone.lilac);
      expect(lnTagToneFor('backend'), LnTagTone.slate);
      expect(lnTagToneFor('favorite'), LnTagTone.amber);
    });

    test('unknown name falls back to slate tone', () {
      expect(lnTagToneFor('x-random-tag'), LnTagTone.slate);
    });

    testWidgets(
      'tone exposes both background and foreground colors via context',
      (tester) async {
        late BuildContext ctx;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (c) {
                ctx = c;
                return const SizedBox();
              },
            ),
          ),
        );
        expect(LnTagTone.forest.background(ctx), AppColors.forestSoft);
        expect(LnTagTone.forest.foreground(ctx), AppColors.forestInk);
        expect(LnTagTone.amber.background(ctx), AppColors.amberSoft);
        expect(LnTagTone.rose.foreground(ctx), AppColors.rose);
      },
    );
  });

  group('LnTag widget', () {
    testWidgets('renders hash prefix and name', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: LnTag(name: 'flutter')),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('#'), findsOneWidget);
      expect(find.textContaining('flutter'), findsOneWidget);
    });

    testWidgets('onTap is invoked', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LnTag(name: 'design', onTap: () => tapped = true),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(LnTag));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });
  });
}
