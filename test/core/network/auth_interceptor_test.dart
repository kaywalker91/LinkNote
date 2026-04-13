import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/core/network/auth_interceptor.dart';

void main() {
  group('AuthInterceptor', () {
    test('should call onUnauthorized when 401 error occurs', () {
      // Arrange
      var callbackCalled = false;
      final interceptor = AuthInterceptor(
        onUnauthorized: () async => callbackCalled = true,
      );
      final handler = _MockErrorHandler();
      final err = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 401,
        ),
      );

      // Act
      interceptor.onError(err, handler);

      // Assert
      expect(callbackCalled, isTrue);
      expect(handler.nextCalled, isTrue);
    });

    test('should not call onUnauthorized on non-401 errors', () {
      // Arrange
      var callbackCalled = false;
      final interceptor = AuthInterceptor(
        onUnauthorized: () async => callbackCalled = true,
      );
      final handler = _MockErrorHandler();
      final err = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 403,
        ),
      );

      // Act
      interceptor.onError(err, handler);

      // Assert
      expect(callbackCalled, isFalse);
      expect(handler.nextCalled, isTrue);
    });

    test('should work when onUnauthorized is null', () {
      // Arrange
      final interceptor = AuthInterceptor();
      final handler = _MockErrorHandler();
      final err = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 401,
        ),
      );

      // Act & Assert — no crash
      interceptor.onError(err, handler);
      expect(handler.nextCalled, isTrue);
    });
  });
}

class _MockErrorHandler extends ErrorInterceptorHandler {
  bool nextCalled = false;

  @override
  void next(DioException err) {
    nextCalled = true;
  }
}
