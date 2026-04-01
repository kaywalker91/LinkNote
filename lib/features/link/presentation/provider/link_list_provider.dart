import 'package:linknote/core/constants/app_constants.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/features/link/presentation/provider/link_filter_provider.dart';
import 'package:linknote/shared/models/paginated_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'link_list_provider.g.dart';

@riverpod
class LinkList extends _$LinkList {
  @override
  Future<PaginatedState<LinkEntity>> build() async {
    final filter = ref.watch(linkFilterProvider);
    return _fetch(favoritesOnly: filter.favoritesOnly);
  }

  Future<PaginatedState<LinkEntity>> _fetch({
    String? cursor,
    bool favoritesOnly = false,
  }) async {
    // TODO(linknote): Inject ILinkRepository and use FetchLinksUsecase.
    // Returning mock state until repository is wired up.
    await Future.delayed(const Duration(milliseconds: 500));
    return PaginatedState<LinkEntity>(
      items: _mockLinks(),
    );
  }

  Future<void> refresh() async {
    final filter = ref.read(linkFilterProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _fetch(favoritesOnly: filter.favoritesOnly),
    );
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.isLoadingMore) return;
    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final filter = ref.read(linkFilterProvider);
      final next = await _fetch(
        cursor: current.nextCursor,
        favoritesOnly: filter.favoritesOnly,
      );
      state = AsyncData(
        current.copyWith(
          items: [...current.items, ...next.items],
          hasMore: next.hasMore,
          nextCursor: next.nextCursor,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      state = AsyncData(
        current.copyWith(
          isLoadingMore: false,
          loadMoreError: e,
        ),
      );
    }
  }

  Future<void> deleteLink(String id) async {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        items: current.items.where((link) => link.id != id).toList(),
      ),
    );
    // TODO(linknote): Call DeleteLinkUsecase
  }

  /// Optimistic favorite toggle — immediately updates UI, rolls back on failure.
  Future<void> toggleFavorite(String id) async {
    final current = state.value;
    if (current == null) return;

    // Optimistic update
    final updatedItems = current.items.map((link) {
      if (link.id == id) return link.copyWith(isFavorite: !link.isFavorite);
      return link;
    }).toList();
    state = AsyncData(current.copyWith(items: updatedItems));

    // TODO(linknote): Call ToggleFavoriteUsecase — roll back on failure.
  }

  List<LinkEntity> _mockLinks() {
    return List.generate(
      AppConstants.defaultPageSize,
      (i) => LinkEntity(
        id: 'link_$i',
        url: 'https://example.com/article-$i',
        title: 'Sample Link $i',
        createdAt: DateTime.now().subtract(Duration(hours: i)),
        updatedAt: DateTime.now().subtract(Duration(hours: i)),
        description: 'A sample bookmark description for link $i',
        isFavorite: i.isEven,
      ),
    );
  }
}
