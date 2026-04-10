import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/features/search/domain/entity/search_filter_entity.dart';
import 'package:linknote/features/search/domain/repository/i_search_repository.dart';

class SearchLinksUsecase {
  const SearchLinksUsecase(this._repository);
  final ISearchRepository _repository;

  Future<Result<List<LinkEntity>>> call(
    String query, {
    SearchFilterEntity? filter,
  }) => _repository.searchLinks(query, filter: filter);
}
