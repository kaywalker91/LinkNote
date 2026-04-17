import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/collection/presentation/provider/collection_detail_provider.dart';
import 'package:linknote/features/collection/presentation/provider/collection_links_provider.dart';
import 'package:linknote/features/collection/presentation/provider/collection_list_provider.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/features/link/presentation/provider/link_detail_provider.dart';
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
    return _fetch(
      favoritesOnly: filter.favoritesOnly,
      collectionId: filter.collectionId,
    );
  }

  Future<PaginatedState<LinkEntity>> _fetch({
    String? cursor,
    bool favoritesOnly = false,
    String? collectionId,
  }) async {
    final result = await ref
        .read(fetchLinksUsecaseProvider)
        .call(
          cursor: cursor,
          favoritesOnly: favoritesOnly,
          collectionId: collectionId,
        );
    if (result.isSuccess) return result.data!;
    Error.throwWithStackTrace(result.failure!, StackTrace.current);
  }

  Future<void> refresh() async {
    final filter = ref.read(linkFilterProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _fetch(
        favoritesOnly: filter.favoritesOnly,
        collectionId: filter.collectionId,
      ),
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
        collectionId: filter.collectionId,
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

  /// Moves a link to a different collection (or clears collection if null).
  ///
  /// Follows the optimistic-update + rollback pattern used by [deleteLink]
  /// and [toggleFavorite]: the in-memory state is updated immediately; on
  /// usecase failure the previous state is restored and the underlying
  /// Failure is rethrown so the caller can surface an error snackbar.
  Future<void> moveToCollection({
    required String linkId,
    required String? collectionId,
  }) async {
    final current = state.value;
    if (current == null) return;

    final existing = current.items.where((l) => l.id == linkId).firstOrNull;
    if (existing == null) return;

    if (existing.collectionId == collectionId) return;

    final previous = current;
    final optimistic = existing.copyWith(
      collectionId: collectionId,
      collectionName: null,
    );
    state = AsyncData(
      current.copyWith(
        items: current.items
            .map((l) => l.id == linkId ? optimistic : l)
            .toList(),
      ),
    );

    final result = await ref.read(updateLinkUsecaseProvider).call(optimistic);
    if (result.isFailure) {
      state = AsyncData(previous);
      Error.throwWithStackTrace(result.failure!, StackTrace.current);
    }

    state = AsyncData(
      current.copyWith(
        items: current.items
            .map((l) => l.id == linkId ? result.data! : l)
            .toList(),
      ),
    );

    if (existing.collectionId != null) {
      ref
        ..invalidate(collectionLinksProvider(existing.collectionId!))
        ..invalidate(collectionDetailProvider(existing.collectionId!));
    }
    if (collectionId != null) {
      ref
        ..invalidate(collectionLinksProvider(collectionId))
        ..invalidate(collectionDetailProvider(collectionId));
    }
    ref
      ..invalidate(collectionListProvider)
      ..invalidate(linkDetailProvider(linkId));
  }
}
