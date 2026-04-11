import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/profile/domain/entity/user_profile_entity.dart';
import 'package:linknote/features/profile/presentation/provider/profile_di_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_provider.g.dart';

@riverpod
class Profile extends _$Profile {
  @override
  Future<UserProfileEntity> build() async {
    final usecase = ref.watch(getProfileUsecaseProvider);
    final result = await usecase.call(); // Result<UserProfileEntity>

    if (result.isSuccess) return result.data!;
    throw result.failure!;
  }

  Future<void> updateProfile({
    String? displayName,
    String? avatarUrl,
  }) async {
    state = const AsyncLoading();
    final usecase = ref.read(updateProfileUsecaseProvider);
    final result = await usecase.call(
      displayName: displayName,
      avatarUrl: avatarUrl,
    );

    if (result.isSuccess) {
      state = AsyncData(result.data!);
    } else {
      state = AsyncError(result.failure!, StackTrace.current);
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }
}
