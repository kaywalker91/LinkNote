import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linknote/app/router/routes.dart';
import 'package:linknote/app/theme/app_colors.dart';
import 'package:linknote/app/theme/app_radius.dart';
import 'package:linknote/app/theme/app_spacing.dart';
import 'package:linknote/app/theme/app_text_styles.dart';
import 'package:linknote/features/search/presentation/provider/search_provider.dart';
import 'package:linknote/features/search/presentation/widgets/search_filter_bar.dart';
import 'package:linknote/features/search/presentation/widgets/search_suggestions_list.dart';
import 'package:linknote/shared/utils/url_launcher_helper.dart';
import 'package:linknote/shared/widgets/empty_state_illustration.dart';
import 'package:linknote/shared/widgets/empty_state_widget.dart';
import 'package:linknote/shared/widgets/ln/ln_icon_btn.dart';
import 'package:linknote/shared/widgets/ln/ln_link_card.dart';
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

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        surfaceTintColor: AppColors.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        shape: const Border(bottom: BorderSide(color: AppColors.line)),
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
            vertical: AppSpacing.xs,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.bgSunk,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.line),
            ),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                const Icon(
                  Icons.search,
                  size: 20,
                  color: AppColors.ink3,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    cursorColor: AppColors.forest,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.ink,
                    ),
                    decoration: InputDecoration(
                      hintText: '링크, 메모, 태그 검색',
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.ink3,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onChanged: (v) =>
                        ref.read(searchProvider.notifier).updateQuery(v),
                    onSubmitted: (v) =>
                        ref.read(searchProvider.notifier).addRecentSearch(v),
                  ),
                ),
                if (hasQuery)
                  LnIconBtn(
                    icon: Icons.close_rounded,
                    color: AppColors.ink3,
                    onPressed: _onClearPressed,
                  ),
              ],
            ),
          ),
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
    final hasActiveFilter = state.filter.hasActiveFilters;

    if (state.query.isEmpty && !hasActiveFilter) {
      if (state.recentSearches.isEmpty) {
        return const EmptyStateWidget(
          illustration: EmptyStateIllustration.search(),
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
                  style: AppTextStyles.label.copyWith(color: AppColors.ink2),
                ),
                TextButton(
                  onPressed: () =>
                      ref.read(searchProvider.notifier).clearRecentSearches(),
                  child: Text(
                    '전체 삭제',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.forest,
                    ),
                  ),
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
      final emptyMessage = state.query.isNotEmpty
          ? '"${state.query}" 검색 결과 없음'
          : '검색 결과 없음';
      return Column(
        children: [
          SearchSuggestionsListWidget(onSuggestionTap: onSuggestionTap),
          Expanded(
            child: EmptyStateWidget(
              illustration: const EmptyStateIllustration.noResults(),
              message: emptyMessage,
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
              return LnLinkCard(
                link: link,
                highlightText: state.query,
                onTap: () => UrlLauncherHelper.launch(context, link.url),
                onLongPress: () => context.push(Routes.linkDetailPath(link.id)),
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
