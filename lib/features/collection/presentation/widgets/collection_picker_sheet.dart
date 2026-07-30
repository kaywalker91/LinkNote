import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linknote/app/theme/app_spacing.dart';
import 'package:linknote/features/collection/presentation/provider/collection_list_provider.dart';

/// A collection choice made in [CollectionPickerSheet].
///
/// Wraps the id because a bare `String?` result cannot tell "picked 없음"
/// apart from "dismissed the sheet" — both would arrive as `null`.
class CollectionPick {
  const CollectionPick({required this.id});

  /// `null` means "no collection".
  final String? id;
}

/// Shows the shared collection picker as a modal bottom sheet.
///
/// Returns `null` when dismissed without picking.
Future<CollectionPick?> showCollectionPickerSheet(BuildContext context) {
  return showModalBottomSheet<CollectionPick>(
    context: context,
    builder: (_) => const CollectionPickerSheet(),
  );
}

/// Lists the user's collections plus a "없음" entry, popping a [CollectionPick].
///
/// Shared by the home card's move action and the link add/edit form.
class CollectionPickerSheet extends ConsumerWidget {
  const CollectionPickerSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(collectionListProvider);

    return SafeArea(
      child: async.when(
        // Riverpod 3.1 defaults skipLoadingOnRefresh to true. Explicitly
        // render the loading branch for invalidate/refresh as required by DoD.
        skipLoadingOnRefresh: false,
        loading: () => const SizedBox(
          height: 160,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (error, _) => Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('컬렉션을 불러오지 못했습니다'),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () =>
                    ref.read(collectionListProvider.notifier).refresh(),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
        data: (page) => ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              leading: const Icon(Icons.folder_off_outlined),
              title: const Text('없음'),
              onTap: () => Navigator.of(context).pop(
                const CollectionPick(id: null),
              ),
            ),
            const Divider(height: 1),
            if (page.items.isEmpty)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  '컬렉션이 없어요',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ...page.items.map(
              (c) => ListTile(
                leading: const Icon(Icons.folder_outlined),
                title: Text(c.name),
                onTap: () => Navigator.of(context).pop(
                  CollectionPick(id: c.id),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
