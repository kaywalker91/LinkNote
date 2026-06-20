// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_public_collection_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// One-shot holder for a cold-start public-collection deep link.
///
/// `linknote://` deep links arrive through `receive_sharing_intent` (the OS
/// routes the VIEW intent to the activity, the plugin delivers it as a
/// `SharedMediaFile`), not Flutter's built-in deep linking. Bootstrap
/// classifies a `linknote:///collections/public/<id>` payload from
/// `getInitialMedia()` and seeds the target location here; the GoRouter
/// redirect consumes it once — after auth resolves — to land on the read-only
/// public view. Mirrors [PendingSharedUrl] (the URL-to-save sibling).

@ProviderFor(PendingPublicCollection)
final pendingPublicCollectionProvider = PendingPublicCollectionProvider._();

/// One-shot holder for a cold-start public-collection deep link.
///
/// `linknote://` deep links arrive through `receive_sharing_intent` (the OS
/// routes the VIEW intent to the activity, the plugin delivers it as a
/// `SharedMediaFile`), not Flutter's built-in deep linking. Bootstrap
/// classifies a `linknote:///collections/public/<id>` payload from
/// `getInitialMedia()` and seeds the target location here; the GoRouter
/// redirect consumes it once — after auth resolves — to land on the read-only
/// public view. Mirrors [PendingSharedUrl] (the URL-to-save sibling).
final class PendingPublicCollectionProvider
    extends $NotifierProvider<PendingPublicCollection, String?> {
  /// One-shot holder for a cold-start public-collection deep link.
  ///
  /// `linknote://` deep links arrive through `receive_sharing_intent` (the OS
  /// routes the VIEW intent to the activity, the plugin delivers it as a
  /// `SharedMediaFile`), not Flutter's built-in deep linking. Bootstrap
  /// classifies a `linknote:///collections/public/<id>` payload from
  /// `getInitialMedia()` and seeds the target location here; the GoRouter
  /// redirect consumes it once — after auth resolves — to land on the read-only
  /// public view. Mirrors [PendingSharedUrl] (the URL-to-save sibling).
  PendingPublicCollectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingPublicCollectionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingPublicCollectionHash();

  @$internal
  @override
  PendingPublicCollection create() => PendingPublicCollection();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$pendingPublicCollectionHash() =>
    r'c6c785a665de659b9e857f9519732ff59d79d8e8';

/// One-shot holder for a cold-start public-collection deep link.
///
/// `linknote://` deep links arrive through `receive_sharing_intent` (the OS
/// routes the VIEW intent to the activity, the plugin delivers it as a
/// `SharedMediaFile`), not Flutter's built-in deep linking. Bootstrap
/// classifies a `linknote:///collections/public/<id>` payload from
/// `getInitialMedia()` and seeds the target location here; the GoRouter
/// redirect consumes it once — after auth resolves — to land on the read-only
/// public view. Mirrors [PendingSharedUrl] (the URL-to-save sibling).

abstract class _$PendingPublicCollection extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
