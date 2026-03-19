// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Auth)
final authProvider = AuthProvider._();

final class AuthProvider extends $AsyncNotifierProvider<Auth, AuthStateEntity> {
  AuthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authHash();

  @$internal
  @override
  Auth create() => Auth();
}

String _$authHash() => r'ae354a4e6a55a6d3486e19ebd47a46af262d9cc3';

abstract class _$Auth extends $AsyncNotifier<AuthStateEntity> {
  FutureOr<AuthStateEntity> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AuthStateEntity>, AuthStateEntity>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AuthStateEntity>, AuthStateEntity>,
              AsyncValue<AuthStateEntity>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
