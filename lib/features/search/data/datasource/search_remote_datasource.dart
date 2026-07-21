import 'package:linknote/core/error/result.dart';
import 'package:linknote/core/network/supabase_guard.dart';
import 'package:linknote/core/utils/parse_rows.dart';
import 'package:linknote/features/link/data/datasource/link_remote_datasource.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/features/link/domain/entity/tag_entity.dart';
import 'package:linknote/features/search/domain/entity/search_filter_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SearchRemoteDataSource {
  const SearchRemoteDataSource(this._client);
  final SupabaseClient _client;

  /// Sanitizes user input into a safe PostgreSQL tsquery string.
  /// Removes characters that could cause tsquery parse errors or injection.
  static String sanitizeTsQuery(String query) {
    return query
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .map((w) => w.replaceAll(RegExp(r'[^a-zA-Z0-9가-힣\-_]'), ''))
        .where((w) => w.isNotEmpty)
        .map((w) => "'$w'")
        .join(' & ');
  }

  Future<Result<List<LinkEntity>>> searchLinks(
    String query, {
    SearchFilterEntity? filter,
  }) {
    return guardSupabase<List<LinkEntity>>(() async {
      final tsQuery = sanitizeTsQuery(query);
      final hasFilter = filter != null && filter.hasActiveFilters;

      if (tsQuery.isEmpty && !hasFilter) return success([]);

      var queryBuilder = _client.from('links').select('''
            *,
            link_tags(tags(*)),
            collections(name, visibility, locked_at)
          ''');

      if (tsQuery.isNotEmpty) {
        queryBuilder = queryBuilder.textSearch('fts', tsQuery);
      }

      if (filter != null) {
        if (filter.favoritesOnly) {
          queryBuilder = queryBuilder.eq('is_favorite', true);
        }
        if (filter.dateFrom != null) {
          queryBuilder = queryBuilder.gte(
            'created_at',
            filter.dateFrom!.toIso8601String(),
          );
        }
        if (filter.dateTo != null) {
          queryBuilder = queryBuilder.lte(
            'created_at',
            filter.dateTo!.toIso8601String(),
          );
        }
      }

      final response = await queryBuilder
          .order('created_at', ascending: false)
          .limit(50);

      final items = LinkRemoteDataSource.parseRows(
        response.cast<Map<String, dynamic>>(),
      );
      return success(items);
    }, label: 'search remote failure');
  }

  Future<Result<List<TagEntity>>> fetchUserTags() {
    return guardSupabase<List<TagEntity>>(() async {
      // `link_tags!inner(...)` turns the embed into an inner join, so only tags
      // that are still attached to at least one link come back. This hides any
      // orphan tag rows (left behind when a link is deleted or its tags edited)
      // from the search UI even before the DB-side cleanup migration is applied.
      final response = await _client
          .from('tags')
          .select('id, name, color, link_tags!inner(tag_id)')
          .order('name');

      final tags = parseRowsTolerant<TagEntity>(
        response.cast<Map<String, dynamic>>(),
        (row) => TagEntity(
          id: row['id'] as String,
          name: row['name'] as String,
          color: row['color'] as String? ?? '#808080',
        ),
        label: 'SearchRemoteDataSource.fetchUserTags',
      );
      return success(tags);
    }, label: 'search remote failure');
  }
}
