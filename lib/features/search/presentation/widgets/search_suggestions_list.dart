import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linknote/app/theme/app_spacing.dart';
import 'package:linknote/features/search/presentation/provider/search_provider.dart';
import 'package:linknote/features/search/presentation/provider/search_suggestions_provider.dart';

class SearchSuggestionsListWidget extends ConsumerWidget {
  const SearchSuggestionsListWidget({
    required this.onSuggestionTap,
    super.key,
  });

  final ValueChanged<String> onSuggestionTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestions = ref.watch(searchSuggestionsProvider);

    if (suggestions.isEmpty) return const SizedBox.shrink();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
      ),
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return ListTile(
          dense: true,
          leading: Icon(
            suggestion.type == SuggestionType.recent
                ? Icons.history
                : Icons.tag,
            size: 20,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          title: Text(suggestion.text),
          onTap: () {
            ref.read(searchProvider.notifier)
              ..addRecentSearch(suggestion.text)
              ..updateQuery(suggestion.text);
            onSuggestionTap(suggestion.text);
          },
        );
      },
    );
  }
}
