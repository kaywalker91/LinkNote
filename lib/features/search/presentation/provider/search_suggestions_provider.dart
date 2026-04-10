import 'package:linknote/features/search/presentation/provider/search_provider.dart';
import 'package:linknote/features/search/presentation/provider/user_tags_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_suggestions_provider.g.dart';

enum SuggestionType { recent, tag }

class SearchSuggestion {
  const SearchSuggestion({
    required this.text,
    required this.type,
  });

  final String text;
  final SuggestionType type;
}

@riverpod
List<SearchSuggestion> searchSuggestions(Ref ref) {
  final searchState = ref.watch(searchProvider);
  final query = searchState.query.toLowerCase().trim();

  if (query.isEmpty) return [];

  final suggestions = <SearchSuggestion>[];

  // Recent searches matching the query prefix.
  for (final recent in searchState.recentSearches) {
    if (recent.toLowerCase().startsWith(query) && recent != query) {
      suggestions.add(
        SearchSuggestion(text: recent, type: SuggestionType.recent),
      );
    }
  }

  // Tag names matching the query prefix.
  ref.watch(userTagsProvider).whenData((tags) {
    for (final tag in tags) {
      if (tag.name.toLowerCase().startsWith(query)) {
        suggestions.add(
          SearchSuggestion(text: tag.name, type: SuggestionType.tag),
        );
      }
    }
  });

  // Deduplicate by text, keep first occurrence.
  final seen = <String>{};
  final unique = <SearchSuggestion>[];
  for (final s in suggestions) {
    if (seen.add(s.text.toLowerCase())) {
      unique.add(s);
    }
  }

  return unique.take(8).toList();
}
