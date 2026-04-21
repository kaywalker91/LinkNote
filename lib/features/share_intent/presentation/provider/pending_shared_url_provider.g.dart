// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_shared_url_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// One-shot holder for a URL delivered via cold-start share intent.
///
/// Bootstrap seeds this from `ReceiveSharingIntent.getInitialMedia()` before
/// `runApp`; the GoRouter redirect consumes it once — after auth resolves —
/// to land the user on `/links/new?prefill=...`. Subsequent reads see `null`.

@ProviderFor(PendingSharedUrl)
final pendingSharedUrlProvider = PendingSharedUrlProvider._();

/// One-shot holder for a URL delivered via cold-start share intent.
///
/// Bootstrap seeds this from `ReceiveSharingIntent.getInitialMedia()` before
/// `runApp`; the GoRouter redirect consumes it once — after auth resolves —
/// to land the user on `/links/new?prefill=...`. Subsequent reads see `null`.
final class PendingSharedUrlProvider
    extends $NotifierProvider<PendingSharedUrl, String?> {
  /// One-shot holder for a URL delivered via cold-start share intent.
  ///
  /// Bootstrap seeds this from `ReceiveSharingIntent.getInitialMedia()` before
  /// `runApp`; the GoRouter redirect consumes it once — after auth resolves —
  /// to land the user on `/links/new?prefill=...`. Subsequent reads see `null`.
  PendingSharedUrlProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingSharedUrlProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingSharedUrlHash();

  @$internal
  @override
  PendingSharedUrl create() => PendingSharedUrl();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$pendingSharedUrlHash() => r'31321074c12aa099381bcbd0987928656175aa5a';

/// One-shot holder for a URL delivered via cold-start share intent.
///
/// Bootstrap seeds this from `ReceiveSharingIntent.getInitialMedia()` before
/// `runApp`; the GoRouter redirect consumes it once — after auth resolves —
/// to land the user on `/links/new?prefill=...`. Subsequent reads see `null`.

abstract class _$PendingSharedUrl extends $Notifier<String?> {
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
