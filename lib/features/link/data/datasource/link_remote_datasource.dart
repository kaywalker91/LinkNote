import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/core/logger/app_logger.dart';
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

  static const _selectQuery = '''
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
  }) async {
    try {
      var query = _client.from('links').select(_selectQuery);

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
    } on PostgrestException catch (e) {
      return error(Failure.server(message: e.message));
    } on Object catch (e, st) {
      // Catches Dart `Error` subtypes (e.g. `_TypeError` from JSON cast
      // failures) in addition to Exceptions, so they surface as Failure
      // instead of escaping to AsyncValue.error as raw Errors. The same
      // policy applies to every catch block below. The raw error is logged
      // (not embedded in Failure.message) to avoid leaking it to the UI (F5).
      appLogger.w('link remote failure', error: e, stackTrace: st);
      return error(const Failure.unknown());
    }
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
  }) async {
    try {
      var query = _client
          .from('links')
          .select(_selectQuery)
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
    } on PostgrestException catch (e) {
      return error(Failure.server(message: e.message));
    } on Object catch (e, st) {
      appLogger.w('link remote failure', error: e, stackTrace: st);
      return error(const Failure.unknown());
    }
  }

  Future<Result<LinkEntity>> getLinkById(String id) async {
    try {
      final response = await _client
          .from('links')
          .select(_selectQuery)
          .eq('id', id)
          .single();

      return success(LinkMapper.toEntity(LinkDto.fromJson(response)));
    } on PostgrestException catch (e) {
      return error(Failure.server(message: e.message));
    } on Object catch (e, st) {
      appLogger.w('link remote failure', error: e, stackTrace: st);
      return error(const Failure.unknown());
    }
  }

  Future<Result<LinkEntity>> createLink(
    LinkEntity link,
    String userId,
  ) async {
    try {
      final json = LinkMapper.toInsertJson(link, userId);
      final response = await _client
          .from('links')
          .insert(json)
          .select(_selectQuery)
          .single();

      final createdLink = LinkMapper.toEntity(LinkDto.fromJson(response));

      // Handle tags if present
      if (link.tags.isNotEmpty) {
        await _syncTags(createdLink.id, link.tags, userId);
        // Re-fetch to get tags in response
        return getLinkById(createdLink.id);
      }

      return success(createdLink);
    } on PostgrestException catch (e) {
      return error(Failure.server(message: e.message));
    } on Object catch (e, st) {
      appLogger.w('link remote failure', error: e, stackTrace: st);
      return error(const Failure.unknown());
    }
  }

  Future<Result<LinkEntity>> updateLink(LinkEntity link) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return error(const Failure.auth(message: 'Session expired'));
      }

      final json = LinkMapper.toUpdateJson(link);
      await _client.from('links').update(json).eq('id', link.id);

      // Sync tags
      await _syncTags(link.id, link.tags, userId);

      return getLinkById(link.id);
    } on PostgrestException catch (e) {
      return error(Failure.server(message: e.message));
    } on Object catch (e, st) {
      appLogger.w('link remote failure', error: e, stackTrace: st);
      return error(const Failure.unknown());
    }
  }

  Future<Result<void>> deleteLink(String id) async {
    try {
      await _client.from('links').delete().eq('id', id);
      return success(null);
    } on PostgrestException catch (e) {
      return error(Failure.server(message: e.message));
    } on Object catch (e, st) {
      appLogger.w('link remote failure', error: e, stackTrace: st);
      return error(const Failure.unknown());
    }
  }

  Future<Result<LinkEntity>> toggleFavorite(
    String id, {
    required bool isFavorite,
  }) async {
    try {
      await _client
          .from('links')
          .update({'is_favorite': isFavorite})
          .eq('id', id);
      return getLinkById(id);
    } on PostgrestException catch (e) {
      return error(Failure.server(message: e.message));
    } on Object catch (e, st) {
      appLogger.w('link remote failure', error: e, stackTrace: st);
      return error(const Failure.unknown());
    }
  }

  /// Syncs tags for a link: upserts tag records in batch, then replaces
  /// link_tags. Operations are ordered so that a mid-failure does not orphan
  /// existing tags — new link_tags are inserted before old ones are removed.
  Future<void> _syncTags(
    String linkId,
    List<TagEntity> tags,
    String userId,
  ) async {
    if (tags.isEmpty) {
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

    // Build new link_tag rows
    final linkTagRows = tagIds
        .map((tagId) => {'link_id': linkId, 'tag_id': tagId})
        .toList();

    // Remove old link_tags, then insert new ones.
    // Deletion is safe here because tag records are already persisted above.
    await _client.from('link_tags').delete().eq('link_id', linkId);
    await _client.from('link_tags').insert(linkTagRows);
  }
}
