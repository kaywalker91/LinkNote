// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_collection_detail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Read-only public collection detail (owner-agnostic).
///
/// Resolves a `public` collection by id via [GetPublicCollectionDetailUsecase],
/// which never scopes by the caller's `user_id`. Throws the [Failure] when the
/// collection is absent or not public, so the UI degrades to an error state.

@ProviderFor(publicCollectionDetail)
final publicCollectionDetailProvider = PublicCollectionDetailFamily._();

/// Read-only public collection detail (owner-agnostic).
///
/// Resolves a `public` collection by id via [GetPublicCollectionDetailUsecase],
/// which never scopes by the caller's `user_id`. Throws the [Failure] when the
/// collection is absent or not public, so the UI degrades to an error state.

final class PublicCollectionDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<CollectionEntity>,
          CollectionEntity,
          FutureOr<CollectionEntity>
        >
    with $FutureModifier<CollectionEntity>, $FutureProvider<CollectionEntity> {
  /// Read-only public collection detail (owner-agnostic).
  ///
  /// Resolves a `public` collection by id via [GetPublicCollectionDetailUsecase],
  /// which never scopes by the caller's `user_id`. Throws the [Failure] when the
  /// collection is absent or not public, so the UI degrades to an error state.
  PublicCollectionDetailProvider._({
    required PublicCollectionDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'publicCollectionDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$publicCollectionDetailHash();

  @override
  String toString() {
    return r'publicCollectionDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<CollectionEntity> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CollectionEntity> create(Ref ref) {
    final argument = this.argument as String;
    return publicCollectionDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PublicCollectionDetailProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$publicCollectionDetailHash() =>
    r'0be98e22e0261c3afaca4079e33f1aeb27eb2617';

/// Read-only public collection detail (owner-agnostic).
///
/// Resolves a `public` collection by id via [GetPublicCollectionDetailUsecase],
/// which never scopes by the caller's `user_id`. Throws the [Failure] when the
/// collection is absent or not public, so the UI degrades to an error state.

final class PublicCollectionDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<CollectionEntity>, String> {
  PublicCollectionDetailFamily._()
    : super(
        retry: null,
        name: r'publicCollectionDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Read-only public collection detail (owner-agnostic).
  ///
  /// Resolves a `public` collection by id via [GetPublicCollectionDetailUsecase],
  /// which never scopes by the caller's `user_id`. Throws the [Failure] when the
  /// collection is absent or not public, so the UI degrades to an error state.

  PublicCollectionDetailProvider call(String collectionId) =>
      PublicCollectionDetailProvider._(argument: collectionId, from: this);

  @override
  String toString() => r'publicCollectionDetailProvider';
}
