// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_di_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(authRemoteDatasource)
final authRemoteDatasourceProvider = AuthRemoteDatasourceProvider._();

final class AuthRemoteDatasourceProvider
    extends
        $FunctionalProvider<
          AuthRemoteDatasource,
          AuthRemoteDatasource,
          AuthRemoteDatasource
        >
    with $Provider<AuthRemoteDatasource> {
  AuthRemoteDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRemoteDatasourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRemoteDatasourceHash();

  @$internal
  @override
  $ProviderElement<AuthRemoteDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AuthRemoteDatasource create(Ref ref) {
    return authRemoteDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRemoteDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRemoteDatasource>(value),
    );
  }
}

String _$authRemoteDatasourceHash() =>
    r'75762932ab1fc692b55ad961ae83ea2e11cf4936';

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

final class AuthRepositoryProvider
    extends
        $FunctionalProvider<IAuthRepository, IAuthRepository, IAuthRepository>
    with $Provider<IAuthRepository> {
  AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<IAuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  IAuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IAuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IAuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'7e582f90d078a0dd045e2fbe902a4170e9414123';

@ProviderFor(checkSessionUsecase)
final checkSessionUsecaseProvider = CheckSessionUsecaseProvider._();

final class CheckSessionUsecaseProvider
    extends
        $FunctionalProvider<
          CheckSessionUsecase,
          CheckSessionUsecase,
          CheckSessionUsecase
        >
    with $Provider<CheckSessionUsecase> {
  CheckSessionUsecaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'checkSessionUsecaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$checkSessionUsecaseHash();

  @$internal
  @override
  $ProviderElement<CheckSessionUsecase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CheckSessionUsecase create(Ref ref) {
    return checkSessionUsecase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CheckSessionUsecase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CheckSessionUsecase>(value),
    );
  }
}

String _$checkSessionUsecaseHash() =>
    r'e730e3eb1444ad9beb19a6ab6a41e581974ffbff';

@ProviderFor(signInUsecase)
final signInUsecaseProvider = SignInUsecaseProvider._();

final class SignInUsecaseProvider
    extends $FunctionalProvider<SignInUsecase, SignInUsecase, SignInUsecase>
    with $Provider<SignInUsecase> {
  SignInUsecaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signInUsecaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signInUsecaseHash();

  @$internal
  @override
  $ProviderElement<SignInUsecase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SignInUsecase create(Ref ref) {
    return signInUsecase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SignInUsecase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SignInUsecase>(value),
    );
  }
}

String _$signInUsecaseHash() => r'6c1c9583b3c2d3e894fcc307aca3d76618bf119b';

@ProviderFor(signUpUsecase)
final signUpUsecaseProvider = SignUpUsecaseProvider._();

final class SignUpUsecaseProvider
    extends $FunctionalProvider<SignUpUsecase, SignUpUsecase, SignUpUsecase>
    with $Provider<SignUpUsecase> {
  SignUpUsecaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signUpUsecaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signUpUsecaseHash();

  @$internal
  @override
  $ProviderElement<SignUpUsecase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SignUpUsecase create(Ref ref) {
    return signUpUsecase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SignUpUsecase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SignUpUsecase>(value),
    );
  }
}

String _$signUpUsecaseHash() => r'd14169e377694fd46343442f0e0cad565859757c';

@ProviderFor(signOutUsecase)
final signOutUsecaseProvider = SignOutUsecaseProvider._();

final class SignOutUsecaseProvider
    extends $FunctionalProvider<SignOutUsecase, SignOutUsecase, SignOutUsecase>
    with $Provider<SignOutUsecase> {
  SignOutUsecaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signOutUsecaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signOutUsecaseHash();

  @$internal
  @override
  $ProviderElement<SignOutUsecase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SignOutUsecase create(Ref ref) {
    return signOutUsecase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SignOutUsecase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SignOutUsecase>(value),
    );
  }
}

String _$signOutUsecaseHash() => r'0f47e82ee13158c890eed35858bfcda51df770fd';
