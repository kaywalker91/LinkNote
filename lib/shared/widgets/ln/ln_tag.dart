import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linknote/app/theme/app_radius.dart';
import 'package:linknote/shared/widgets/ln/ln_tags.dart';

/// Small pill tag: `#name` · radius full · tone lookup.
class LnTag extends StatelessWidget {
  const LnTag({
    required this.name,
    super.key,
    this.tone,
    this.onTap,
    this.dense = false,
  });

  final String name;
  final LnTagTone? tone;
  final VoidCallback? onTap;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final effectiveTone = tone ?? lnTagToneFor(name);
    final fg = effectiveTone.foreground(context);
    final bg = effectiveTone.background(context);
    final horizontal = dense ? 8.0 : 10.0;
    final vertical = dense ? 2.0 : 3.0;

    final pill = Container(
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '#',
              style: GoogleFonts.inter(
                fontSize: dense ? 11 : 12,
                fontWeight: FontWeight.w600,
                color: fg.withValues(alpha: 0.6),
              ),
            ),
            TextSpan(
              text: name,
              style: GoogleFonts.inter(
                fontSize: dense ? 11 : 12,
                fontWeight: FontWeight.w500,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
    if (onTap == null) return pill;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: pill,
    );
  }
}
