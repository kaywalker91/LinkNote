// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'link_filter_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LinkFilterNotifier)
final linkFilterProvider = LinkFilterNotifierProvider._();

final class LinkFilterNotifierProvider
    extends $NotifierProvider<LinkFilterNotifier, LinkFilter> {
  LinkFilterNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'linkFilterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$linkFilterNotifierHash();

  @$internal
  @override
  LinkFilterNotifier create() => LinkFilterNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LinkFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LinkFilter>(value),
    );
  }
}

String _$linkFilterNotifierHash() =>
    r'596e5028358093d002bbed9f9eb95824e49ad630';

abstract class _$LinkFilterNotifier extends $Notifier<LinkFilter> {
  LinkFilter build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<LinkFilter, LinkFilter>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LinkFilter, LinkFilter>,
              LinkFilter,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
