import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/app/theme/app_colors.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/shared/widgets/link_list_tile.dart';

LinkEntity _link({
  String title = 'Flutter Forest Guide',
  String url = 'https://flutter.dev/docs',
}) {
  return LinkEntity(
    id: '1',
    url: url,
    title: title,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );
}

Widget _wrap(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

void main() {
  group('LinkListTile highlightText', () {
    testWidgets(
      'should render title as plain Text when highlightText is null',
      (tester) async {
        await tester.pumpWidget(_wrap(LinkListTile(link: _link())));
        await tester.pumpAndSettle();

        final titleFinder = find.text('Flutter Forest Guide');
        expect(titleFinder, findsOneWidget);
        expect(find.byType(RichText), findsWidgets);
      },
    );

    testWidgets(
      'should split title into spans when highlightText matches case-insensitively',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            LinkListTile(
              link: _link(),
              highlightText: 'forest',
            ),
          ),
        );
        await tester.pumpAndSettle();

        final richTextFinder = find.byWidgetPredicate(
          (w) => w is RichText && _containsHighlight(w.text, 'Forest'),
        );
        expect(richTextFinder, findsOneWidget);
      },
    );

    testWidgets(
      'should not highlight title when highlightText is empty',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            LinkListTile(
              link: _link(),
              highlightText: '',
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Flutter Forest Guide'), findsOneWidget);
      },
    );

    testWidgets(
      'should preserve title text when highlightText does not match',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            LinkListTile(
              link: _link(),
              highlightText: 'xyz',
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Flutter Forest Guide'), findsOneWidget);
      },
    );
  });
}

bool _containsHighlight(InlineSpan span, String expected) {
  var found = false;
  span.visitChildren((child) {
    if (child is TextSpan && child.text == expected) {
      final bg = child.style?.backgroundColor;
      if (bg == AppColors.forestSoft) {
        found = true;
        return false;
      }
    }
    return true;
  });
  return found;
}
