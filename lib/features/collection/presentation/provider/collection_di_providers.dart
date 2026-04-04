import 'package:linknote/features/auth/domain/entity/auth_state_entity.dart';
import 'package:linknote/features/auth/presentation/provider/auth_provider.dart';
import 'package:linknote/features/collection/data/datasource/collection_remote_datasource.dart';
import 'package:linknote/features/collection/data/repository/collection_repository_impl.dart';
import 'package:linknote/features/collection/domain/repository/i_collection_repository.dart';
import 'package:linknote/features/collection/domain/usecase/create_collection_usecase.dart';
import 'package:linknote/features/collection/domain/usecase/delete_collection_usecase.dart';
import 'package:linknote/features/collection/domain/usecase/get_collection_detail_usecase.dart';
import 'package:linknote/features/collection/domain/usecase/get_collections_usecase.dart';
import 'package:linknote/features/collection/domain/usecase/update_collection_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'collection_di_providers.g.dart';

@riverpod
CollectionRemoteDataSource collectionRemoteDataSource(Ref ref) {
  return CollectionRemoteDataSource(Supabase.instance.client);
}

@riverpod
ICollectionRepository collectionRepository(Ref ref) {
  final authState = ref.watch(authProvider).requireValue;
  final userId = switch (authState) {
    Authenticated(:final userId) => userId,
    _ => throw StateError('User must be authenticated'),
  };
  return CollectionRepositoryImpl(
    ref.watch(collectionRemoteDataSourceProvider),
    userId: userId,
  );
}

@riverpod
GetCollectionsUsecase getCollectionsUsecase(Ref ref) {
  return GetCollectionsUsecase(ref.watch(collectionRepositoryProvider));
}

@riverpod
GetCollectionDetailUsecase getCollectionDetailUsecase(Ref ref) {
  return GetCollectionDetailUsecase(ref.watch(collectionRepositoryProvider));
}

@riverpod
CreateCollectionUsecase createCollectionUsecase(Ref ref) {
  return CreateCollectionUsecase(ref.watch(collectionRepositoryProvider));
}

@riverpod
UpdateCollectionUsecase updateCollectionUsecase(Ref ref) {
  return UpdateCollectionUsecase(ref.watch(collectionRepositoryProvider));
}

@riverpod
DeleteCollectionUsecase deleteCollectionUsecase(Ref ref) {
  return DeleteCollectionUsecase(ref.watch(collectionRepositoryProvider));
}
