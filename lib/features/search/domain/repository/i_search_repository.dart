import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';

abstract interface class ISearchRepository {
  Future<Result<List<LinkEntity>>> searchLinks(String query);
}
