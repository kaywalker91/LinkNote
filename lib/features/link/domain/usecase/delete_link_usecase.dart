import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/link/domain/repository/i_link_repository.dart';

class DeleteLinkUsecase {
  const DeleteLinkUsecase(this._repository);
  final ILinkRepository _repository;

  Future<Result<void>> call(String id) => _repository.deleteLink(id);
}
