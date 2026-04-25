import 'package:flutter/material.dart';
import 'package:linknote/app/theme/app_colors.dart';
import 'package:linknote/app/theme/app_radius.dart';

/// 40×40 tap target · radius 10 · optional rose badge dot.
class LnIconBtn extends StatelessWidget {
  const LnIconBtn({
    required this.icon,
    super.key,
    this.onPressed,
    this.badge = false,
    this.tooltip,
    this.color,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final bool badge;
  final String? tooltip;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? AppColors.ink;
    final button = Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Stack(
            children: [
              Center(
                child: Icon(icon, size: 20, color: iconColor),
              ),
              if (badge)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: AppColors.rose,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.bg, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    final effectiveTooltip = tooltip;
    if (effectiveTooltip == null) return button;
    return Tooltip(message: effectiveTooltip, child: button);
  }
}
