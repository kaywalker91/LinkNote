import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:linknote/features/auth/domain/entity/auth_state_entity.dart';
import 'package:linknote/features/auth/presentation/provider/auth_provider.dart';
import 'package:linknote/features/auth/presentation/screens/login_screen.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/features/link/presentation/provider/link_list_provider.dart';
import 'package:linknote/features/link/presentation/screens/home_screen.dart';
import 'package:linknote/features/link/presentation/screens/link_add_screen.dart';
import 'package:linknote/shared/models/paginated_state.dart';

// ---------------------------------------------------------------------------
// Mock notifiers
// ---------------------------------------------------------------------------
class _UnauthAuth extends Auth {
  final Completer<void> _signInCompleter = Completer();

  @override
  Future<AuthStateEntity> build() async {
    return const AuthStateEntity.unauthenticated();
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    // Simulate successful sign-in
    state = const AsyncData(
      AuthStateEntity.authenticated(userId: 'u1', email: 'test@example.com'),
    );
    notifyListeners();
    _signInCompleter.complete();
  }

  Future<void> get signInDone => _signInCompleter.future;
}

class _AuthenticatedAuth extends Auth {
  @override
  Future<AuthStateEntity> build() async {
    return const AuthStateEntity.authenticated(
      userId: 'u1',
      email: 'test@example.com',
    );
  }
}

class _EmptyLinkList extends LinkList {
  @override
  Future<PaginatedState<LinkEntity>> build() async {
    return const PaginatedState<LinkEntity>(items: []);
  }

  @override
  Future<void> refresh() async {}

  @override
  Future<void> loadMore() async {}

  @override
  Future<void> deleteLink(String id) async {}

  @override
  Future<void> toggleFavorite(String id) async {}
}

class _PopulatedLinkList extends LinkList {
  @override
  Future<PaginatedState<LinkEntity>> build() async {
    return PaginatedState<LinkEntity>(
      items: [
        LinkEntity(
          id: '1',
          url: 'https://flutter.dev',
          title: 'Flutter',
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        ),
      ],
    );
  }

  @override
  Future<void> refresh() async {}

  @override
  Future<void> loadMore() async {}

  @override
  Future<void> deleteLink(String id) async {}

  @override
  Future<void> toggleFavorite(String id) async {}
}

void main() {
  group('Login → Link Add → List flow', () {
    testWidgets('should show validation on empty login then sign in', (
      tester,
    ) async {
      // Arrange — start on login
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(_UnauthAuth.new),
          ],
          child: const MaterialApp(home: LoginScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Act — tap sign-in with empty fields
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Assert — validation shown
      expect(find.text('Enter email'), findsOneWidget);
      expect(find.text('Enter password'), findsOneWidget);

      // Act — fill in credentials and sign in
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'test@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'password123',
      );
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Assert — validation messages gone
      expect(find.text('Enter email'), findsNothing);
      expect(find.text('Enter password'), findsNothing);
    });

    testWidgets('should show links on home screen after auth', (tester) async {
      // Arrange — authenticated state with link data
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(_AuthenticatedAuth.new),
            linkListProvider.overrideWith(_PopulatedLinkList.new),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Flutter'), findsOneWidget);
      expect(find.text('flutter.dev'), findsOneWidget);
    });

    testWidgets('should render link add form and validate required fields', (
      tester,
    ) async {
      // Arrange — link add screen
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: LinkAddScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Assert — form fields visible
      expect(find.text('URL *'), findsOneWidget);
      expect(find.text('Title *'), findsOneWidget);

      // Act — submit empty
      await tester.ensureVisible(find.text('Save Link'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save Link'));
      await tester.pumpAndSettle();

      // Assert — validation
      expect(find.text('URL and title are required'), findsOneWidget);
    });

    testWidgets('should navigate login → home → add via GoRouter', (
      tester,
    ) async {
      // Arrange — simplified GoRouter for the flow
      final router = GoRouter(
        initialLocation: '/login',
        routes: [
          GoRoute(
            path: '/login',
            pageBuilder: (_, state) => NoTransitionPage(
              key: state.pageKey,
              child: const LoginScreen(),
            ),
          ),
          GoRoute(
            path: '/home',
            pageBuilder: (_, state) =>
                NoTransitionPage(key: state.pageKey, child: const HomeScreen()),
          ),
          GoRoute(
            path: '/links/new',
            pageBuilder: (_, state) => NoTransitionPage(
              key: state.pageKey,
              child: const LinkAddScreen(),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(_UnauthAuth.new),
            linkListProvider.overrideWith(_EmptyLinkList.new),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Assert — on login
      expect(find.text('Welcome back'), findsOneWidget);

      // Act — navigate to home (ShimmerBox skeleton may show briefly; avoid pumpAndSettle)
      router.go('/home');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Assert — on home
      expect(find.text('LinkNote'), findsOneWidget);

      // Act — navigate to link add (do NOT await push — the Future completes on pop)
      unawaited(router.push('/links/new'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Assert — on link add
      expect(find.text('URL *'), findsOneWidget);
      expect(find.text('Save Link'), findsOneWidget);
    });
  });
}
