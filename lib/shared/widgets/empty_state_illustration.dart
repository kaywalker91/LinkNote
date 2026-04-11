import 'package:flutter/material.dart';

class EmptyStateIllustration extends StatelessWidget {
  const EmptyStateIllustration({
    required this.primaryIcon,
    super.key,
    this.secondaryIcon,
    this.accentColor,
  });

  const EmptyStateIllustration.links({super.key})
    : primaryIcon = Icons.bookmarks_outlined,
      secondaryIcon = Icons.add,
      accentColor = null;

  const EmptyStateIllustration.collections({super.key})
    : primaryIcon = Icons.folder_outlined,
      secondaryIcon = null,
      accentColor = null;

  const EmptyStateIllustration.search({super.key})
    : primaryIcon = Icons.search,
      secondaryIcon = null,
      accentColor = null;

  const EmptyStateIllustration.noResults({super.key})
    : primaryIcon = Icons.search_off_outlined,
      secondaryIcon = null,
      accentColor = null;

  const EmptyStateIllustration.notifications({super.key})
    : primaryIcon = Icons.notifications_none_outlined,
      secondaryIcon = null,
      accentColor = null;

  final IconData primaryIcon;
  final IconData? secondaryIcon;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  color.withValues(alpha: 0.12),
                  color.withValues(alpha: 0.04),
                ],
              ),
            ),
          ),
          Icon(primaryIcon, size: 56, color: color.withValues(alpha: 0.6)),
          if (secondaryIcon != null)
            Positioned(
              right: 12,
              bottom: 12,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(secondaryIcon, size: 18, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
