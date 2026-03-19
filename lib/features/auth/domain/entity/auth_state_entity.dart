import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_state_entity.freezed.dart';

@freezed
sealed class AuthStateEntity with _$AuthStateEntity {
  const factory AuthStateEntity.authenticated({
    required String userId,
    required String email,
  }) = Authenticated;
  const factory AuthStateEntity.unauthenticated() = Unauthenticated;
  const factory AuthStateEntity.loading() = AuthLoading;
}
