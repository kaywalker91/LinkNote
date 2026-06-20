import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pending_public_collection_provider.g.dart';

/// One-shot holder for a cold-start public-collection deep link.
///
/// `linknote://` deep links arrive through `receive_sharing_intent` (the OS
/// routes the VIEW intent to the activity, the plugin delivers it as a
/// `SharedMediaFile`), not Flutter's built-in deep linking. Bootstrap
/// classifies a `linknote:///collections/public/<id>` payload from
/// `getInitialMedia()` and seeds the target location here; the GoRouter
/// redirect consumes it once — after auth resolves — to land on the read-only
/// public view. Mirrors `PendingSharedUrl` (the URL-to-save sibling).
@Riverpod(keepAlive: true)
class PendingPublicCollection extends _$PendingPublicCollection {
  @override
  String? build() => null;

  /// Seed the pending location. No-op when [location] is null or empty so a
  /// missing payload cannot clobber a previously-set value.
  void setInitial(String? location) {
    if (location == null || location.isEmpty) return;
    state = location;
  }

  void consume() {
    state = null;
  }
}
