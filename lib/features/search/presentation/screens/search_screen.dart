import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linknote/app/router/routes.dart';
import 'package:linknote/app/theme/app_spacing.dart';
import 'package:linknote/features/search/presentation/provider/search_provider.dart';
import 'package:linknote/features/search/presentation/widgets/search_filter_bar.dart';
import 'package:linknote/features/search/presentation/widgets/search_suggestions_list.dart';
import 'package:linknote/shared/widgets/empty_state_widget.dart';
import 'package:linknote/shared/widgets/link_list_tile.dart';
import 'package:linknote/shared/widgets/skeleton/link_card_skeleton.dart';
import 'package:linknote/shared/widgets/tag_chip_widget.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onClearPressed() {
    _controller.clear();
    ref.read(searchProvider.notifier).clearSearch();
  }

  void _onSuggestionTap(String text) {
    _controller.text = text;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: text.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasQuery = ref.watch(
      searchProvider.select((s) => s.query.isNotEmpty),
    );
    final clearButton = hasQuery
        ? IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _onClearPressed,
          )
        : null;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: '링크, 메모, 태그 검색',
            border: InputBorder.none,
            suffixIcon: clearButton,
          ),
          onChanged: (v) => ref.read(searchProvider.notifier).updateQuery(v),
          onSubmitted: (v) =>
              ref.read(searchProvider.notifier).addRecentSearch(v),
        ),
      ),
      body: Column(
        children: [
          const SearchFilterBar(),
          Expanded(child: _SearchBody(onSuggestionTap: _onSuggestionTap)),
        ],
      ),
    );
  }
}

class _SearchBody extends ConsumerWidget {
  const _SearchBody({required this.onSuggestionTap});

  final ValueChanged<String> onSuggestionTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(searchProvider);

    if (state.query.isEmpty) {
      if (state.recentSearches.isEmpty) {
        return const EmptyStateWidget(
          icon: Icons.search,
          message: '링크를 검색하세요',
          subMessage: '키워드를 입력하여 저장된 링크를 찾아보세요',
        );
      }
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '최근 검색',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                TextButton(
                  onPressed: () =>
                      ref.read(searchProvider.notifier).clearRecentSearches(),
                  child: const Text('전체 삭제'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: state.recentSearches
                  .map(
                    (q) => TagChipWidget(
                      label: q,
                      onTap: () {
                        ref.read(searchProvider.notifier).updateQuery(q);
                        onSuggestionTap(q);
                      },
                      onDelete: () => ref
                          .read(searchProvider.notifier)
                          .removeRecentSearch(
                            q,
                          ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      );
    }

    if (state.isSearching) {
      return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        itemBuilder: (_, __) => const LinkCardSkeleton(),
      );
    }

    if (state.results.isEmpty) {
      return Column(
        children: [
          SearchSuggestionsListWidget(onSuggestionTap: onSuggestionTap),
          Expanded(
            child: EmptyStateWidget(
              icon: Icons.search_off_outlined,
              message: '"${state.query}" 검색 결과 없음',
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        SearchSuggestionsListWidget(onSuggestionTap: onSuggestionTap),
        Expanded(
          child: ListView.builder(
            itemCount: state.results.length,
            itemBuilder: (context, index) {
              final link = state.results[index];
              return LinkListTile(
                link: link,
                onTap: () => context.push(Routes.linkDetailPath(link.id)),
                onFavoriteTap: () =>
                    ref.read(searchProvider.notifier).toggleFavorite(link.id),
              );
            },
          ),
        ),
      ],
    );
  }
}
