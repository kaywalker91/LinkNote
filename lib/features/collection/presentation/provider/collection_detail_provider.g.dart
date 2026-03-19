// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_detail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CollectionDetail)
final collectionDetailProvider = CollectionDetailFamily._();

final class CollectionDetailProvider
    extends $AsyncNotifierProvider<CollectionDetail, CollectionEntity> {
  CollectionDetailProvider._({
    required CollectionDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'collectionDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$collectionDetailHash();

  @override
  String toString() {
    return r'collectionDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CollectionDetail create() => CollectionDetail();

  @override
  bool operator ==(Object other) {
    return other is CollectionDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$collectionDetailHash() => r'b2c6893e3d992c7badc9e63da858950493d718d2';

final class CollectionDetailFamily extends $Family
    with
        $ClassFamilyOverride<
          CollectionDetail,
          AsyncValue<CollectionEntity>,
          CollectionEntity,
          FutureOr<CollectionEntity>,
          String
        > {
  CollectionDetailFamily._()
    : super(
        retry: null,
        name: r'collectionDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CollectionDetailProvider call(String collectionId) =>
      CollectionDetailProvider._(argument: collectionId, from: this);

  @override
  String toString() => r'collectionDetailProvider';
}

abstract class _$CollectionDetail extends $AsyncNotifier<CollectionEntity> {
  late final _$args = ref.$arg as String;
  String get collectionId => _$args;

  FutureOr<CollectionEntity> build(String collectionId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<CollectionEntity>, CollectionEntity>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<CollectionEntity>, CollectionEntity>,
              AsyncValue<CollectionEntity>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
