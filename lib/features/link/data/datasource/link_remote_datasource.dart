import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/core/network/supabase_guard.dart';
import 'package:linknote/core/utils/parse_rows.dart';
import 'package:linknote/features/link/data/dto/link_dto.dart';
import 'package:linknote/features/link/data/mapper/link_mapper.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/features/link/domain/entity/tag_entity.dart';
import 'package:linknote/shared/models/paginated_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LinkRemoteDataSource {
  const LinkRemoteDataSource(this._client);
  final SupabaseClient _client;

  /// Canonical Supabase projection for a link row plus its tag/collection
  /// joins. This is the single source of truth: `SearchRemoteDataSource` reuses
  /// it (via [selectQuery]) so both fetch paths feed the
  /// same shape into [parseRows]. Widening this projection must not be done by
  /// hand-copying the string elsewhere, or search would silently miss the new
  /// join fields.
  static const selectQuery = '''
    *,
    link_tags(tags(*)),
    collections(name, visibility, locked_at)
  ''';

  /// Maps Supabase row maps into [LinkEntity] instances per-item, so a single
  /// malformed row (e.g. a tag join missing `color`) cannot wipe out the
  /// entire page. Delegates to [parseRowsTolerant] for the shared skip-and-log
  /// behavior.
  static List<LinkEntity> parseRows(
    List<Map<String, dynamic>> rows, {
    void Function(Object error, StackTrace stackTrace)? onError,
  }) => parseRowsTolerant<LinkEntity>(
    rows,
    (row) => LinkMapper.toEntity(LinkDto.fromJson(row)),
    label: 'LinkRemoteDataSource',
    onError: onError,
  );

  Future<Result<PaginatedState<LinkEntity>>> getLinks({
    String? cursor,
    int pageSize = 20,
    bool favoritesOnly = false,
    String? collectionId,
  }) {
    return guardSupabase<PaginatedState<LinkEntity>>(() async {
      var query = _client.from('links').select(selectQuery);

      if (favoritesOnly) {
        query = query.eq('is_favorite', true);
      }
      if (collectionId != null) {
        query = query.eq('collection_id', collectionId);
      }
      if (cursor != null) {
        query = query.lt('created_at', cursor);
      }

      final response = await query
          .order('created_at', ascending: false)
          .limit(pageSize + 1);

      final hasMore = response.length > pageSize;
      final rawItems = hasMore ? response.sublist(0, pageSize) : response;
      final items = parseRows(rawItems.cast<Map<String, dynamic>>());

      return success(
        PaginatedState<LinkEntity>(
          items: items,
          hasMore: hasMore,
          nextCursor: items.isNotEmpty
              ? items.last.createdAt.toUtc().toIso8601String()
              : null,
        ),
      );
    }, label: 'link remote failure');
  }

  /// Reads the links of a `public` collection without scoping to the caller's
  /// `user_id`. Backs the read-only public-share view.
  ///
  /// The query is identical to [getLinks] filtered by `collection_id`; what
  /// makes non-owner rows visible is the additive `links_select_public_collection`
  /// RLS policy (a link is readable when its parent collection is public). The
  /// caller is expected to confirm the parent collection resolved as public
  /// before invoking this (presentation-layer gate).
  Future<Result<PaginatedState<LinkEntity>>> getPublicLinksByCollectionId(
    String collectionId, {
    String? cursor,
    int pageSize = 20,
  }) {
    return guardSupabase<PaginatedState<LinkEntity>>(() async {
      var query = _client
          .from('links')
          .select(selectQuery)
          .eq('collection_id', collectionId);

      if (cursor != null) {
        query = query.lt('created_at', cursor);
      }

      final response = await query
          .order('created_at', ascending: false)
          .limit(pageSize + 1);

      final hasMore = response.length > pageSize;
      final rawItems = hasMore ? response.sublist(0, pageSize) : response;
      final items = parseRows(rawItems.cast<Map<String, dynamic>>());

      return success(
        PaginatedState<LinkEntity>(
          items: items,
          hasMore: hasMore,
          nextCursor: items.isNotEmpty
              ? items.last.createdAt.toUtc().toIso8601String()
              : null,
        ),
      );
    }, label: 'link remote failure');
  }

  Future<Result<LinkEntity>> getLinkById(String id) {
    return guardSupabase<LinkEntity>(() async {
      final response = await _client
          .from('links')
          .select(selectQuery)
          .eq('id', id)
          .single();

      return success(LinkMapper.toEntity(LinkDto.fromJson(response)));
    }, label: 'link remote failure');
  }

  Future<Result<LinkEntity>> createLink(
    LinkEntity link,
    String userId,
  ) {
    return guardSupabase<LinkEntity>(() async {
      final json = LinkMapper.toInsertJson(link, userId);
      final response = await _client
          .from('links')
          .insert(json)
          .select(selectQuery)
          .single();

      final createdLink = LinkMapper.toEntity(LinkDto.fromJson(response));

      // Handle tags if present
      if (link.tags.isNotEmpty) {
        await _syncTags(createdLink.id, link.tags, userId);
        // Re-fetch to get tags in response
        return getLinkById(createdLink.id);
      }

      return success(createdLink);
    }, label: 'link remote failure');
  }

  Future<Result<LinkEntity>> updateLink(LinkEntity link) {
    return guardSupabase<LinkEntity>(() async {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return error(const Failure.auth(message: 'Session expired'));
      }

      final json = LinkMapper.toUpdateJson(link);
      await _client.from('links').update(json).eq('id', link.id);

      // Sync tags
      await _syncTags(link.id, link.tags, userId);

      return getLinkById(link.id);
    }, label: 'link remote failure');
  }

  Future<Result<void>> deleteLink(String id) {
    return guardSupabase<void>(() async {
      await _client.from('links').delete().eq('id', id);
      return success(null);
    }, label: 'link remote failure');
  }

  Future<Result<LinkEntity>> toggleFavorite(
    String id, {
    required bool isFavorite,
  }) {
    return guardSupabase<LinkEntity>(() async {
      await _client
          .from('links')
          .update({'is_favorite': isFavorite})
          .eq('id', id);
      return getLinkById(id);
    }, label: 'link remote failure');
  }

  /// Syncs tags for a link: upserts tag records in batch, then reconciles
  /// `link_tags` by adding the desired connections before removing stale ones.
  ///
  /// The add-before-remove ordering matters once the DB-side orphan-cleanup
  /// trigger (see `scripts/migration_66_orphan_tags.sql`) is live: that trigger
  /// deletes a tag the moment its last `link_tags` row disappears. If we deleted
  /// every connection first (old behavior), a tag the user is keeping would
  /// momentarily drop to zero links, get cleaned up, and the follow-up insert
  /// would fail the FK check. Upserting the kept/new connections first means
  /// retained tags never lose their last link, so the trigger only fires for
  /// tags that are genuinely being removed. It also keeps the pre-trigger
  /// invariant that a mid-failure cannot orphan a tag the user still wants.
  Future<void> _syncTags(
    String linkId,
    List<TagEntity> tags,
    String userId,
  ) async {
    if (tags.isEmpty) {
      // No tags remain: drop every connection for this link. The cleanup
      // trigger removes any tag left with zero links.
      await _client.from('link_tags').delete().eq('link_id', linkId);
      return;
    }

    // Batch upsert all tags in a single request
    final tagRows = tags
        .map(
          (tag) => {'user_id': userId, 'name': tag.name, 'color': tag.color},
        )
        .toList();
    final upsertedTags = await _client
        .from('tags')
        .upsert(tagRows, onConflict: 'user_id,name')
        .select('id');
    final tagIds = upsertedTags.map((row) => row['id'] as String).toList();

    // Build the desired link_tag rows.
    final linkTagRows = tagIds
        .map((tagId) => {'link_id': linkId, 'tag_id': tagId})
        .toList();

    // Add the desired connections first (idempotent on the composite PK
    // `(link_id, tag_id)`), then remove only the connections that are no longer
    // wanted. `ignoreDuplicates` makes the upsert a no-op for connections that
    // already exist, so retained tags keep their `link_tags` row untouched.
    await _client
        .from('link_tags')
        .upsert(
          linkTagRows,
          onConflict: 'link_id,tag_id',
          ignoreDuplicates: true,
        );
    await _client
        .from('link_tags')
        .delete()
        .eq('link_id', linkId)
        .not('tag_id', 'in', '(${tagIds.join(',')})');
  }
}
