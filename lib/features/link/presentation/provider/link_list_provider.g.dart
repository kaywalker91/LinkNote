// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'link_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LinkList)
final linkListProvider = LinkListProvider._();

final class LinkListProvider
    extends $AsyncNotifierProvider<LinkList, PaginatedState<LinkEntity>> {
  LinkListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'linkListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$linkListHash();

  @$internal
  @override
  LinkList create() => LinkList();
}

String _$linkListHash() => r'bceab0bdbd97cf135d761d93a843ac72cb2d4ff3';

abstract class _$LinkList extends $AsyncNotifier<PaginatedState<LinkEntity>> {
  FutureOr<PaginatedState<LinkEntity>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<PaginatedState<LinkEntity>>,
              PaginatedState<LinkEntity>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PaginatedState<LinkEntity>>,
                PaginatedState<LinkEntity>
              >,
              AsyncValue<PaginatedState<LinkEntity>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
