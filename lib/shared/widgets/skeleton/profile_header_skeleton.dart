import 'package:flutter/material.dart';
import 'package:linknote/app/theme/app_spacing.dart';
import 'package:linknote/shared/widgets/skeleton/shimmer_box.dart';

class ProfileHeaderSkeleton extends StatelessWidget {
  const ProfileHeaderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        children: [
          ShimmerBox(width: 80, height: 80, borderRadius: 40),
          SizedBox(height: AppSpacing.md),
          ShimmerBox(width: 160, height: 18, borderRadius: 4),
          SizedBox(height: 8),
          ShimmerBox(width: 200, height: 14, borderRadius: 4),
        ],
      ),
    );
  }
}
