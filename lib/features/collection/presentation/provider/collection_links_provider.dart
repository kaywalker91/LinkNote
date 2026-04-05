import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';

// TODO(linknote): Replace with CollectionLinksUsecase when data layer is ready.
/// Mock provider for links belonging to a collection.
// ignore: specify_nonobvious_property_types, type is clear from initializer.
final collectionLinksProvider = FutureProvider.autoDispose
    .family<List<LinkEntity>, String>(
      (ref, collectionId) async {
        await Future<void>.delayed(const Duration(milliseconds: 300));
        return List.generate(
          5,
          (i) => LinkEntity(
            id: '${collectionId}_link_$i',
            url: 'https://example.com/$collectionId/article-$i',
            title: 'Collection Article $i',
            description: 'A link in this collection',
            isFavorite: i.isEven,
            createdAt: DateTime.now().subtract(Duration(hours: i * 3)),
            updatedAt: DateTime.now().subtract(Duration(hours: i)),
          ),
        );
      },
    );
