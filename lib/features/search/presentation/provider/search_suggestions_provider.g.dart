// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_suggestions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(searchSuggestions)
final searchSuggestionsProvider = SearchSuggestionsProvider._();

final class SearchSuggestionsProvider
    extends
        $FunctionalProvider<
          List<SearchSuggestion>,
          List<SearchSuggestion>,
          List<SearchSuggestion>
        >
    with $Provider<List<SearchSuggestion>> {
  SearchSuggestionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchSuggestionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchSuggestionsHash();

  @$internal
  @override
  $ProviderElement<List<SearchSuggestion>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<SearchSuggestion> create(Ref ref) {
    return searchSuggestions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<SearchSuggestion> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<SearchSuggestion>>(value),
    );
  }
}

String _$searchSuggestionsHash() => r'd4002bc7d319d8ba7ed30534c1da7aa40b015b8b';
