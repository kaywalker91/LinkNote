import 'package:flutter/material.dart';
import 'package:linknote/app/theme/app_spacing.dart';
import 'package:linknote/shared/widgets/skeleton/shimmer_box.dart';

class CollectionCardSkeleton extends StatelessWidget {
  const CollectionCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: double.infinity, height: 120, borderRadius: 12),
          SizedBox(height: 8),
          ShimmerBox(width: 160, height: 16, borderRadius: 4),
          SizedBox(height: 4),
          ShimmerBox(width: 100, height: 12, borderRadius: 4),
        ],
      ),
    );
  }
}
