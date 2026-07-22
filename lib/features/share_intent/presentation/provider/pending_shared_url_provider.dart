import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pending_shared_url_provider.g.dart';

/// One-shot holder for a URL delivered via share intent (cold or warm).
///
/// Cold path: bootstrap seeds this from
/// `ReceiveSharingIntent.getInitialMedia()` before `runApp`.
/// Warm path: ShareIntentListener seeds this when the user is not yet
/// authenticated (`deferUntilAuthenticated`).
///
/// GoRouter redirect consumes it once — after auth resolves — to land the
/// user on `/links/new?prefill=...`. Subsequent reads see `null`.
@Riverpod(keepAlive: true)
class PendingSharedUrl extends _$PendingSharedUrl {
  @override
  String? build() => null;

  /// Seed the pending URL. No-op when [url] is null or empty so a missing
  /// payload cannot clobber a previously-set value. A newer non-empty URL
  /// replaces an older pending value (last-write-wins for consecutive shares).
  void setInitial(String? url) {
    if (url == null || url.isEmpty) return;
    state = url;
  }

  void consume() {
    state = null;
  }
}
