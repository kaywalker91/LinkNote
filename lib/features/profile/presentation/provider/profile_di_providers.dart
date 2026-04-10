import 'package:linknote/features/profile/data/datasource/profile_remote_datasource.dart';
import 'package:linknote/features/profile/data/repository/profile_repository_impl.dart';
import 'package:linknote/features/profile/domain/repository/i_profile_repository.dart';
import 'package:linknote/features/profile/domain/usecase/get_profile_usecase.dart';
import 'package:linknote/features/profile/domain/usecase/update_profile_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'profile_di_providers.g.dart';

@riverpod
ProfileRemoteDataSource profileRemoteDataSource(Ref ref) {
  return ProfileRemoteDataSource(Supabase.instance.client);
}

@riverpod
IProfileRepository profileRepository(Ref ref) {
  return ProfileRepositoryImpl(ref.watch(profileRemoteDataSourceProvider));
}

@riverpod
GetProfileUsecase getProfileUsecase(Ref ref) {
  return GetProfileUsecase(ref.watch(profileRepositoryProvider));
}

@riverpod
UpdateProfileUsecase updateProfileUsecase(Ref ref) {
  return UpdateProfileUsecase(ref.watch(profileRepositoryProvider));
}
