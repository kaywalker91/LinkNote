import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/features/link/presentation/provider/link_di_providers.dart';
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
    final result = await ref
        .read(fetchLinksUsecaseProvider)
        .call(
          cursor: cursor,
          favoritesOnly: favoritesOnly,
        );
    if (result.isSuccess) return result.data!;
    throw result.failure!;
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
    } on Exception catch (e) {
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

    // Optimistic removal
    final previous = current;
    state = AsyncData(
      current.copyWith(
        items: current.items.where((link) => link.id != id).toList(),
      ),
    );

    final result = await ref.read(deleteLinkUsecaseProvider).call(id);
    if (result.isFailure) {
      state = AsyncData(previous);
    }
  }

  /// Optimistic favorite toggle — immediately updates UI, rolls back on failure.
  Future<void> toggleFavorite(String id) async {
    final current = state.value;
    if (current == null) return;

    final link = current.items.firstWhere((l) => l.id == id);
    final previous = current;

    // Optimistic update
    final updatedItems = current.items.map((l) {
      if (l.id == id) return l.copyWith(isFavorite: !l.isFavorite);
      return l;
    }).toList();
    state = AsyncData(current.copyWith(items: updatedItems));

    final result = await ref
        .read(toggleFavoriteUsecaseProvider)
        .call(id, isFavorite: !link.isFavorite);
    if (result.isFailure) {
      state = AsyncData(previous);
    }
  }
}
