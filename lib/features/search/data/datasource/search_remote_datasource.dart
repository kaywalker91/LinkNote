import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/link/data/dto/link_dto.dart';
import 'package:linknote/features/link/data/mapper/link_mapper.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SearchRemoteDataSource {
  const SearchRemoteDataSource(this._client);
  final SupabaseClient _client;

  Future<Result<List<LinkEntity>>> searchLinks(String query) async {
    try {
      // Convert user query to PostgreSQL tsquery format.
      final tsQuery = query
          .split(RegExp(r'\s+'))
          .where((w) => w.isNotEmpty)
          .map((w) => "'$w'")
          .join(' & ');

      if (tsQuery.isEmpty) return success([]);

      final response = await _client
          .from('links')
          .select('''
            *,
            link_tags(tags(*)),
            collections(name)
          ''')
          .textSearch('fts', tsQuery)
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
}
