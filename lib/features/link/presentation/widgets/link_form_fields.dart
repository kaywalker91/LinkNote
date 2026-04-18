import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linknote/app/theme/app_colors.dart';
import 'package:linknote/app/theme/app_spacing.dart';
import 'package:linknote/features/link/domain/entity/tag_entity.dart';
import 'package:linknote/features/link/presentation/provider/link_form_provider.dart';
import 'package:uuid/uuid.dart';

/// Shared form fields for add/edit link screens.
///
/// Owns the TextEditingControllers for title/description/memo/tag input.
/// Controllers mirror provider state via `ref.listen`, so programmatic state
/// updates (e.g., OG tag parse, URL auto-extract title) propagate to the UI
/// without the host screen needing controller references.
///
/// The host screen handles URL input and the submit button since their UX
/// differs (add: editable URL + OG parse; edit: URL display only).
class LinkFormFields extends ConsumerStatefulWidget {
  const LinkFormFields({required this.linkId, super.key});

  /// `null` → add mode, non-null → edit mode.
  final String? linkId;

  @override
  ConsumerState<LinkFormFields> createState() => _LinkFormFieldsState();
}

class _LinkFormFieldsState extends ConsumerState<LinkFormFields> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _memoController = TextEditingController();
  final _tagController = TextEditingController();
  bool _seeded = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _memoController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _seed(LinkFormState state) {
    if (_seeded) return;
    _titleController.text = state.title;
    _descController.text = state.description;
    _memoController.text = state.memo;
    _seeded = true;
  }

  /// Mirror an incoming field value into its controller, preserving cursor
  /// when the text is unchanged. Called from `ref.listen` on state changes.
  void _mirror(TextEditingController c, String value) {
    if (c.text == value) return;
    c.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
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
            color: AppColors.defaultTagColorHex,
          ),
        );
    _tagController.clear();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(linkFormProvider(widget.linkId), (prev, next) {
      final state = next.value;
      if (state == null) return;
      _mirror(_titleController, state.title);
      _mirror(_descController, state.description);
      _mirror(_memoController, state.memo);
    });

    final formAsync = ref.watch(linkFormProvider(widget.linkId));
    final formState = formAsync.value;
    if (formState == null) return const SizedBox.shrink();

    _seed(formState);

    final notifier = ref.read(linkFormProvider(widget.linkId).notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (formState.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Text(
              formState.errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(labelText: 'Title *'),
          onChanged: notifier.updateTitle,
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _descController,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Description'),
          onChanged: notifier.updateDescription,
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _memoController,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Notes'),
          onChanged: notifier.updateMemo,
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
                    onDeleted: () => notifier.removeTag(tag.id),
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
              value: formState.isFavorite,
              onChanged: (_) => notifier.toggleFavorite(),
            ),
          ],
        ),
      ],
    );
  }
}
