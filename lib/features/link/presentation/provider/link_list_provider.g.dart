// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'link_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Keep the global link list alive across navigation so pagination state
/// and cached items survive brief re-subscription (e.g., push/pop detail).

@ProviderFor(LinkList)
final linkListProvider = LinkListProvider._();

/// Keep the global link list alive across navigation so pagination state
/// and cached items survive brief re-subscription (e.g., push/pop detail).
final class LinkListProvider
    extends $AsyncNotifierProvider<LinkList, PaginatedState<LinkEntity>> {
  /// Keep the global link list alive across navigation so pagination state
  /// and cached items survive brief re-subscription (e.g., push/pop detail).
  LinkListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'linkListProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$linkListHash();

  @$internal
  @override
  LinkList create() => LinkList();
}

String _$linkListHash() => r'8c2c0798b6bd2050db07cfe2db45fa68c63700d3';

/// Keep the global link list alive across navigation so pagination state
/// and cached items survive brief re-subscription (e.g., push/pop detail).

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
