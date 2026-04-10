import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/features/search/data/datasource/search_remote_datasource.dart';
import 'package:linknote/features/search/domain/entity/search_filter_entity.dart';
import 'package:linknote/features/search/domain/repository/i_search_repository.dart';

class SearchRepositoryImpl implements ISearchRepository {
  const SearchRepositoryImpl(this._dataSource);
  final SearchRemoteDataSource _dataSource;

  @override
  Future<Result<List<LinkEntity>>> searchLinks(
    String query, {
    SearchFilterEntity? filter,
  }) async {
    final result = await _dataSource.searchLinks(query, filter: filter);

    if (result.isFailure) return result;

    // Client-side tag filtering (PostgREST cannot filter on nested joins).
    if (filter != null && filter.selectedTagIds.isNotEmpty) {
      final filtered = result.data!
          .where(
            (link) => link.tags.any(
              (t) => filter.selectedTagIds.contains(t.id),
            ),
          )
          .toList();
      return success(filtered);
    }

    return result;
  }
}
