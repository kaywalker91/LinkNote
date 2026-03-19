import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:linknote/shared/widgets/skeleton/shimmer_box.dart';

class OgThumbnailWidget extends StatelessWidget {
  const OgThumbnailWidget({
    super.key,
    this.thumbnailUrl,
    this.size = 80,
    this.borderRadius = 12,
  });

  final String? thumbnailUrl;
  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    if (thumbnailUrl == null || thumbnailUrl!.isEmpty) {
      return _placeholder(context);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: thumbnailUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (context, url) =>
            ShimmerBox(width: size, height: size, borderRadius: borderRadius),
        errorWidget: (context, url, error) => _placeholder(context),
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Icon(
        Icons.link_rounded,
        color: Theme.of(context).colorScheme.outline,
        size: size * 0.4,
      ),
    );
  }
}
