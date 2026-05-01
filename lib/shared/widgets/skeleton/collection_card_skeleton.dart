import 'package:flutter/material.dart';
import 'package:linknote/app/theme/app_colors.dart';
import 'package:linknote/app/theme/app_radius.dart';
import 'package:linknote/app/theme/app_spacing.dart';
import 'package:linknote/shared/widgets/skeleton/shimmer_box.dart';

class CollectionCardSkeleton extends StatelessWidget {
  const CollectionCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.line),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ShimmerBox(width: double.infinity, height: 78, borderRadius: 0),
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm + 2,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 120, height: 14, borderRadius: 4),
                SizedBox(height: 6),
                ShimmerBox(width: 64, height: 11, borderRadius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
