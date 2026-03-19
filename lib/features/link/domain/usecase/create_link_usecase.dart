import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/features/link/domain/repository/i_link_repository.dart';

class CreateLinkUsecase {
  const CreateLinkUsecase(this._repository);
  final ILinkRepository _repository;

  Future<Result<LinkEntity>> call(LinkEntity link) =>
      _repository.createLink(link);
}
