import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/core/config/app_config.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/core/network/auth_interceptor.dart';
import 'package:linknote/core/network/dio_client.dart';
import 'package:linknote/features/auth/domain/usecase/sign_out_usecase.dart';
import 'package:linknote/features/auth/presentation/provider/auth_di_providers.dart';
import 'package:linknote/shared/providers/session_expired_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockSignOutUsecase extends Mock implements SignOutUsecase {}

void main() {
  // appEnv는 late final 전역이므로 테스트 프로세스 전체에서 한 번만 초기화.
  // 다른 테스트가 먼저 초기화한 경우 재할당은 LateInitializationError를
  // 던지므로, 여기서 한 번만 assignment를 시도한다.
  setUpAll(_ensureAppEnvInitialized);

  group('dioProvider onUnauthorized', () {
    late MockSignOutUsecase mockSignOutUsecase;
    late ProviderContainer container;

    setUp(() {
      mockSignOutUsecase = MockSignOutUsecase();
      when(() => mockSignOutUsecase.call())
          .thenAnswer((_) async => success(null));

      container = ProviderContainer(
        overrides: [
          signOutUsecaseProvider.overrideWith((_) => mockSignOutUsecase),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test(
      'should invoke SignOutUsecase when AuthInterceptor receives 401',
      () async {
        // Arrange — dioProvider를 읽으면 AuthInterceptor가 설정된 Dio 반환.
        final dio = container.read(dioProvider);
        final authInterceptor = dio.interceptors
            .whereType<AuthInterceptor>()
            .first;
        final handler = _StubErrorHandler();
        final err = DioException(
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 401,
          ),
        );

        // Act — 401 주입.
        authInterceptor.onError(err, handler);

        // onUnauthorized 콜백이 async이므로 마이크로태스크 큐 flush.
        await Future<void>.delayed(Duration.zero);

        // Assert
        verify(() => mockSignOutUsecase.call()).called(1);
        expect(container.read(sessionExpiredProvider), isTrue);
      },
    );

    test(
      'should NOT invoke SignOutUsecase on non-401 errors',
      () async {
        // Arrange
        final dio = container.read(dioProvider);
        final authInterceptor = dio.interceptors
            .whereType<AuthInterceptor>()
            .first;
        final handler = _StubErrorHandler();
        final err = DioException(
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 500,
          ),
        );

        // Act
        authInterceptor.onError(err, handler);
        await Future<void>.delayed(Duration.zero);

        // Assert
        verifyNever(() => mockSignOutUsecase.call());
      },
    );
  });
}

class _StubErrorHandler extends ErrorInterceptorHandler {
  @override
  void next(DioException err) {}
}

bool _appEnvInitialized = false;

void _ensureAppEnvInitialized() {
  if (_appEnvInitialized) return;
  appEnv = const AppEnv(
    flavor: Flavor.dev,
    supabaseUrl: 'https://test.supabase.co',
    supabaseAnonKey: 'test-anon-key',
  );
  _appEnvInitialized = true;
}
