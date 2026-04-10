// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_di_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(profileRemoteDataSource)
final profileRemoteDataSourceProvider = ProfileRemoteDataSourceProvider._();

final class ProfileRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          ProfileRemoteDataSource,
          ProfileRemoteDataSource,
          ProfileRemoteDataSource
        >
    with $Provider<ProfileRemoteDataSource> {
  ProfileRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileRemoteDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<ProfileRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProfileRemoteDataSource create(Ref ref) {
    return profileRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileRemoteDataSource>(value),
    );
  }
}

String _$profileRemoteDataSourceHash() =>
    r'5ea5f1fd86065e174f1419d6faa76c640c2f1e33';

@ProviderFor(profileRepository)
final profileRepositoryProvider = ProfileRepositoryProvider._();

final class ProfileRepositoryProvider
    extends
        $FunctionalProvider<
          IProfileRepository,
          IProfileRepository,
          IProfileRepository
        >
    with $Provider<IProfileRepository> {
  ProfileRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileRepositoryHash();

  @$internal
  @override
  $ProviderElement<IProfileRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  IProfileRepository create(Ref ref) {
    return profileRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IProfileRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IProfileRepository>(value),
    );
  }
}

String _$profileRepositoryHash() => r'541be9f988ef615bd945442587d39236398c3c0c';

@ProviderFor(getProfileUsecase)
final getProfileUsecaseProvider = GetProfileUsecaseProvider._();

final class GetProfileUsecaseProvider
    extends
        $FunctionalProvider<
          GetProfileUsecase,
          GetProfileUsecase,
          GetProfileUsecase
        >
    with $Provider<GetProfileUsecase> {
  GetProfileUsecaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getProfileUsecaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getProfileUsecaseHash();

  @$internal
  @override
  $ProviderElement<GetProfileUsecase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetProfileUsecase create(Ref ref) {
    return getProfileUsecase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetProfileUsecase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetProfileUsecase>(value),
    );
  }
}

String _$getProfileUsecaseHash() => r'870352a3f0a7709bd8ec52ba619c350b9584ea49';

@ProviderFor(updateProfileUsecase)
final updateProfileUsecaseProvider = UpdateProfileUsecaseProvider._();

final class UpdateProfileUsecaseProvider
    extends
        $FunctionalProvider<
          UpdateProfileUsecase,
          UpdateProfileUsecase,
          UpdateProfileUsecase
        >
    with $Provider<UpdateProfileUsecase> {
  UpdateProfileUsecaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateProfileUsecaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateProfileUsecaseHash();

  @$internal
  @override
  $ProviderElement<UpdateProfileUsecase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UpdateProfileUsecase create(Ref ref) {
    return updateProfileUsecase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateProfileUsecase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateProfileUsecase>(value),
    );
  }
}

String _$updateProfileUsecaseHash() =>
    r'5d941402826f194db52fcc80d3fedfadc247648e';
