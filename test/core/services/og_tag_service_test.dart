import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/core/services/og_tag_service.dart';

/// Fake adapter driven by a queue of response builders keyed loosely by URL.
///
/// Each entry produces a ResponseBody given the incoming RequestOptions.
/// Call counts are exposed so tests can assert network behavior (cache hits,
/// redirect hop counts, etc.).
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this._responder);

  final ResponseBody Function(RequestOptions options) _responder;
  int callCount = 0;
  final List<String> requestedUrls = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    callCount++;
    requestedUrls.add(options.uri.toString());
    return _responder(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _body(
  String text, {
  int statusCode = 200,
  Map<String, List<String>>? headers,
}) {
  final bytes = utf8.encode(text);
  final stream = Stream<Uint8List>.value(Uint8List.fromList(bytes));
  return ResponseBody(
    stream,
    statusCode,
    headers: {
      'content-type': ['text/html; charset=utf-8'],
      ...?headers,
    },
  );
}

ResponseBody _redirect(String location, {int statusCode = 302}) {
  final stream = Stream<Uint8List>.value(Uint8List(0));
  return ResponseBody(
    stream,
    statusCode,
    headers: {
      'location': [location],
    },
  );
}

void main() {
  group('OgTagService.fetchOgTags', () {
    test(
      'returns OgTagResult with title/description/image on success',
      () async {
        final adapter = _FakeAdapter(
          (_) => _body('''
<html><head>
  <meta property="og:title" content="Hello" />
  <meta property="og:description" content="World" />
  <meta property="og:image" content="https://img.test/x.png" />
</head><body></body></html>'''),
        );
        final dio = Dio()..httpClientAdapter = adapter;
        final service = OgTagService(dio: dio);
        addTearDown(service.close);

        final result = await service.fetchOgTags('https://example.com');

        expect(result.isSuccess, isTrue);
        expect(result.data!.title, 'Hello');
        expect(result.data!.description, 'World');
        expect(result.data!.imageUrl, 'https://img.test/x.png');
      },
    );

    test('falls back to <title> when no og:title tag', () async {
      final adapter = _FakeAdapter(
        (_) => _body(
          '<html><head><title>Plain Title</title></head><body></body></html>',
        ),
      );
      final service = OgTagService(dio: Dio()..httpClientAdapter = adapter);
      addTearDown(service.close);

      final result = await service.fetchOgTags('https://example.com');

      expect(result.isSuccess, isTrue);
      expect(result.data!.title, 'Plain Title');
      expect(result.data!.description, isNull);
    });

    test('returns empty OgTagResult for empty body', () async {
      final adapter = _FakeAdapter((_) => _body(''));
      final service = OgTagService(dio: Dio()..httpClientAdapter = adapter);
      addTearDown(service.close);

      final result = await service.fetchOgTags('https://example.com');

      expect(result.isSuccess, isTrue);
      expect(result.data!.title, isNull);
    });

    test('caches results — second call does not hit network', () async {
      final adapter = _FakeAdapter(
        (_) => _body(
          '<html><head><meta property="og:title" content="Cached"/></head></html>',
        ),
      );
      final service = OgTagService(dio: Dio()..httpClientAdapter = adapter);
      addTearDown(service.close);

      await service.fetchOgTags('https://example.com');
      await service.fetchOgTags('https://example.com');

      expect(adapter.callCount, 1);
    });

    test('returns NetworkFailure on connection timeout', () async {
      final adapter = _FakeAdapter(
        (opts) => throw DioException(
          requestOptions: opts,
          type: DioExceptionType.connectionTimeout,
          message: 'timeout',
        ),
      );
      final service = OgTagService(dio: Dio()..httpClientAdapter = adapter);
      addTearDown(service.close);

      final result = await service.fetchOgTags('https://example.com');

      expect(result.isFailure, isTrue);
      expect(result.failure, isA<NetworkFailure>());
    });

    test('returns NetworkFailure on receive timeout', () async {
      final adapter = _FakeAdapter(
        (opts) => throw DioException(
          requestOptions: opts,
          type: DioExceptionType.receiveTimeout,
        ),
      );
      final service = OgTagService(dio: Dio()..httpClientAdapter = adapter);
      addTearDown(service.close);

      final result = await service.fetchOgTags('https://example.com');

      expect(result.isFailure, isTrue);
      expect(result.failure, isA<NetworkFailure>());
    });

    test('returns ServerFailure with 404 statusCode', () async {
      final adapter = _FakeAdapter((_) => _body('Not Found', statusCode: 404));
      final service = OgTagService(dio: Dio()..httpClientAdapter = adapter);
      addTearDown(service.close);

      final result = await service.fetchOgTags('https://example.com');

      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ServerFailure>());
      final failure = result.failure! as ServerFailure;
      expect(failure.statusCode, 404);
    });

    test('returns ServerFailure with 500 statusCode', () async {
      final adapter = _FakeAdapter(
        (_) => _body('oops', statusCode: 500),
      );
      final service = OgTagService(dio: Dio()..httpClientAdapter = adapter);
      addTearDown(service.close);

      final result = await service.fetchOgTags('https://example.com');

      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ServerFailure>());
      expect((result.failure! as ServerFailure).statusCode, 500);
    });

    test('follows HTTPS → HTTPS redirect', () async {
      var hop = 0;
      final adapter = _FakeAdapter((opts) {
        hop++;
        if (hop == 1) return _redirect('https://final.example.com/');
        return _body(
          '<html><head><meta property="og:title" content="Final"/></head></html>',
        );
      });
      final service = OgTagService(dio: Dio()..httpClientAdapter = adapter);
      addTearDown(service.close);

      final result = await service.fetchOgTags('https://origin.example.com');

      expect(
        result.isSuccess,
        isTrue,
        reason: 'Expected success, got failure: ${result.failure}',
      );
      expect(result.data!.title, 'Final');
      expect(adapter.callCount, 2);
    });

    test('blocks HTTPS → HTTP redirect downgrade', () async {
      final adapter = _FakeAdapter(
        (_) => _redirect('http://insecure.example.com/'),
      );
      final service = OgTagService(dio: Dio()..httpClientAdapter = adapter);
      addTearDown(service.close);

      final result = await service.fetchOgTags('https://origin.example.com');

      expect(
        result.isFailure,
        isTrue,
        reason: 'HTTPS→HTTP downgrade must be refused',
      );
    });

    test('allows HTTP → HTTP redirect (no downgrade concern)', () async {
      var hop = 0;
      final adapter = _FakeAdapter((opts) {
        hop++;
        if (hop == 1) return _redirect('http://final.example.com/');
        return _body(
          '<html><head><title>HTTP OK</title></head></html>',
        );
      });
      final service = OgTagService(dio: Dio()..httpClientAdapter = adapter);
      addTearDown(service.close);

      final result = await service.fetchOgTags('http://origin.example.com');

      expect(result.isSuccess, isTrue);
      expect(result.data!.title, 'HTTP OK');
    });

    test('rejects after too many redirects (loop guard)', () async {
      final adapter = _FakeAdapter(
        (_) => _redirect('https://loop.example.com/next'),
      );
      final service = OgTagService(dio: Dio()..httpClientAdapter = adapter);
      addTearDown(service.close);

      final result = await service.fetchOgTags('https://origin.example.com');

      expect(result.isFailure, isTrue);
    });

    test('handles malformed HTML gracefully', () async {
      final adapter = _FakeAdapter(
        (_) => _body('<html><head><meta property="og:title" content=unquoted'),
      );
      final service = OgTagService(dio: Dio()..httpClientAdapter = adapter);
      addTearDown(service.close);

      final result = await service.fetchOgTags('https://example.com');

      // html parser is forgiving — we should still get a Result (success or
      // empty), never crash.
      expect(result.isSuccess || result.isFailure, isTrue);
    });
  });
}
