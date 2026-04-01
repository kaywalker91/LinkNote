import 'package:linknote/features/auth/domain/entity/auth_state_entity.dart';
import 'package:linknote/features/auth/presentation/provider/auth_provider.dart';
import 'package:linknote/features/profile/domain/entity/user_profile_entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_provider.g.dart';

@riverpod
class Profile extends _$Profile {
  @override
  Future<UserProfileEntity> build() async {
    final authState = await ref.watch(authProvider.future);
    return switch (authState) {
      Authenticated(:final userId, :final email) => UserProfileEntity(
        id: userId,
        email: email,
        displayName: email.split('@').first,
        linkCount: 0,
        collectionCount: 0,
      ),
      Unauthenticated() => throw Exception('Not authenticated'),
      AuthLoading() => throw Exception('Loading'),
    };
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build());
  }
}
