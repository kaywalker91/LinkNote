import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/features/search/domain/entity/search_filter_entity.dart';

// ignore: one_member_abstracts, Clean Architecture interface contract.
abstract interface class ISearchRepository {
  Future<Result<List<LinkEntity>>> searchLinks(
    String query, {
    SearchFilterEntity? filter,
  });
}
