import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/features/link/domain/repository/i_link_repository.dart';

class ToggleFavoriteUsecase {
  const ToggleFavoriteUsecase(this._repository);
  final ILinkRepository _repository;

  Future<Result<LinkEntity>> call(String id, {required bool isFavorite}) =>
      _repository.toggleFavorite(id, isFavorite: isFavorite);
}
