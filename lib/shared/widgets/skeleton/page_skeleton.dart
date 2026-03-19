import 'package:flutter/material.dart';
import 'package:linknote/shared/widgets/skeleton/link_card_skeleton.dart';

class PageSkeleton extends StatelessWidget {
  const PageSkeleton({super.key, this.itemCount = 8});
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) => const LinkCardSkeleton(),
    );
  }
}
