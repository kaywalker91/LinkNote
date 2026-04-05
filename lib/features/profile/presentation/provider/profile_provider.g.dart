// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Profile)
final profileProvider = ProfileProvider._();

final class ProfileProvider
    extends $AsyncNotifierProvider<Profile, UserProfileEntity> {
  ProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileHash();

  @$internal
  @override
  Profile create() => Profile();
}

String _$profileHash() => r'2630b7a40a2adc24b45054882f8a96e713efce7f';

abstract class _$Profile extends $AsyncNotifier<UserProfileEntity> {
  FutureOr<UserProfileEntity> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<UserProfileEntity>, UserProfileEntity>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<UserProfileEntity>, UserProfileEntity>,
              AsyncValue<UserProfileEntity>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
