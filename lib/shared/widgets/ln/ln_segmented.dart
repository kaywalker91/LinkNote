import 'package:flutter/material.dart';
import 'package:linknote/app/theme/app_radius.dart';
import 'package:linknote/app/theme/app_shadows.dart';
import 'package:linknote/app/theme/app_text_styles.dart';
import 'package:linknote/shared/extensions/context_extensions.dart';

/// Pill segmented control — bg-sunk track, white+sh1 active segment.
class LnSegmented extends StatelessWidget {
  const LnSegmented({
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    super.key,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: palette.bgSunk,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: _Segment(
                label: labels[i],
                selected: i == selectedIndex,
                onTap: () => onChanged(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? palette.bg : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.full),
          boxShadow: selected ? AppShadows.sh1 : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: selected ? palette.ink : palette.ink3,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 12.5,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
