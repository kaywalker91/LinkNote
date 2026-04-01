import 'package:flutter/material.dart';
import 'package:linknote/app/theme/app_spacing.dart';
import 'package:linknote/shared/widgets/skeleton/shimmer_box.dart';

class NotificationTileSkeleton extends StatelessWidget {
  const NotificationTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          ShimmerBox(width: 40, height: 40, borderRadius: 20),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: double.infinity, height: 14, borderRadius: 4),
                SizedBox(height: 6),
                ShimmerBox(width: 150, height: 12, borderRadius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
