import 'package:linknote/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:linknote/features/auth/data/repository/auth_repository_impl.dart';
import 'package:linknote/features/auth/domain/repository/i_auth_repository.dart';
import 'package:linknote/features/auth/domain/usecase/check_session_usecase.dart';
import 'package:linknote/features/auth/domain/usecase/sign_in_usecase.dart';
import 'package:linknote/features/auth/domain/usecase/sign_out_usecase.dart';
import 'package:linknote/features/auth/domain/usecase/sign_up_usecase.dart';
import 'package:linknote/features/collection/presentation/provider/collection_di_providers.dart';
import 'package:linknote/features/link/presentation/provider/link_di_providers.dart';
import 'package:linknote/features/notification/presentation/provider/notification_di_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_di_providers.g.dart';

@riverpod
AuthRemoteDatasource authRemoteDatasource(Ref ref) {
  return AuthRemoteDatasource(Supabase.instance.client);
}

@riverpod
IAuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDatasourceProvider));
}

@riverpod
CheckSessionUsecase checkSessionUsecase(Ref ref) {
  return CheckSessionUsecase(ref.watch(authRepositoryProvider));
}

@riverpod
SignInUsecase signInUsecase(Ref ref) {
  return SignInUsecase(ref.watch(authRepositoryProvider));
}

@riverpod
SignUpUsecase signUpUsecase(Ref ref) {
  return SignUpUsecase(ref.watch(authRepositoryProvider));
}

@riverpod
SignOutUsecase signOutUsecase(Ref ref) {
  return SignOutUsecase(
    ref.watch(authRepositoryProvider),
    ref.watch(linkLocalDataSourceProvider),
    ref.watch(collectionLocalDataSourceProvider),
    ref.watch(notificationLocalDataSourceProvider),
  );
}
