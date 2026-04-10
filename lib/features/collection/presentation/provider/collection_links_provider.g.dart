// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_links_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(collectionLinks)
final collectionLinksProvider = CollectionLinksFamily._();

final class CollectionLinksProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<LinkEntity>>,
          List<LinkEntity>,
          FutureOr<List<LinkEntity>>
        >
    with $FutureModifier<List<LinkEntity>>, $FutureProvider<List<LinkEntity>> {
  CollectionLinksProvider._({
    required CollectionLinksFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'collectionLinksProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$collectionLinksHash();

  @override
  String toString() {
    return r'collectionLinksProvider'
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
    return collectionLinks(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CollectionLinksProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$collectionLinksHash() => r'f8f6647d4d3be7baecb47541a1e906168857085c';

final class CollectionLinksFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<LinkEntity>>, String> {
  CollectionLinksFamily._()
    : super(
        retry: null,
        name: r'collectionLinksProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CollectionLinksProvider call(String collectionId) =>
      CollectionLinksProvider._(argument: collectionId, from: this);

  @override
  String toString() => r'collectionLinksProvider';
}
