import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:linknote/core/services/analytics_service.dart';
import 'package:linknote/shared/widgets/app_scaffold_with_nav_bar.dart';
import 'package:mocktail/mocktail.dart';

class MockAnalyticsService extends Mock implements AnalyticsService {}

void main() {
  group('AppScaffoldWithNavBar.destinationLabels', () {
    test('should expose 4 bottom nav destinations', () {
      expect(AppScaffoldWithNavBar.destinationLabels.length, 4);
    });

    test('should contain Home, Search, Collections, Profile (in order)', () {
      expect(
        AppScaffoldWithNavBar.destinationLabels,
        equals(const ['Home', 'Search', 'Collections', 'Profile']),
      );
    });

    test('should NOT contain Notifications (moved to AppBar bell)', () {
      expect(
        AppScaffoldWithNavBar.destinationLabels,
        isNot(contains('Notifications')),
      );
    });
  });

  late MockAnalyticsService mockAnalytics;

  setUp(() {
    mockAnalytics = MockAnalyticsService();
    when(() => mockAnalytics.logScreenView(any())).thenAnswer((_) async {});
  });

  // Minimal shell router mirroring the production 4-branch layout so the real
  // widget builds with a genuine StatefulNavigationShell.
  GoRouter buildRouter() {
    GoRoute page(String path, String label) => GoRoute(
      path: path,
      pageBuilder: (context, state) => NoTransitionPage(
        child: Scaffold(body: Center(child: Text(label))),
      ),
    );

    return GoRouter(
      initialLocation: '/home',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) =>
              AppScaffoldWithNavBar(navigationShell: shell),
          branches: [
            StatefulShellBranch(routes: [page('/home', 'HomeBody')]),
            StatefulShellBranch(routes: [page('/search', 'SearchBody')]),
            StatefulShellBranch(
              routes: [page('/collections', 'CollectionsBody')],
            ),
            StatefulShellBranch(routes: [page('/profile', 'ProfileBody')]),
          ],
        ),
        // Root-navigator push targets for the shell FAB, as in production.
        page('/links/new', 'LinkAddBody'),
        page('/collections/new', 'CollectionFormBody'),
      ],
    );
  }

  Future<void> pumpShell(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [analyticsServiceProvider.overrideWithValue(mockAnalytics)],
        child: MaterialApp.router(routerConfig: buildRouter()),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('tab-switch screen_view logging', () {
    testWidgets('does not log on initial build (root observer owns it)', (
      tester,
    ) async {
      await pumpShell(tester);
      verifyNever(() => mockAnalytics.logScreenView(any()));
    });

    testWidgets('logs the branch route when a tab is selected', (tester) async {
      await pumpShell(tester);

      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();
      verify(() => mockAnalytics.logScreenView('/search')).called(1);

      await tester.tap(find.text('Collections'));
      await tester.pumpAndSettle();
      verify(() => mockAnalytics.logScreenView('/collections')).called(1);
    });

    testWidgets('maps each destination index to its route path', (
      tester,
    ) async {
      await pumpShell(tester);

      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      verify(() => mockAnalytics.logScreenView('/profile')).called(1);
      verify(() => mockAnalytics.logScreenView('/home')).called(1);
    });
  });

  group('shell FAB', () {
    Future<void> goToCollections(WidgetTester tester) async {
      await tester.tap(find.text('Collections'));
      await tester.pumpAndSettle();
    }

    testWidgets('is add-link on non-collection tabs', (tester) async {
      await pumpShell(tester);

      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
      expect(find.byIcon(Icons.create_new_folder_rounded), findsNothing);
      expect(
        tester
            .widget<FloatingActionButton>(
              find.byType(FloatingActionButton),
            )
            .tooltip,
        '링크 추가',
      );

      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
    });

    testWidgets('becomes add-collection on the Collections tab', (
      tester,
    ) async {
      await pumpShell(tester);
      await goToCollections(tester);

      expect(find.byIcon(Icons.create_new_folder_rounded), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsNothing);
      expect(
        tester
            .widget<FloatingActionButton>(
              find.byType(FloatingActionButton),
            )
            .tooltip,
        '컬렉션 추가',
      );
    });

    testWidgets('pushes the add-link route from the Home tab', (tester) async {
      await pumpShell(tester);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('LinkAddBody'), findsOneWidget);
    });

    testWidgets('pushes the collection form route from the Collections tab', (
      tester,
    ) async {
      await pumpShell(tester);
      await goToCollections(tester);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('CollectionFormBody'), findsOneWidget);
    });

    testWidgets('reverts to add-link when leaving the Collections tab', (
      tester,
    ) async {
      await pumpShell(tester);
      await goToCollections(tester);

      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
      expect(find.byIcon(Icons.create_new_folder_rounded), findsNothing);
    });
  });
}
