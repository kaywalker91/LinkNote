import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linknote/app/router/app_router.dart';
import 'package:linknote/app/router/routes.dart';
import 'package:linknote/core/logger/app_logger.dart';
import 'package:linknote/core/services/analytics_service.dart';
import 'package:linknote/features/auth/domain/entity/auth_state_entity.dart';
import 'package:linknote/features/auth/presentation/provider/auth_provider.dart';
import 'package:linknote/features/share_intent/domain/service/share_payload_resolver.dart';
import 'package:linknote/features/share_intent/domain/service/shared_intent_service.dart';
import 'package:linknote/features/share_intent/presentation/provider/pending_shared_url_provider.dart';
import 'package:linknote/features/share_intent/presentation/provider/shared_media_stream_provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

/// What to do with a warm/foreground share intent.
enum WarmShareAction {
  /// A URL was salvaged, user is authenticated, and no in-progress form is at
  /// risk — open the prefill form directly.
  navigate,

  /// A URL was salvaged but the user is not authenticated yet. Seed pending
  /// and wait for login — do not push a protected route.
  deferUntilAuthenticated,

  /// A URL was salvaged but the user is editing a form. Don't clobber their
  /// input; surface a snackbar that lets them opt in.
  degrade,

  /// The payload carried no usable URL — tell the user it couldn't be saved.
  toastFailure,
}

/// Pure decision for a warm share. Extracted for unit testing without the
/// widget tree.
WarmShareAction resolveWarmShareAction({
  required String? extractedUrl,
  required String currentLocation,
  required bool isAuthenticated,
}) {
  if (extractedUrl == null) return WarmShareAction.toastFailure;
  if (!isAuthenticated) return WarmShareAction.deferUntilAuthenticated;
  if (_isEditingRoute(currentLocation)) return WarmShareAction.degrade;
  return WarmShareAction.navigate;
}

/// Whether [location] is a full-screen create/edit form where a warm share
/// would destroy unsaved input.
bool _isEditingRoute(String location) {
  return location == Routes.linkAdd ||
      location == Routes.collectionNew ||
      location.endsWith('/edit');
}

/// Subscribes to the warm/foreground share stream for the app's lifetime and
/// routes each incoming share, degrading to a snackbar when the user is mid-edit
/// and reporting a failure when no URL can be salvaged.
///
/// Mounted above the [Navigator] via `MaterialApp.router`'s `builder`, so its
/// subscription and snackbar context survive route changes.
class ShareIntentListener extends ConsumerStatefulWidget {
  const ShareIntentListener({
    required this.child,
    required this.messengerKey,
    this.payloadResolver,
    super.key,
  });

  final Widget child;

  /// The app's [ScaffoldMessenger] key. The listener sits above the messenger
  /// in `MaterialApp.router`'s `builder`, so it shows snackbars through the key
  /// rather than an (absent) ancestor lookup.
  final GlobalKey<ScaffoldMessengerState> messengerKey;

  /// Injectable for tests; defaults to real Android extras fallback.
  final SharePayloadResolver? payloadResolver;

  @override
  ConsumerState<ShareIntentListener> createState() =>
      _ShareIntentListenerState();
}

class _ShareIntentListenerState extends ConsumerState<ShareIntentListener> {
  late final SharePayloadResolver _resolver =
      widget.payloadResolver ?? SharePayloadResolver();

  void _onShare(
    AsyncValue<List<SharedMediaFile>>? previous,
    AsyncValue<List<SharedMediaFile>> next,
  ) {
    final media = next.value;
    if (media == null || media.isEmpty) return;

    final payload = media.first.path;
    unawaited(_handleSharePayload(payload));
  }

  Future<void> _handleSharePayload(String payload) async {
    final router = ref.read(appRouterProvider);
    final analytics = ref.read(analyticsServiceProvider);

    unawaited(
      analytics.logShareIntentReceived(
        appState: 'warm',
        payloadType: 'text',
      ),
    );

    // Internal deep link (`linknote://collections/public/<id>`) arrives on the
    // same stream as shared web URLs. Route it to the read-only public view
    // instead of treating it as a URL to save. Pushing stacks above any
    // in-progress form, so no degrade is needed here.
    final publicCollectionId = SharedIntentService.extractPublicCollectionId(
      payload,
    );
    if (publicCollectionId != null) {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        unawaited(
          router.push(Routes.publicCollectionDetailPath(publicCollectionId)),
        );
      });
      return;
    }

    // Plugin path first; EXTRA_TEXT / ClipData fallback for YouTube shares.
    final url = await _resolver.resolveUrl(payload);
    if (!mounted) return;

    final location = router.routerDelegate.currentConfiguration.uri.path;
    final authState = ref.read(authProvider).value;
    final isAuthenticated = authState is Authenticated;
    final action = resolveWarmShareAction(
      extractedUrl: url,
      currentLocation: location,
      isAuthenticated: isAuthenticated,
    );

    // The listener callback can fire mid-frame; navigation and snackbars must
    // run after the current build to take effect.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      switch (action) {
        case WarmShareAction.navigate:
          unawaited(
            analytics.logShareUrlExtracted(
              appState: 'warm',
              sourceCategory: AnalyticsService.sourceCategoryForUrl(url!),
            ),
          );
          _openPrefill(router, url, entryState: 'warm_navigate');
        case WarmShareAction.deferUntilAuthenticated:
          unawaited(
            analytics.logShareUrlExtracted(
              appState: 'warm',
              sourceCategory: AnalyticsService.sourceCategoryForUrl(url!),
            ),
          );
          // Same pending contract as cold start — router consumes after login.
          ref.read(pendingSharedUrlProvider.notifier).setInitial(url);
        case WarmShareAction.degrade:
          unawaited(
            analytics.logShareUrlExtracted(
              appState: 'warm',
              sourceCategory: AnalyticsService.sourceCategoryForUrl(url!),
            ),
          );
          _showSnackBar(
            '공유한 링크를 받았어요.',
            actionLabel: '열기',
            onAction: () =>
                _openPrefill(router, url, entryState: 'warm_degrade'),
          );
        case WarmShareAction.toastFailure:
          appLogger.w(
            'Warm share: no URL from plugin path or EXTRA_TEXT',
          );
          unawaited(
            analytics.logShareUrlRejected(reasonCode: 'no_url'),
          );
          _showSnackBar('공유 내용에서 저장할 링크를 찾지 못했어요.');
      }
    });
  }

  void _openPrefill(
    GoRouter router,
    String url, {
    required String entryState,
  }) {
    unawaited(
      ref
          .read(analyticsServiceProvider)
          .logShareAddFormOpened(
            entryState: entryState,
          ),
    );
    unawaited(
      router.push('${Routes.linkAdd}?prefill=${Uri.encodeComponent(url)}'),
    );
  }

  void _showSnackBar(
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final messenger = widget.messengerKey.currentState;
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          action: actionLabel != null && onAction != null
              ? SnackBarAction(label: actionLabel, onPressed: onAction)
              : null,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(sharedMediaStreamProvider, _onShare);
    return widget.child;
  }
}
