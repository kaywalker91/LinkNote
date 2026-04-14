import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linknote/app/theme/app_spacing.dart';
import 'package:linknote/features/link/domain/entity/tag_entity.dart';
import 'package:linknote/features/link/presentation/provider/link_form_provider.dart';
import 'package:linknote/shared/extensions/context_extensions.dart';
import 'package:linknote/shared/widgets/error_state_widget.dart';
import 'package:linknote/shared/widgets/primary_button_widget.dart';
import 'package:linknote/shared/widgets/skeleton/shimmer_box.dart';
import 'package:uuid/uuid.dart';

class LinkEditScreen extends ConsumerStatefulWidget {
  const LinkEditScreen({required this.linkId, super.key});
  final String linkId;

  @override
  ConsumerState<LinkEditScreen> createState() => _LinkEditScreenState();
}

class _LinkEditScreenState extends ConsumerState<LinkEditScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _memoController = TextEditingController();
  final _tagController = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _memoController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _addTag() {
    final text = _tagController.text.trim();
    if (text.isEmpty) return;
    ref
        .read(linkFormProvider(widget.linkId).notifier)
        .addTag(
          TagEntity(
            id: const Uuid().v4(),
            name: text,
            color: '#6750A4',
          ),
        );
    _tagController.clear();
  }

  void _syncControllers(LinkFormState state) {
    if (_initialized) return;
    _titleController.text = state.title;
    _descController.text = state.description;
    _memoController.text = state.memo;
    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final formAsync = ref.watch(linkFormProvider(widget.linkId));

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Link')),
      body: formAsync.when(
        loading: () => const _LinkEditSkeleton(),
        error: (error, _) => ErrorStateWidget.fromError(error),
        data: (formState) {
          _syncControllers(formState);
          final isSubmitting = formState.isSubmitting;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (formState.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Text(
                      formState.errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                Text(
                  formState.url,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title *'),
                  onChanged: (v) => ref
                      .read(linkFormProvider(widget.linkId).notifier)
                      .updateTitle(v),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _descController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Description'),
                  onChanged: (v) => ref
                      .read(linkFormProvider(widget.linkId).notifier)
                      .updateDescription(v),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _memoController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Notes'),
                  onChanged: (v) => ref
                      .read(linkFormProvider(widget.linkId).notifier)
                      .updateMemo(v),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (formState.tags.isNotEmpty) ...[
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xs,
                    children: formState.tags
                        .map(
                          (tag) => Chip(
                            label: Text(tag.name),
                            onDeleted: () => ref
                                .read(linkFormProvider(widget.linkId).notifier)
                                .removeTag(tag.id),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                TextField(
                  controller: _tagController,
                  decoration: InputDecoration(
                    labelText: 'Tags',
                    hintText: 'Add a tag and press enter',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _addTag,
                    ),
                  ),
                  onSubmitted: (_) => _addTag(),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    const Text('Favorite'),
                    const Spacer(),
                    Switch(
                      value: formState.isFavorite,
                      onChanged: (_) => ref
                          .read(linkFormProvider(widget.linkId).notifier)
                          .toggleFavorite(),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),
                PrimaryButtonWidget(
                  label: 'Update Link',
                  isLoading: isSubmitting,
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final success = await ref
                              .read(linkFormProvider(widget.linkId).notifier)
                              .submit();
                          if (success && context.mounted) {
                            context
                              ..showSuccessSnackBar('링크가 수정되었습니다')
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
