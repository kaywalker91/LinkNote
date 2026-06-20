// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_collection_links_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Read-only links of a `public` collection (owner-agnostic).
///
/// App-level gate: it first awaits [publicCollectionDetailProvider] so the
/// links are only fetched after the parent collection resolves as public. If
/// the parent errors (absent / not public / RLS-blocked), that error
/// propagates and the links fetch is never issued — links are never surfaced
/// for a collection that did not resolve as public.

@ProviderFor(publicCollectionLinks)
final publicCollectionLinksProvider = PublicCollectionLinksFamily._();

/// Read-only links of a `public` collection (owner-agnostic).
///
/// App-level gate: it first awaits [publicCollectionDetailProvider] so the
/// links are only fetched after the parent collection resolves as public. If
/// the parent errors (absent / not public / RLS-blocked), that error
/// propagates and the links fetch is never issued — links are never surfaced
/// for a collection that did not resolve as public.

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
  /// App-level gate: it first awaits [publicCollectionDetailProvider] so the
  /// links are only fetched after the parent collection resolves as public. If
  /// the parent errors (absent / not public / RLS-blocked), that error
  /// propagates and the links fetch is never issued — links are never surfaced
  /// for a collection that did not resolve as public.
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
    r'863b6485cbc697338218d5443877fef7d73a2f2c';

/// Read-only links of a `public` collection (owner-agnostic).
///
/// App-level gate: it first awaits [publicCollectionDetailProvider] so the
/// links are only fetched after the parent collection resolves as public. If
/// the parent errors (absent / not public / RLS-blocked), that error
/// propagates and the links fetch is never issued — links are never surfaced
/// for a collection that did not resolve as public.

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
  /// App-level gate: it first awaits [publicCollectionDetailProvider] so the
  /// links are only fetched after the parent collection resolves as public. If
  /// the parent errors (absent / not public / RLS-blocked), that error
  /// propagates and the links fetch is never issued — links are never surfaced
  /// for a collection that did not resolve as public.

  PublicCollectionLinksProvider call(String collectionId) =>
      PublicCollectionLinksProvider._(argument: collectionId, from: this);

  @override
  String toString() => r'publicCollectionLinksProvider';
}
