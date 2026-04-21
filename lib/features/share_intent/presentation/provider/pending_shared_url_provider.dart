import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pending_shared_url_provider.g.dart';

/// One-shot holder for a URL delivered via cold-start share intent.
///
/// Bootstrap seeds this from `ReceiveSharingIntent.getInitialMedia()` before
/// `runApp`; the GoRouter redirect consumes it once — after auth resolves —
/// to land the user on `/links/new?prefill=...`. Subsequent reads see `null`.
@Riverpod(keepAlive: true)
class PendingSharedUrl extends _$PendingSharedUrl {
  @override
  String? build() => null;

  /// Seed the pending URL at boot. No-op when [url] is null or empty so a
  /// missing cold-start payload cannot clobber a previously-set value.
  void setInitial(String? url) {
    if (url == null || url.isEmpty) return;
    state = url;
  }

  void consume() {
    state = null;
  }
}
