import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linknote/app/theme/app_spacing.dart';
import 'package:linknote/features/link/presentation/provider/link_form_provider.dart';
import 'package:linknote/features/link/presentation/widgets/link_form_fields.dart';
import 'package:linknote/shared/extensions/context_extensions.dart';
import 'package:linknote/shared/widgets/error_state_widget.dart';
import 'package:linknote/shared/widgets/primary_button_widget.dart';
import 'package:linknote/shared/widgets/skeleton/shimmer_box.dart';

class LinkEditScreen extends ConsumerWidget {
  const LinkEditScreen({required this.linkId, super.key});
  final String linkId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formAsync = ref.watch(linkFormProvider(linkId));

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Link')),
      body: formAsync.when(
        loading: () => const _LinkEditSkeleton(),
        error: (error, _) => ErrorStateWidget.fromError(error),
        data: (formState) {
          final isSubmitting = formState.isSubmitting;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  formState.url,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                LinkFormFields(linkId: linkId),
                const SizedBox(height: AppSpacing.xxl),
                PrimaryButtonWidget(
                  label: 'Update Link',
                  isLoading: isSubmitting,
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final success = await ref
                              .read(linkFormProvider(linkId).notifier)
                              .submit();
                          if (success && context.mounted) {
                            context
                              ..showSuccessSnackBar('Link updated')
                              ..pop();
                          }
                        },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LinkEditSkeleton extends StatelessWidget {
  const _LinkEditSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: 200, height: 14, borderRadius: 4),
          SizedBox(height: AppSpacing.lg),
          ShimmerBox(width: double.infinity, height: 56, borderRadius: 12),
          SizedBox(height: AppSpacing.md),
          ShimmerBox(width: double.infinity, height: 88, borderRadius: 12),
          SizedBox(height: AppSpacing.md),
          ShimmerBox(width: double.infinity, height: 88, borderRadius: 12),
          SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              ShimmerBox(width: 60, height: 28, borderRadius: 14),
              SizedBox(width: AppSpacing.sm),
              ShimmerBox(width: 60, height: 28, borderRadius: 14),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          ShimmerBox(width: double.infinity, height: 56, borderRadius: 12),
          SizedBox(height: AppSpacing.lg),
          ShimmerBox(width: double.infinity, height: 48, borderRadius: 12),
        ],
      ),
    );
  }
}
