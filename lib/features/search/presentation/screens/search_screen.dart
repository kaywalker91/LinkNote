import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linknote/app/router/routes.dart';
import 'package:linknote/app/theme/app_spacing.dart';
import 'package:linknote/features/search/domain/entity/search_state_entity.dart';
import 'package:linknote/features/search/presentation/provider/search_provider.dart';
import 'package:linknote/shared/widgets/empty_state_widget.dart';
import 'package:linknote/shared/widgets/link_list_tile.dart';
import 'package:linknote/shared/widgets/tag_chip_widget.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: false,
          decoration: InputDecoration(
            hintText: 'Search links, notes, tags',
            border: InputBorder.none,
            suffixIcon: searchState.query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                      ref.read(searchProvider.notifier).clearSearch();
                    },
                  )
                : null,
          ),
          onChanged: (v) => ref.read(searchProvider.notifier).updateQuery(v),
          onSubmitted: (v) {
            ref.read(searchProvider.notifier).addRecentSearch(v);
          },
        ),
      ),
      body: _SearchBody(searchState: searchState),
    );
  }
}

class _SearchBody extends ConsumerWidget {
  const _SearchBody({required this.searchState});
  final SearchStateEntity searchState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(searchProvider);

    if (state.query.isEmpty) {
      if (state.recentSearches.isEmpty) {
        return const EmptyStateWidget(
          icon: Icons.search,
          message: 'Search for links',
          subMessage: 'Enter keywords to find your saved links',
        );
      }
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent searches',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: state.recentSearches
                  .map(
                    (q) => TagChipWidget(
                      label: q,
                      onTap: () =>
                          ref.read(searchProvider.notifier).updateQuery(q),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      );
    }

    if (state.isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.results.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.search_off_outlined,
        message: 'No results for "${state.query}"',
      );
    }

    return ListView.builder(
      itemCount: state.results.length,
      itemBuilder: (context, index) {
        final link = state.results[index];
        return LinkListTile(
          link: link,
          onTap: () => context.push(Routes.linkDetailPath(link.id)),
          onFavoriteTap:
              () {}, // TODO(linknote): Wire to toggleFavorite usecase
        );
      },
    );
  }
}
