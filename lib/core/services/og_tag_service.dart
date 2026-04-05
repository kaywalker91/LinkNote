import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'og_tag_service.g.dart';

class OgTagResult {
  const OgTagResult({this.title, this.description, this.imageUrl});
  final String? title;
  final String? description;
  final String? imageUrl;
}

class OgTagService {
  OgTagService()
    : _dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {
            'User-Agent': 'Mozilla/5.0 (compatible; LinkNote/1.0)',
          },
        ),
      );

  final Dio _dio;

  Future<OgTagResult> fetchOgTags(String url) async {
    try {
      final response = await _dio.get<String>(url);
      final body = response.data;
      if (body == null) return const OgTagResult();

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

      // Fallback to <title> if no OG title
      ogTitle ??= document.head?.querySelector('title')?.text;

      return OgTagResult(
        title: ogTitle,
        description: ogDescription,
        imageUrl: ogImage,
      );
    } on Exception catch (_) {
      return const OgTagResult();
    }
  }
}

@riverpod
OgTagService ogTagService(Ref ref) {
  return OgTagService();
}
