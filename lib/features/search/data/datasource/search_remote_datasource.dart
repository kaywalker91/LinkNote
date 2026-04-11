import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/link/data/dto/link_dto.dart';
import 'package:linknote/features/link/data/mapper/link_mapper.dart';
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
  }) async {
    try {
      final tsQuery = sanitizeTsQuery(query);

      if (tsQuery.isEmpty) return success([]);

      var queryBuilder = _client
          .from('links')
          .select('''
            *,
            link_tags(tags(*)),
            collections(name)
          ''')
          .textSearch('fts', tsQuery);

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

      final items = response
          .map(
            (json) => LinkMapper.toEntity(LinkDto.fromJson(json)),
          )
          .toList();
      return success(items);
    } on PostgrestException catch (e) {
      return error(Failure.server(message: e.message));
    } on Exception catch (e) {
      return error(Failure.unknown(message: e.toString()));
    }
  }

  Future<Result<List<TagEntity>>> fetchUserTags() async {
    try {
      final response = await _client.from('tags').select().order('name');

      final tags = response
          .map(
            (json) => TagEntity(
              id: json['id'] as String,
              name: json['name'] as String,
              color: json['color'] as String? ?? '#808080',
            ),
          )
          .toList();
      return success(tags);
    } on PostgrestException catch (e) {
      return error(Failure.server(message: e.message));
    } on Exception catch (e) {
      return error(Failure.unknown(message: e.toString()));
    }
  }
}
