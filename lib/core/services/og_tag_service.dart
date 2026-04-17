import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'og_tag_service.g.dart';

class OgTagResult {
  const OgTagResult({this.title, this.description, this.imageUrl});
  final String? title;
  final String? description;
  final String? imageUrl;
}

class OgTagService {
  OgTagService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
              headers: {
                'User-Agent': 'Mozilla/5.0 (compatible; LinkNote/1.0)',
              },
            ),
          );

  static final Options _requestOptions = Options(
    // Redirects are handled manually to enforce the HTTPS→HTTPS policy.
    followRedirects: false,
    validateStatus: (status) => status != null && status >= 200 && status < 400,
    responseType: ResponseType.plain,
  );

  final Dio _dio;
  final Map<String, _CacheEntry> _cache = {};
  static const Duration _cacheTtl = Duration(minutes: 30);
  static const int _maxCacheSize = 100;
  static const int _maxRedirects = 3;

  Future<Result<OgTagResult>> fetchOgTags(String url) async {
    final cached = _cache[url];
    if (cached != null && !cached.isExpired) {
      return success(cached.result);
    }
    try {
      final response = await _fetchFollowingRedirects(url);
      final body = response.data;
      if (body == null || body.isEmpty) {
        return success(const OgTagResult());
      }

      final document = html_parser.parse(body);
      final metaTags = document.head?.querySelectorAll('meta') ?? [];

      String? ogTitle;
      String? ogDescription;
      String? ogImage;

      for (final meta in metaTags) {
        final property = meta.attributes['property'] ?? '';
        final name = meta.attributes['name'] ?? '';
        final content = meta.attributes['content'];
        if (content == null || content.isEmpty) continue;

        if (property == 'og:title' || name == 'og:title') {
          ogTitle = content;
        } else if (property == 'og:description' || name == 'og:description') {
          ogDescription = content;
        } else if (property == 'og:image' || name == 'og:image') {
          ogImage = content;
        }
      }

      ogTitle ??= document.head?.querySelector('title')?.text;

      final result = OgTagResult(
        title: ogTitle,
        description: ogDescription,
        imageUrl: ogImage,
      );
      _cache[url] = _CacheEntry(result: result);
      _evictIfNeeded();
      return success(result);
    } on DioException catch (e) {
      return error(_mapDioError(e));
    } on Exception catch (e) {
      return error(Failure.unknown(message: 'Failed to parse page: $e'));
    }
  }

  Future<Response<String>> _fetchFollowingRedirects(String url) async {
    final originalScheme = Uri.parse(url).scheme.toLowerCase();
    var current = url;
    for (var hop = 0; hop <= _maxRedirects; hop++) {
      final response = await _dio.get<String>(
        current,
        options: _requestOptions,
      );
      final status = response.statusCode ?? 0;
      if (status < 300) return response;
      final location = response.headers.value('location');
      if (location == null || location.isEmpty) return response;
      final next = Uri.parse(current).resolve(location).toString();
      final nextScheme = Uri.parse(next).scheme.toLowerCase();
      if (originalScheme == 'https' && nextScheme == 'http') {
        throw DioException(
          requestOptions: response.requestOptions,
          type: DioExceptionType.badResponse,
          message: 'Refusing HTTPS→HTTP redirect downgrade',
        );
      }
      current = next;
    }
    throw DioException(
      requestOptions: RequestOptions(path: url),
      type: DioExceptionType.badResponse,
      message: 'Too many redirects (>$_maxRedirects)',
    );
  }

  Failure _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const Failure.network(message: 'Request timed out');
      case DioExceptionType.connectionError:
      case DioExceptionType.cancel:
        return Failure.network(message: e.message ?? 'Network error');
      case DioExceptionType.badResponse:
        return Failure.server(
          message: e.message ?? 'Server error',
          statusCode: e.response?.statusCode,
        );
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return Failure.unknown(message: e.message ?? 'Unknown error');
    }
  }

  void _evictIfNeeded() {
    if (_cache.length <= _maxCacheSize) return;
    final sorted = _cache.entries.toList()
      ..sort((a, b) => a.value.createdAt.compareTo(b.value.createdAt));
    for (final entry in sorted.take(_cache.length - _maxCacheSize)) {
      _cache.remove(entry.key);
    }
  }

  void clearCache() => _cache.clear();

  void close() {
    _dio.close();
    _cache.clear();
  }
}

class _CacheEntry {
  _CacheEntry({required this.result}) : createdAt = DateTime.now();

  final OgTagResult result;
  final DateTime createdAt;

  bool get isExpired =>
      DateTime.now().difference(createdAt) > OgTagService._cacheTtl;
}

@Riverpod(keepAlive: true)
OgTagService ogTagService(Ref ref) {
  final service = OgTagService();
  ref.onDispose(service.close);
  return service;
}
