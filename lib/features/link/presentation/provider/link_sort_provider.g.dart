// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'link_sort_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LinkSortNotifier)
final linkSortProvider = LinkSortNotifierProvider._();

final class LinkSortNotifierProvider
    extends $NotifierProvider<LinkSortNotifier, LinkSortOrder> {
  LinkSortNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'linkSortProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$linkSortNotifierHash();

  @$internal
  @override
  LinkSortNotifier create() => LinkSortNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LinkSortOrder value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LinkSortOrder>(value),
    );
  }
}

String _$linkSortNotifierHash() => r'1339ed81a3208241bae22e92fae7b8e06103e75e';

abstract class _$LinkSortNotifier extends $Notifier<LinkSortOrder> {
  LinkSortOrder build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<LinkSortOrder, LinkSortOrder>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LinkSortOrder, LinkSortOrder>,
              LinkSortOrder,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
