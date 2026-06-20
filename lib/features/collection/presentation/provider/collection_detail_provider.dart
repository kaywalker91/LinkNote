import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/collection/domain/entity/collection_entity.dart';
import 'package:linknote/features/collection/presentation/provider/collection_di_providers.dart';
import 'package:linknote/features/collection/presentation/provider/collection_list_provider.dart';
import 'package:linknote/features/link/presentation/provider/link_detail_provider.dart';
import 'package:linknote/features/link/presentation/provider/link_list_provider.dart';
import 'package:linknote/features/search/presentation/provider/search_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'collection_detail_provider.g.dart';

@riverpod
class CollectionDetail extends _$CollectionDetail {
  @override
  Future<CollectionEntity> build(String collectionId) async {
    final result = await ref
        .read(getCollectionDetailUsecaseProvider)
        .call(collectionId);
    if (result.isFailure) {
      Error.throwWithStackTrace(result.failure!, StackTrace.current);
    }
    return result.data!;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build(collectionId));
  }

  /// Toggles public/private. No-op if already in the requested state.
  Future<void> setVisibility(CollectionVisibility visibility) async {
    final current = state.value;
    if (current == null || current.visibility == visibility) return;
    await _applyVisibility(
      previous: current,
      visibility: visibility,
      lockedAt: current.lockedAt,
    );
  }

  /// Sets/clears the lock marker (visual only; access control is backend-side).
  Future<void> setLocked({required bool locked}) async {
    final current = state.value;
    if (current == null || (current.lockedAt != null) == locked) return;
    await _applyVisibility(
      previous: current,
      visibility: current.visibility,
      lockedAt: locked ? DateTime.now() : null,
    );
  }

  /// Optimistically applies the new visibility/lock, persists it, rolls back on
  /// failure, then invalidates every surface that denormalizes these fields.
  Future<void> _applyVisibility({
    required CollectionEntity previous,
    required CollectionVisibility visibility,
    required DateTime? lockedAt,
  }) async {
    state = AsyncData(
      previous.copyWith(visibility: visibility, lockedAt: lockedAt),
    );

    final result = await ref
        .read(updateCollectionVisibilityUsecaseProvider)
        .call(id: collectionId, visibility: visibility, lockedAt: lockedAt);

    if (result.isFailure) {
      state = AsyncData(previous);
      Error.throwWithStackTrace(result.failure!, StackTrace.current);
    }

    state = AsyncData(result.data!);
    _invalidateDenormalizedSurfaces();
  }

  /// The link read-model denormalizes collection visibility/lockedAt (#46/#47),
  /// so a toggle must refresh link/search surfaces, not just the collection.
  void _invalidateDenormalizedSurfaces() {
    ref
      ..invalidate(collectionListProvider)
      ..invalidate(linkListProvider)
      ..invalidate(linkDetailProvider)
      ..invalidate(searchProvider);
  }
}
