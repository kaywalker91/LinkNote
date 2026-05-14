import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/shared/utils/highlight_text.dart';

void main() {
  group('buildHighlightedSpans', () {
    const bg = Color(0xFFAABBCC);
    const fg = Color(0xFF112233);

    test('should return null when query is empty', () {
      final spans = buildHighlightedSpans(
        text: 'Flutter Forest',
        query: '',
        highlightBg: bg,
        highlightFg: fg,
      );
      expect(spans, isNull);
    });

    test('should return null when query does not match', () {
      final spans = buildHighlightedSpans(
        text: 'Flutter Forest',
        query: 'xyz',
        highlightBg: bg,
        highlightFg: fg,
      );
      expect(spans, isNull);
    });

    test('should split text into spans on case-insensitive match', () {
      final spans = buildHighlightedSpans(
        text: 'Flutter Forest Guide',
        query: 'forest',
        highlightBg: bg,
        highlightFg: fg,
      );
      expect(spans, isNotNull);
      final highlight = spans!.firstWhere(
        (s) => s.text == 'Forest',
        orElse: () => const TextSpan(text: ''),
      );
      expect(highlight.text, 'Forest');
      expect(highlight.style?.backgroundColor, bg);
      expect(highlight.style?.color, fg);
      expect(highlight.style?.fontWeight, FontWeight.w600);
    });

    test('should highlight every occurrence', () {
      final spans = buildHighlightedSpans(
        text: 'aa bb aa',
        query: 'aa',
        highlightBg: bg,
        highlightFg: fg,
      );
      expect(spans, isNotNull);
      final hits = spans!.where((s) => s.text == 'aa').toList();
      expect(hits.length, 2);
    });
  });
}
