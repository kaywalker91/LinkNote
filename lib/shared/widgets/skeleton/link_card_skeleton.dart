import 'package:flutter/material.dart';
import 'package:linknote/app/theme/app_spacing.dart';
import 'package:linknote/shared/widgets/skeleton/shimmer_box.dart';

class LinkCardSkeleton extends StatelessWidget {
  const LinkCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding, vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: 80, height: 80, borderRadius: 12),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(
                    width: double.infinity, height: 16, borderRadius: 4),
                SizedBox(height: 8),
                ShimmerBox(width: 200, height: 12, borderRadius: 4),
                SizedBox(height: 8),
                Row(children: [
                  ShimmerBox(width: 60, height: 24, borderRadius: 12),
                  SizedBox(width: 8),
                  ShimmerBox(width: 60, height: 24, borderRadius: 12),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
