// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CollectionList)
final collectionListProvider = CollectionListProvider._();

final class CollectionListProvider
    extends
        $AsyncNotifierProvider<
          CollectionList,
          PaginatedState<CollectionEntity>
        > {
  CollectionListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'collectionListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$collectionListHash();

  @$internal
  @override
  CollectionList create() => CollectionList();
}

String _$collectionListHash() => r'c38e6d499e658093c479fc7153cd02e7f0cc7fb4';

abstract class _$CollectionList
    extends $AsyncNotifier<PaginatedState<CollectionEntity>> {
  FutureOr<PaginatedState<CollectionEntity>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<PaginatedState<CollectionEntity>>,
              PaginatedState<CollectionEntity>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PaginatedState<CollectionEntity>>,
                PaginatedState<CollectionEntity>
              >,
              AsyncValue<PaginatedState<CollectionEntity>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
