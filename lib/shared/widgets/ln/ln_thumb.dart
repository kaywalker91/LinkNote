import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:linknote/app/theme/app_radius.dart';
import 'package:linknote/shared/widgets/ln/ln_tags.dart';
import 'package:linknote/shared/widgets/skeleton/shimmer_box.dart';

enum LnThumbSize { sm, md, lg }

extension on LnThumbSize {
  double get edge {
    switch (this) {
      case LnThumbSize.sm:
        return 56;
      case LnThumbSize.md:
        return 72;
      case LnThumbSize.lg:
        return 170;
    }
  }

  double get radius {
    switch (this) {
      case LnThumbSize.sm:
        return AppRadius.md; // 10
      case LnThumbSize.md:
        return AppRadius.md; // 10
      case LnThumbSize.lg:
        return AppRadius.lg; // 14
    }
  }
}

/// Gradient placeholder / OG image preview. Fills full width when [size] is [LnThumbSize.lg].
class LnThumb extends StatelessWidget {
  const LnThumb({
    super.key,
    this.url,
    this.size = LnThumbSize.md,
    this.tone = LnTagTone.forest,
    this.hostPill,
  });

  final String? url;
  final LnThumbSize size;
  final LnTagTone tone;
  final String? hostPill;

  @override
  Widget build(BuildContext context) {
    final radius = size.radius;
    Widget child;
    if (url != null && url!.isNotEmpty) {
      child = CachedNetworkImage(
        imageUrl: url!,
        fit: BoxFit.cover,
        placeholder: (_, __) => ShimmerBox(
          width: size.edge,
          height: size.edge,
          borderRadius: radius,
        ),
        errorWidget: (_, __, ___) => _gradient(),
      );
    } else {
      child = _gradient();
    }

    Widget wrapped = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: child,
    );

    if (size == LnThumbSize.lg) {
      wrapped = AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            wrapped,
            if (hostPill != null)
              Positioned(
                top: 10,
                left: 10,
                child: _HostPill(label: hostPill!),
              ),
          ],
        ),
      );
    } else {
      wrapped = SizedBox(
        width: size.edge,
        height: size.edge,
        child: wrapped,
      );
    }
    return wrapped;
  }

  Widget _gradient() {
    final a = tone.background;
    final b = tone.foreground.withValues(alpha: 0.25);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [a, b],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.link_rounded,
          color: tone.foreground.withValues(alpha: 0.35),
          size: _iconSize,
        ),
      ),
    );
  }

  double get _iconSize {
    switch (size) {
      case LnThumbSize.sm:
        return 22;
      case LnThumbSize.md:
        return 28;
      case LnThumbSize.lg:
        return 48;
    }
  }
}

class _HostPill extends StatelessWidget {
  const _HostPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: GoogleFonts.jetBrainsMono(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
