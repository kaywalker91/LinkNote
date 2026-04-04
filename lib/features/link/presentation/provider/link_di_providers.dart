import 'package:linknote/features/auth/domain/entity/auth_state_entity.dart';
import 'package:linknote/features/auth/presentation/provider/auth_provider.dart';
import 'package:linknote/features/link/data/datasource/link_remote_datasource.dart';
import 'package:linknote/features/link/data/repository/link_repository_impl.dart';
import 'package:linknote/features/link/domain/repository/i_link_repository.dart';
import 'package:linknote/features/link/domain/usecase/create_link_usecase.dart';
import 'package:linknote/features/link/domain/usecase/delete_link_usecase.dart';
import 'package:linknote/features/link/domain/usecase/fetch_links_usecase.dart';
import 'package:linknote/features/link/domain/usecase/get_link_detail_usecase.dart';
import 'package:linknote/features/link/domain/usecase/toggle_favorite_usecase.dart';
import 'package:linknote/features/link/domain/usecase/update_link_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'link_di_providers.g.dart';

@riverpod
LinkRemoteDataSource linkRemoteDataSource(Ref ref) {
  return LinkRemoteDataSource(Supabase.instance.client);
}

@riverpod
ILinkRepository linkRepository(Ref ref) {
  final authState = ref.watch(authProvider).requireValue;
  final userId = switch (authState) {
    Authenticated(:final userId) => userId,
    _ => throw StateError('User must be authenticated'),
  };
  return LinkRepositoryImpl(
    ref.watch(linkRemoteDataSourceProvider),
    userId: userId,
  );
}

@riverpod
FetchLinksUsecase fetchLinksUsecase(Ref ref) {
  return FetchLinksUsecase(ref.watch(linkRepositoryProvider));
}

@riverpod
CreateLinkUsecase createLinkUsecase(Ref ref) {
  return CreateLinkUsecase(ref.watch(linkRepositoryProvider));
}

@riverpod
UpdateLinkUsecase updateLinkUsecase(Ref ref) {
  return UpdateLinkUsecase(ref.watch(linkRepositoryProvider));
}

@riverpod
DeleteLinkUsecase deleteLinkUsecase(Ref ref) {
  return DeleteLinkUsecase(ref.watch(linkRepositoryProvider));
}

@riverpod
GetLinkDetailUsecase getLinkDetailUsecase(Ref ref) {
  return GetLinkDetailUsecase(ref.watch(linkRepositoryProvider));
}

@riverpod
ToggleFavoriteUsecase toggleFavoriteUsecase(Ref ref) {
  return ToggleFavoriteUsecase(ref.watch(linkRepositoryProvider));
}
