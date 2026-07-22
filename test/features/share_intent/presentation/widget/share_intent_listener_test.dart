import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:linknote/app/router/app_router.dart';
import 'package:linknote/core/services/analytics_service.dart';
import 'package:linknote/features/auth/domain/entity/auth_state_entity.dart';
import 'package:linknote/features/auth/presentation/provider/auth_provider.dart';
import 'package:linknote/features/share_intent/data/android_share_extras.dart';
import 'package:linknote/features/share_intent/domain/service/share_payload_resolver.dart';
import 'package:linknote/features/share_intent/presentation/provider/pending_shared_url_provider.dart';
import 'package:linknote/features/share_intent/presentation/provider/shared_media_stream_provider.dart';
import 'package:linknote/features/share_intent/presentation/widget/share_intent_listener.dart';
import 'package:mocktail/mocktail.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class MockAnalyticsService extends Mock implements AnalyticsService {}

/// No native extras — tests only exercise the plugin path payload.
class _EmptyExtrasReader extends AndroidShareExtrasReader {
  @override
  Future<AndroidShareExtras?> read() async => null;
}

final _testResolver = SharePayloadResolver(
  extrasReader: _EmptyExtrasReader(),
);

SharedMediaFile _text(String value) =>
    SharedMediaFile(path: value, type: SharedMediaType.text);

GoRouter _testRouter(String initial) => GoRouter(
  initialLocation: initial,
  routes: [
    GoRoute(
      path: '/home',
      builder: (_, _) => const Scaffold(body: Text('HOME')),
    ),
    GoRoute(
      path: '/login',
      builder: (_, _) => const Scaffold(body: Text('LOGIN')),
    ),
    GoRoute(
      path: '/links/new',
      builder: (_, state) => Scaffold(
        body: Text('ADD:${state.uri.queryParameters['prefill'] ?? ''}'),
      ),
    ),
    GoRoute(
      path: '/links/:id/edit',
      builder: (_, _) => const Scaffold(body: Text('EDIT')),
    ),
  ],
);

/// Minimal Auth override — bypasses real Supabase bootstrap.
class _StubAuth extends Auth {
  _StubAuth(this._state);
  final AuthStateEntity _state;

  @override
  Future<AuthStateEntity> build() async => _state;
}

