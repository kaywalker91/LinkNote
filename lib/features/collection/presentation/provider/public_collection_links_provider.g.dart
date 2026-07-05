// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_collection_links_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Read-only links of a `public` collection (owner-agnostic).
///
/// App-level gate: it first resolves the parent collection via the public
/// detail usecase and only fetches links once that succeeds. If the parent is
/// absent / not public / RLS-blocked, the error propagates and the links fetch
/// is never issued — links are never surfaced for a collection that did not
/// resolve as public. (Gating on the usecase directly, rather than the detail
/// provider's future, keeps this a single async step — the screen still shares
/// the detail provider for the header.)

@ProviderFor(publicCollectionLinks)
final publicCollectionLinksProvider = PublicCollectionLinksFamily._();

/// Read-only links of a `public` collection (owner-agnostic).
///
/// App-level gate: it first resolves the parent collection via the public
/// detail usecase and only fetches links once that succeeds. If the parent is
/// absent / not public / RLS-blocked, the error propagates and the links fetch
/// is never issued — links are never surfaced for a collection that did not
/// resolve as public. (Gating on the usecase directly, rather than the detail
/// provider's future, keeps this a single async step — the screen still shares
/// the detail provider for the header.)

final class PublicCollectionLinksProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<LinkEntity>>,
          List<LinkEntity>,
          FutureOr<List<LinkEntity>>
        >
    with $FutureModifier<List<LinkEntity>>, $FutureProvider<List<LinkEntity>> {
  /// Read-only links of a `public` collection (owner-agnostic).
  ///
  /// App-level gate: it first resolves the parent collection via the public
  /// detail usecase and only fetches links once that succeeds. If the parent is
  /// absent / not public / RLS-blocked, the error propagates and the links fetch
  /// is never issued — links are never surfaced for a collection that did not
  /// resolve as public. (Gating on the usecase directly, rather than the detail
  /// provider's future, keeps this a single async step — the screen still shares
  /// the detail provider for the header.)
  PublicCollectionLinksProvider._({
    required PublicCollectionLinksFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'publicCollectionLinksProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$publicCollectionLinksHash();

  @override
  String toString() {
    return r'publicCollectionLinksProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<LinkEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<LinkEntity>> create(Ref ref) {
    final argument = this.argument as String;
    return publicCollectionLinks(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PublicCollectionLinksProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$publicCollectionLinksHash() =>
    r'f7adbe73b251bb3805f53991b8eeea0eecda0ec5';

/// Read-only links of a `public` collection (owner-agnostic).
///
/// App-level gate: it first resolves the parent collection via the public
/// detail usecase and only fetches links once that succeeds. If the parent is
/// absent / not public / RLS-blocked, the error propagates and the links fetch
/// is never issued — links are never surfaced for a collection that did not
/// resolve as public. (Gating on the usecase directly, rather than the detail
/// provider's future, keeps this a single async step — the screen still shares
/// the detail provider for the header.)

final class PublicCollectionLinksFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<LinkEntity>>, String> {
  PublicCollectionLinksFamily._()
    : super(
        retry: null,
        name: r'publicCollectionLinksProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Read-only links of a `public` collection (owner-agnostic).
  ///
  /// App-level gate: it first resolves the parent collection via the public
  /// detail usecase and only fetches links once that succeeds. If the parent is
  /// absent / not public / RLS-blocked, the error propagates and the links fetch
  /// is never issued — links are never surfaced for a collection that did not
  /// resolve as public. (Gating on the usecase directly, rather than the detail
  /// provider's future, keeps this a single async step — the screen still shares
  /// the detail provider for the header.)

  PublicCollectionLinksProvider call(String collectionId) =>
      PublicCollectionLinksProvider._(argument: collectionId, from: this);

  @override
  String toString() => r'publicCollectionLinksProvider';
}
