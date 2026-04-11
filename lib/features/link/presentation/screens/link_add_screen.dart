import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linknote/app/theme/app_spacing.dart';
import 'package:linknote/features/link/domain/entity/tag_entity.dart';
import 'package:linknote/features/link/presentation/provider/link_form_provider.dart';
import 'package:linknote/shared/extensions/context_extensions.dart';
import 'package:linknote/shared/widgets/primary_button_widget.dart';

class LinkAddScreen extends ConsumerStatefulWidget {
  const LinkAddScreen({super.key});

  @override
  ConsumerState<LinkAddScreen> createState() => _LinkAddScreenState();
}

class _LinkAddScreenState extends ConsumerState<LinkAddScreen> {
  final _urlController = TextEditingController();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _memoController = TextEditingController();
  final _tagController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
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
        .read(linkFormProvider(null).notifier)
        .addTag(
          TagEntity(
            id: 'tag_${DateTime.now().millisecondsSinceEpoch}',
            name: text,
            color: '#6750A4',
          ),
        );
    _tagController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final formAsync = ref.watch(linkFormProvider(null));
    final formState = formAsync.value;
    final isSubmitting = formState?.isSubmitting ?? false;
    final isParsingOg = formState?.isParsingOg ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Link'),
        actions: [
          if (isParsingOg)
            const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (formState?.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Text(
                  formState!.errorMessage!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            TextField(
              controller: _urlController,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                labelText: 'URL *',
                hintText: 'https://',
                prefixIcon: Icon(Icons.link),
              ),
              onChanged: (v) =>
                  ref.read(linkFormProvider(null).notifier).updateUrl(v),
              onEditingComplete: () async {
                final url = _urlController.text.trim();
                if (url.isNotEmpty) {
                  await ref
                      .read(linkFormProvider(null).notifier)
                      .parseOgTags(url);
                }
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title *'),
              onChanged: (v) =>
                  ref.read(linkFormProvider(null).notifier).updateTitle(v),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description'),
              onChanged: (v) => ref
                  .read(linkFormProvider(null).notifier)
                  .updateDescription(v),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _memoController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Notes'),
              onChanged: (v) =>
                  ref.read(linkFormProvider(null).notifier).updateMemo(v),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (formState != null && formState.tags.isNotEmpty) ...[
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: formState.tags
                    .map(
                      (tag) => Chip(
                        label: Text(tag.name),
                        onDeleted: () => ref
                            .read(linkFormProvider(null).notifier)
                            .removeTag(tag.id),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                  value: formState?.isFavorite ?? false,
                  onChanged: (_) => ref
                      .read(linkFormProvider(null).notifier)
                      .toggleFavorite(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            PrimaryButtonWidget(
              label: 'Save Link',
              isLoading: isSubmitting,
              onPressed: isSubmitting
                  ? null
                  : () async {
                      final success = await ref
                          .read(linkFormProvider(null).notifier)
                          .submit();
                      if (success && context.mounted) {
                        context.showSuccessSnackBar('링크가 저장되었습니다');
                        context.pop();
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }
}
