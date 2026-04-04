// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_di_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(searchRemoteDataSource)
final searchRemoteDataSourceProvider = SearchRemoteDataSourceProvider._();

final class SearchRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          SearchRemoteDataSource,
          SearchRemoteDataSource,
          SearchRemoteDataSource
        >
    with $Provider<SearchRemoteDataSource> {
  SearchRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchRemoteDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<SearchRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SearchRemoteDataSource create(Ref ref) {
    return searchRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchRemoteDataSource>(value),
    );
  }
}

String _$searchRemoteDataSourceHash() =>
    r'1d27e9e2df335fc88e063ba8d2bef9969b5659e3';

@ProviderFor(searchRepository)
final searchRepositoryProvider = SearchRepositoryProvider._();

final class SearchRepositoryProvider
    extends
        $FunctionalProvider<
          ISearchRepository,
          ISearchRepository,
          ISearchRepository
        >
    with $Provider<ISearchRepository> {
  SearchRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchRepositoryHash();

  @$internal
  @override
  $ProviderElement<ISearchRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ISearchRepository create(Ref ref) {
    return searchRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ISearchRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ISearchRepository>(value),
    );
  }
}

String _$searchRepositoryHash() => r'7141644a0169bf0fb07599d913d9d7da25ecc7e2';

@ProviderFor(searchLinksUsecase)
final searchLinksUsecaseProvider = SearchLinksUsecaseProvider._();

final class SearchLinksUsecaseProvider
    extends
        $FunctionalProvider<
          SearchLinksUsecase,
          SearchLinksUsecase,
          SearchLinksUsecase
        >
    with $Provider<SearchLinksUsecase> {
  SearchLinksUsecaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchLinksUsecaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchLinksUsecaseHash();

  @$internal
  @override
  $ProviderElement<SearchLinksUsecase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SearchLinksUsecase create(Ref ref) {
    return searchLinksUsecase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchLinksUsecase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchLinksUsecase>(value),
    );
  }
}

String _$searchLinksUsecaseHash() =>
    r'd2ab1e1bb7db755676457dc896eb03de8807deda';
