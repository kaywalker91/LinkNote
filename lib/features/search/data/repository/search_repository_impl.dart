import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/features/search/data/datasource/search_remote_datasource.dart';
import 'package:linknote/features/search/domain/repository/i_search_repository.dart';

class SearchRepositoryImpl implements ISearchRepository {
  const SearchRepositoryImpl(this._dataSource);
  final SearchRemoteDataSource _dataSource;

  @override
  Future<Result<List<LinkEntity>>> searchLinks(String query) =>
      _dataSource.searchLinks(query);
}
