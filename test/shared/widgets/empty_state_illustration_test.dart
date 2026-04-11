import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/shared/widgets/empty_state_illustration.dart';

void main() {
  Widget buildApp({required Widget child}) {
    return MaterialApp(
      home: Scaffold(body: Center(child: child)),
    );
  }

  group('EmptyStateIllustration', () {
    testWidgets('should render links illustration with badge', (tester) async {
      await tester.pumpWidget(
        buildApp(child: const EmptyStateIllustration.links()),
      );

      expect(find.byIcon(Icons.bookmarks_outlined), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should render collections illustration without badge', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildApp(child: const EmptyStateIllustration.collections()),
      );

      expect(find.byIcon(Icons.folder_outlined), findsOneWidget);
    });

    testWidgets('should render search illustration', (tester) async {
      await tester.pumpWidget(
        buildApp(child: const EmptyStateIllustration.search()),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('should render noResults illustration', (tester) async {
      await tester.pumpWidget(
        buildApp(child: const EmptyStateIllustration.noResults()),
      );

      expect(find.byIcon(Icons.search_off_outlined), findsOneWidget);
    });

    testWidgets('should render notifications illustration', (tester) async {
      await tester.pumpWidget(
        buildApp(child: const EmptyStateIllustration.notifications()),
      );

      expect(find.byIcon(Icons.notifications_none_outlined), findsOneWidget);
    });

    testWidgets('should have 120x120 size', (tester) async {
      await tester.pumpWidget(
        buildApp(child: const EmptyStateIllustration.links()),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, 120);
      expect(sizedBox.height, 120);
    });

    testWidgets('should use custom accent color when provided', (tester) async {
      await tester.pumpWidget(
        buildApp(
          child: const EmptyStateIllustration(
            primaryIcon: Icons.star,
            accentColor: Colors.orange,
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsOneWidget);
    });
  });
}