void main() {
  group('resolveWarmShareAction', () {
    test('navigates when authenticated on a passive route', () {
      expect(
        resolveWarmShareAction(
          extractedUrl: 'https://a.com',
          currentLocation: '/home',
          isAuthenticated: true,
        ),
        WarmShareAction.navigate,
      );
    });

    test('defers when unauthenticated even on a passive route', () {
      expect(
        resolveWarmShareAction(
          extractedUrl: 'https://a.com',
          currentLocation: '/home',
          isAuthenticated: false,
        ),
        WarmShareAction.deferUntilAuthenticated,
      );
    });

    test('defers when unauthenticated on login route', () {
      expect(
        resolveWarmShareAction(
          extractedUrl: 'https://a.com',
          currentLocation: '/login',
          isAuthenticated: false,
        ),
        WarmShareAction.deferUntilAuthenticated,
      );
    });

    test('degrades while on the link-add route (authenticated)', () {
      expect(
        resolveWarmShareAction(
          extractedUrl: 'https://a.com',
          currentLocation: '/links/new',
          isAuthenticated: true,
        ),
        WarmShareAction.degrade,
      );
    });

    test('degrades while on an edit route', () {
      expect(
        resolveWarmShareAction(
          extractedUrl: 'https://a.com',
          currentLocation: '/links/42/edit',
          isAuthenticated: true,
        ),
        WarmShareAction.degrade,
      );
    });

    test('degrades while on the collection-new route', () {
      expect(
        resolveWarmShareAction(
          extractedUrl: 'https://a.com',
          currentLocation: '/collections/new',
          isAuthenticated: true,
        ),
        WarmShareAction.degrade,
      );
    });

    test('reports failure when no URL could be extracted', () {
      expect(
        resolveWarmShareAction(
          extractedUrl: null,
          currentLocation: '/home',
          isAuthenticated: true,
        ),
        WarmShareAction.toastFailure,
      );
    });

    test('failure takes precedence even on an editing route', () {
      expect(
        resolveWarmShareAction(
          extractedUrl: null,
          currentLocation: '/links/new',
          isAuthenticated: true,
        ),
        WarmShareAction.toastFailure,
      );
    });

    test('failure takes precedence over unauthenticated', () {
      expect(
        resolveWarmShareAction(
          extractedUrl: null,
          currentLocation: '/login',
          isAuthenticated: false,
        ),
        WarmShareAction.toastFailure,
      );
    });
  });

  group('ShareIntentListener widget', () {
    late StreamController<List<SharedMediaFile>> controller;
    late MockAnalyticsService mockAnalytics;

    setUp(() {
      controller = StreamController<List<SharedMediaFile>>.broadcast();
      mockAnalytics = MockAnalyticsService();
      when(
        () => mockAnalytics.logShareIntentReceived(
          appState: any(named: 'appState'),
          payloadType: any(named: 'payloadType'),
        ),
      ).thenAnswer((_) async {});
      when(
        () => mockAnalytics.logShareUrlExtracted(
          appState: any(named: 'appState'),
          sourceCategory: any(named: 'sourceCategory'),
        ),
      ).thenAnswer((_) async {});
      when(
        () => mockAnalytics.logShareUrlRejected(
          reasonCode: any(named: 'reasonCode'),
        ),
      ).thenAnswer((_) async {});
      when(
        () => mockAnalytics.logShareAddFormOpened(
          entryState: any(named: 'entryState'),
        ),
      ).thenAnswer((_) async {});
    });
    tearDown(() => controller.close());

    Future<ProviderContainer> pumpListener(
      WidgetTester tester,
      String initial, {
      AuthStateEntity auth = const Authenticated(
        userId: 'u1',
        email: 'a@b.com',
      ),
    }) async {
      final router = _testRouter(initial);
      final messengerKey = GlobalKey<ScaffoldMessengerState>();
      final container = ProviderContainer(
        overrides: [
          appRouterProvider.overrideWithValue(router),
          sharedMediaStreamProvider.overrideWith((ref) => controller.stream),
          analyticsServiceProvider.overrideWithValue(mockAnalytics),
          authProvider.overrideWith(() => _StubAuth(auth)),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: router,
            scaffoldMessengerKey: messengerKey,
            builder: (context, child) => ShareIntentListener(
              messengerKey: messengerKey,
              payloadResolver: _testResolver,
              child: child!,
            ),
          ),
        ),
      );
      // Auth is async; wait so resolveWarmShareAction sees a real value.
      await container.read(authProvider.future);
      await tester.pumpAndSettle();
      return container;
    }

    /// Delivers a stream event and flushes async resolve + post-frame work.
    Future<void> deliverShare(WidgetTester tester, String payload) async {
      controller.add([_text(payload)]);
      await tester.pump(); // stream → _handleSharePayload scheduled
      await tester.pump(); // await resolveUrl completes → post-frame scheduled
      await tester.pump(); // post-frame callback
      await tester.pump(const Duration(milliseconds: 50));
    }

    testWidgets('warm share on a passive route opens the prefill form', (
      tester,
    ) async {
      await pumpListener(tester, '/home');
      expect(find.text('HOME'), findsOneWidget);

      await deliverShare(tester, 'https://flutter.dev');
      await tester.pumpAndSettle();

      // The pushed prefill form is shown with the decoded URL seeded.
      expect(find.text('ADD:https://flutter.dev'), findsOneWidget);
    });

    testWidgets('warm share while editing degrades to a snackbar', (
      tester,
    ) async {
      await pumpListener(tester, '/links/7/edit');
      expect(find.text('EDIT'), findsOneWidget);

      await deliverShare(tester, 'https://flutter.dev');

      // Stayed on the edit screen — no clobbering navigation.
      expect(find.text('EDIT'), findsOneWidget);
      expect(find.textContaining('ADD:'), findsNothing);
      expect(
        find.widgetWithText(SnackBar, '공유한 링크를 받았어요.'),
        findsOneWidget,
      );
      expect(find.text('열기'), findsOneWidget);
    });

    testWidgets('unsalvageable payload shows a failure snackbar', (
      tester,
    ) async {
      await pumpListener(tester, '/home');

      await deliverShare(tester, 'no url here just prose');

      expect(find.text('HOME'), findsOneWidget);
      expect(
        find.widgetWithText(SnackBar, '공유 내용에서 저장할 링크를 찾지 못했어요.'),
        findsOneWidget,
      );
    });

    testWidgets(
      'warm unauthenticated share seeds pending URL without navigating',
      (tester) async {
        final container = await pumpListener(
          tester,
          '/login',
          auth: const Unauthenticated(),
        );

        await deliverShare(tester, 'https://example.com/shared');
        await tester.pumpAndSettle();

        // Stayed on login — no premature prefill navigation.
        expect(find.text('LOGIN'), findsOneWidget);
        expect(find.textContaining('ADD:'), findsNothing);
        expect(
          container.read(pendingSharedUrlProvider),
          'https://example.com/shared',
        );
      },
    );
  });
}
