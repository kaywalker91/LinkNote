import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
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
    collections(name)
  ''';

  Future<Result<PaginatedState<LinkEntity>>> getLinks({
    String? cursor,
    int pageSize = 20,
    bool favoritesOnly = false,
  }) async {
    try {
      var query = _client.from('links').select(_selectQuery);

      if (favoritesOnly) {
        query = query.eq('is_favorite', true);
      }
      if (cursor != null) {
        query = query.lt('created_at', cursor);
      }

      final response = await query
          .order('created_at', ascending: false)
          .limit(pageSize + 1);

      final hasMore = response.length > pageSize;
      final rawItems = hasMore ? response.sublist(0, pageSize) : response;
      final items = rawItems
          .map(
            (json) => LinkMapper.toEntity(LinkDto.fromJson(json)),
          )
          .toList();

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
    } on Exception catch (e) {
      return error(Failure.unknown(message: e.toString()));
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
    } on Exception catch (e) {
      return error(Failure.unknown(message: e.toString()));
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
    } on Exception catch (e) {
      return error(Failure.unknown(message: e.toString()));
    }
  }

  Future<Result<LinkEntity>> updateLink(LinkEntity link) async {
    try {
      final json = LinkMapper.toUpdateJson(link);
      await _client.from('links').update(json).eq('id', link.id);

      // Sync tags
      final userId = _client.auth.currentUser!.id;
      await _syncTags(link.id, link.tags, userId);

      return getLinkById(link.id);
    } on PostgrestException catch (e) {
      return error(Failure.server(message: e.message));
    } on Exception catch (e) {
      return error(Failure.unknown(message: e.toString()));
    }
  }

  Future<Result<void>> deleteLink(String id) async {
    try {
      await _client.from('links').delete().eq('id', id);
      return success(null);
    } on PostgrestException catch (e) {
      return error(Failure.server(message: e.message));
    } on Exception catch (e) {
      return error(Failure.unknown(message: e.toString()));
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
    } on Exception catch (e) {
      return error(Failure.unknown(message: e.toString()));
    }
  }

  /// Syncs tags for a link: upserts tag records, then replaces link_tags.
  Future<void> _syncTags(
    String linkId,
    List<TagEntity> tags,
    String userId,
  ) async {
    // Remove existing link_tags
    await _client.from('link_tags').delete().eq('link_id', linkId);

    if (tags.isEmpty) return;

    // Upsert each tag and collect IDs
    final tagIds = <String>[];
    for (final tag in tags) {
      final response = await _client
          .from('tags')
          .upsert(
            {'user_id': userId, 'name': tag.name, 'color': tag.color},
            onConflict: 'user_id,name',
          )
          .select('id')
          .single();
      tagIds.add(response['id'] as String);
    }

    // Insert link_tags
    final linkTagRows = tagIds
        .map((tagId) => {'link_id': linkId, 'tag_id': tagId})
        .toList();
    await _client.from('link_tags').insert(linkTagRows);
  }
}
