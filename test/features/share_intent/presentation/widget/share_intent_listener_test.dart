import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:linknote/app/router/app_router.dart';
import 'package:linknote/features/share_intent/presentation/provider/shared_media_stream_provider.dart';
import 'package:linknote/features/share_intent/presentation/widget/share_intent_listener.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

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

void main() {
  group('resolveWarmShareAction', () {
    test('navigates when a URL is extracted on a passive route', () {
      expect(
        resolveWarmShareAction(
          extractedUrl: 'https://a.com',
          currentLocation: '/home',
        ),
        WarmShareAction.navigate,
      );
    });

    test('degrades while on the link-add route', () {
      expect(
        resolveWarmShareAction(
          extractedUrl: 'https://a.com',
          currentLocation: '/links/new',
        ),
        WarmShareAction.degrade,
      );
    });

    test('degrades while on an edit route', () {
      expect(
        resolveWarmShareAction(
          extractedUrl: 'https://a.com',
          currentLocation: '/links/42/edit',
        ),
        WarmShareAction.degrade,
      );
    });

    test('degrades while on the collection-new route', () {
      expect(
        resolveWarmShareAction(
          extractedUrl: 'https://a.com',
          currentLocation: '/collections/new',
        ),
        WarmShareAction.degrade,
      );
    });

    test('reports failure when no URL could be extracted', () {
      expect(
        resolveWarmShareAction(
          extractedUrl: null,
          currentLocation: '/home',
        ),
        WarmShareAction.toastFailure,
      );
    });

    test('failure takes precedence even on an editing route', () {
      expect(
        resolveWarmShareAction(
          extractedUrl: null,
          currentLocation: '/links/new',
        ),
        WarmShareAction.toastFailure,
      );
    });
  });

  group('ShareIntentListener widget', () {
    late StreamController<List<SharedMediaFile>> controller;

    setUp(
      () => controller = StreamController<List<SharedMediaFile>>.broadcast(),
    );
    tearDown(() => controller.close());

    Future<GoRouter> pumpListener(WidgetTester tester, String initial) async {
      final router = _testRouter(initial);
      final messengerKey = GlobalKey<ScaffoldMessengerState>();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appRouterProvider.overrideWithValue(router),
            sharedMediaStreamProvider.overrideWith((ref) => controller.stream),
          ],
          child: MaterialApp.router(
            routerConfig: router,
            scaffoldMessengerKey: messengerKey,
            builder: (context, child) => ShareIntentListener(
              messengerKey: messengerKey,
              child: child!,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return router;
    }

    testWidgets('warm share on a passive route opens the prefill form', (
      tester,
    ) async {
      await pumpListener(tester, '/home');
      expect(find.text('HOME'), findsOneWidget);

      controller.add([_text('https://flutter.dev')]);
      await tester.pump(); // deliver event → schedule post-frame push
      await tester.pumpAndSettle(); // settle navigation

      // The pushed prefill form is shown with the decoded URL seeded.
      expect(find.text('ADD:https://flutter.dev'), findsOneWidget);
    });

    testWidgets('warm share while editing degrades to a snackbar', (
      tester,
    ) async {
      await pumpListener(tester, '/links/7/edit');
      expect(find.text('EDIT'), findsOneWidget);

      controller.add([_text('https://flutter.dev')]);
      await tester.pump(); // deliver event
      await tester.pump(); // run post-frame → showSnackBar
      await tester.pump(const Duration(milliseconds: 50)); // snackbar enters

      // Stayed on the edit screen — no clobbering navigation.
      expect(find.text('EDIT'), findsOneWidget);
      expect(find.textContaining('ADD:'), findsNothing);
      expect(
        find.widgetWithText(SnackBar, 'Shared link received'),
        findsOneWidget,
      );
    });

    testWidgets('unsalvageable payload shows a failure snackbar', (
      tester,
    ) async {
      await pumpListener(tester, '/home');

      controller.add([_text('no url here just prose')]);
      await tester.pump(); // deliver event
      await tester.pump(); // run post-frame → showSnackBar
      await tester.pump(const Duration(milliseconds: 50)); // snackbar enters

      expect(find.text('HOME'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}
