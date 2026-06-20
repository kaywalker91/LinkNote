import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linknote/app/router/app_router.dart';
import 'package:linknote/app/router/routes.dart';
import 'package:linknote/features/share_intent/domain/service/shared_intent_service.dart';
import 'package:linknote/features/share_intent/presentation/provider/shared_media_stream_provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

/// What to do with a warm/foreground share intent.
enum WarmShareAction {
  /// A URL was salvaged and no in-progress form is at risk — open the
  /// prefill form directly.
  navigate,

  /// A URL was salvaged but the user is editing a form. Don't clobber their
  /// input; surface a snackbar that lets them opt in.
  degrade,

  /// The payload carried no usable URL — tell the user it couldn't be saved.
  toastFailure,
}

/// Pure decision for a warm share, given the extracted URL and where the user
/// currently is. Extracted for unit testing without the widget tree.
WarmShareAction resolveWarmShareAction({
  required String? extractedUrl,
  required String currentLocation,
}) {
  if (extractedUrl == null) return WarmShareAction.toastFailure;
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
    super.key,
  });

  final Widget child;

  /// The app's [ScaffoldMessenger] key. The listener sits above the messenger
  /// in `MaterialApp.router`'s `builder`, so it shows snackbars through the key
  /// rather than an (absent) ancestor lookup.
  final GlobalKey<ScaffoldMessengerState> messengerKey;

  @override
  ConsumerState<ShareIntentListener> createState() =>
      _ShareIntentListenerState();
}

class _ShareIntentListenerState extends ConsumerState<ShareIntentListener> {
  void _onShare(
    AsyncValue<List<SharedMediaFile>>? previous,
    AsyncValue<List<SharedMediaFile>> next,
  ) {
    final media = next.value;
    if (media == null || media.isEmpty) return;

    final payload = media.first.path;
    final router = ref.read(appRouterProvider);

    // Internal deep link (`linknote://collections/public/<id>`) arrives on the
    // same stream as shared web URLs. Route it to the read-only public view
    // instead of treating it as a URL to save. Pushing stacks above any
    // in-progress form, so no degrade is needed here.
    final publicCollectionId = SharedIntentService.extractPublicCollectionId(
      payload,
    );
    if (publicCollectionId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        unawaited(
          router.push(Routes.publicCollectionDetailPath(publicCollectionId)),
        );
      });
      return;
    }

    final url = SharedIntentService.extractUrl(payload);
    final location = router.routerDelegate.currentConfiguration.uri.path;
    final action = resolveWarmShareAction(
      extractedUrl: url,
      currentLocation: location,
    );

    // The listener callback can fire mid-frame; navigation and snackbars must
    // run after the current build to take effect.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      switch (action) {
        case WarmShareAction.navigate:
          _openPrefill(router, url!);
        case WarmShareAction.degrade:
          _showSnackBar(
            'Shared link received',
            actionLabel: 'Open',
            onAction: () => _openPrefill(router, url!),
          );
        case WarmShareAction.toastFailure:
          _showSnackBar("Couldn't find a URL in the shared content");
      }
    });
  }

  void _openPrefill(GoRouter router, String url) {
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
