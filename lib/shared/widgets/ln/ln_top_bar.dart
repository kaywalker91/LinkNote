import 'package:flutter/material.dart';
import 'package:linknote/app/theme/app_colors.dart';
import 'package:linknote/app/theme/app_text_styles.dart';

/// Top bar variants per handoff: standard (56h + bottom border) and large (display title below).
class LnTopBar extends StatelessWidget implements PreferredSizeWidget {
  const LnTopBar({
    super.key,
    this.leading,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.displayTitle,
    this.displaySubtitle,
    this.actions = const <Widget>[],
    this.large = false,
  });

  final Widget? leading;
  final String? title;
  final Widget? titleWidget;
  final String? subtitle;
  final String? displayTitle;
  final String? displaySubtitle;
  final List<Widget> actions;
  final bool large;

  static const double _standardHeight = 56;
  static const double _largeExtra = 92;

  @override
  Size get preferredSize => Size.fromHeight(
    large ? _standardHeight + _largeExtra : _standardHeight,
  );

  @override
  Widget build(BuildContext context) {
    final content = <Widget>[
      SizedBox(
        height: _standardHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              ?leading,
              if (leading != null) const SizedBox(width: 8),
              Expanded(
                child:
                    titleWidget ??
                    (title != null
                        ? Text(
                            title!,
                            style: AppTextStyles.titleL.copyWith(
                              color: AppColors.ink,
                            ),
                            overflow: TextOverflow.ellipsis,
                          )
                        : const SizedBox.shrink()),
              ),
              ...actions,
            ],
          ),
        ),
      ),
      if (large) _buildLargeBlock(),
    ];

    return Material(
      color: AppColors.bg,
      child: SafeArea(
        bottom: false,
        child: DecoratedBox(
          decoration: large
              ? const BoxDecoration()
              : const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.line),
                  ),
                ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: content,
          ),
        ),
      ),
    );
  }

  Widget _buildLargeBlock() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (displayTitle != null)
            Text(
              displayTitle!,
              style: AppTextStyles.heading1.copyWith(color: AppColors.ink),
            ),
          if (displaySubtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              displaySubtitle!,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.ink3),
            ),
          ],
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: AppTextStyles.caption.copyWith(color: AppColors.ink3),
            ),
          ],
        ],
      ),
    );
  }
}
