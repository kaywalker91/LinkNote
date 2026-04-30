import 'package:flutter/material.dart';
import 'package:linknote/app/theme/app_colors.dart';

/// Splits [text] into spans, highlighting every case-insensitive occurrence
/// of [query] with forest tokens. Returns null when [query] is empty or no
/// match is found, so callers can fall back to plain Text.
List<TextSpan>? buildHighlightedSpans({
  required String text,
  required String query,
}) {
  if (query.isEmpty) return null;
  final lowerText = text.toLowerCase();
  final lowerQuery = query.toLowerCase();
  final spans = <TextSpan>[];
  var cursor = 0;
  var matched = false;
  while (cursor < text.length) {
    final hit = lowerText.indexOf(lowerQuery, cursor);
    if (hit == -1) {
      spans.add(TextSpan(text: text.substring(cursor)));
      break;
    }
    if (hit > cursor) {
      spans.add(TextSpan(text: text.substring(cursor, hit)));
    }
    spans.add(
      TextSpan(
        text: text.substring(hit, hit + query.length),
        style: const TextStyle(
          backgroundColor: AppColors.forestSoft,
          color: AppColors.forestInk,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
    matched = true;
    cursor = hit + query.length;
  }
  return matched ? spans : null;
}
