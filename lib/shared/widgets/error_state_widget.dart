import 'package:flutter/material.dart';
import 'package:linknote/app/theme/app_spacing.dart';
import 'package:linknote/core/error/failure_ui.dart';

class ErrorStateWidget extends StatelessWidget {
  const ErrorStateWidget({
    required this.message,
    super.key,
    this.title = '오류가 발생했습니다',
    this.icon = Icons.error_outline_rounded,
    this.isRetryable = true,
    this.onRetry,
  });

  factory ErrorStateWidget.fromError(
    Object error, {
    Key? key,
    VoidCallback? onRetry,
  }) {
    final ui = failureUiFromError(error);
    return ErrorStateWidget(
      key: key,
      title: ui.title,
      message: ui.message,
      icon: ui.icon,
      isRetryable: ui.isRetryable,
      onRetry: onRetry,
    );
  }

  final String title;
  final String message;
  final IconData icon;
  final bool isRetryable;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.huge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: colorScheme.error),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colorScheme.outline),
              textAlign: TextAlign.center,
            ),
            if (isRetryable && onRetry != null) ...[
              const SizedBox(height: AppSpacing.xxl),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('다시 시도'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
