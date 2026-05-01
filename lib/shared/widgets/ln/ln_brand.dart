import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linknote/shared/extensions/context_extensions.dart';

/// Wordmark: `link` (Inter) + `note` (Fraunces italic · forest).
class LinkNoteWordmark extends StatelessWidget {
  const LinkNoteWordmark({super.key, this.fontSize = 18});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final inkStyle = GoogleFonts.fraunces(
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      color: palette.ink,
      letterSpacing: -0.015 * fontSize,
    );
    final forestItalic = inkStyle.copyWith(
      color: palette.forest,
      fontStyle: FontStyle.italic,
    );
    return Semantics(
      label: 'LinkNote',
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: 'link', style: inkStyle),
            TextSpan(text: 'note', style: forestItalic),
          ],
        ),
      ),
    );
  }
}

/// Simple brand mark — filled forest rounded square with white chain-L glyph.
/// Lightweight first-pass; can be replaced with SVG asset later.
class LinkNoteMark extends StatelessWidget {
  const LinkNoteMark({super.key, this.size = 32});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: context.palette.forest,
        borderRadius: BorderRadius.circular(size * 0.25),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.bookmark_rounded,
        color: Colors.white,
        size: size * 0.62,
      ),
    );
  }
}
