import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linknote/app/theme/app_spacing.dart';
import 'package:linknote/features/collection/presentation/provider/collection_detail_provider.dart';
import 'package:linknote/features/collection/presentation/provider/collection_list_provider.dart';
import 'package:linknote/shared/widgets/primary_button_widget.dart';

class CollectionFormScreen extends ConsumerStatefulWidget {
  const CollectionFormScreen({super.key, this.collectionId});

  /// null = create mode, non-null = edit mode.
  final String? collectionId;

  @override
  ConsumerState<CollectionFormScreen> createState() =>
      _CollectionFormScreenState();
}

class _CollectionFormScreenState extends ConsumerState<CollectionFormScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  bool _initialized = false;
  bool _isSubmitting = false;

  bool get _isEditMode => widget.collectionId != null;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _syncControllers(String name, String? description) {
    if (_initialized) return;
    _nameController.text = name;
    _descController.text = description ?? '';
    _initialized = true;
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isSubmitting = true);

    if (_isEditMode) {
      await ref
          .read(collectionListProvider.notifier)
          .updateCollection(
            id: widget.collectionId!,
            name: name,
            description: _descController.text.trim().isEmpty
                ? null
                : _descController.text.trim(),
          );
    } else {
      await ref
          .read(collectionListProvider.notifier)
          .createCollection(
            name: name,
            description: _descController.text.trim().isEmpty
                ? null
                : _descController.text.trim(),
          );
    }

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_isEditMode) {
      ref
          .watch(collectionDetailProvider(widget.collectionId!))
          .whenData(
            (c) => _syncControllers(c.name, c.description),
          );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Collection' : 'New Collection'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name *',
                hintText: 'e.g. Dev Resources',
              ),
              autofocus: !_isEditMode,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'What is this collection about?',
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: AppSpacing.xxl),
            PrimaryButtonWidget(
              label: _isEditMode ? 'Save Changes' : 'Create Collection',
              isLoading: _isSubmitting,
              onPressed: _isSubmitting ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
