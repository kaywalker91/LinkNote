// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Search)
final searchProvider = SearchProvider._();

final class SearchProvider
    extends $NotifierProvider<Search, SearchStateEntity> {
  SearchProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchHash();

  @$internal
  @override
  Search create() => Search();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchStateEntity value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchStateEntity>(value),
    );
  }
}

String _$searchHash() => r'489c8023febdc46b0ad38119c82c1abb80af71f1';

abstract class _$Search extends $Notifier<SearchStateEntity> {
  SearchStateEntity build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SearchStateEntity, SearchStateEntity>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SearchStateEntity, SearchStateEntity>,
              SearchStateEntity,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
