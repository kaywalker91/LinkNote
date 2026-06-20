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

  group('tab-switch screen_view logging', () {
    late MockAnalyticsService mockAnalytics;

    setUp(() {
      mockAnalytics = MockAnalyticsService();
      when(() => mockAnalytics.logScreenView(any())).thenAnswer((_) async {});
    });

    // Minimal shell router mirroring the production 4-branch layout so the real
    // widget builds with a genuine StatefulNavigationShell.
    GoRouter buildRouter() {
      GoRoute branch(String path, String label) => GoRoute(
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
              StatefulShellBranch(routes: [branch('/home', 'HomeBody')]),
              StatefulShellBranch(routes: [branch('/search', 'SearchBody')]),
              StatefulShellBranch(
                routes: [branch('/collections', 'CollectionsBody')],
              ),
              StatefulShellBranch(routes: [branch('/profile', 'ProfileBody')]),
            ],
          ),
        ],
      );
    }

    Future<void> pumpShell(WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            analyticsServiceProvider.overrideWithValue(mockAnalytics),
          ],
          child: MaterialApp.router(routerConfig: buildRouter()),
        ),
      );
      await tester.pumpAndSettle();
    }

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
}
