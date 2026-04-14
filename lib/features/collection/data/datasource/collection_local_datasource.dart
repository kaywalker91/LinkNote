import 'package:hive_ce/hive_ce.dart';
import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/core/storage/i_clearable_cache.dart';
import 'package:linknote/features/collection/domain/entity/collection_entity.dart';
import 'package:linknote/shared/models/paginated_state.dart';

class CollectionLocalDataSource implements IClearableCache {
  const CollectionLocalDataSource(this._box);

  final Box<Map<dynamic, dynamic>> _box;

  static const int _maxCacheSize = 100;

  // ---------------------------------------------------------------------------
  // Read
  // ---------------------------------------------------------------------------

  Result<PaginatedState<CollectionEntity>> getCachedCollections() {
    try {
      if (_box.isEmpty) {
        return error(const Failure.cache(message: 'No cached collections'));
      }
      final entities =
          _box.values.map(_mapToEntity).whereType<CollectionEntity>().toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return success(PaginatedState<CollectionEntity>(items: entities));
    } on Exception catch (e) {
      return error(Failure.cache(message: e.toString()));
    }
  }

  Result<CollectionEntity> getCachedCollectionById(String id) {
    try {
      final raw = _box.get(id);
      if (raw == null) {
        return error(
          const Failure.cache(message: 'Collection not found in cache'),
        );
      }
      final entity = _mapToEntity(raw);
      if (entity == null) {
        return error(
          const Failure.cache(message: 'Failed to parse cached collection'),
        );
      }
      return success(entity);
    } on Exception catch (e) {
      return error(Failure.cache(message: e.toString()));
    }
  }

  // ---------------------------------------------------------------------------
  // Write
  // ---------------------------------------------------------------------------

  Future<void> cacheCollections(
    List<CollectionEntity> collections,
  ) async {
    try {
      final entries = <String, Map<String, dynamic>>{
        for (final c in collections) c.id: _entityToMap(c),
      };
      await _box.putAll(entries);
      await _trimCache();
    } on Exception catch (_) {
      // Silent failure — cache write should not break the app
    }
  }

  Future<void> cacheSingleCollection(CollectionEntity collection) async {
    try {
      await _box.put(collection.id, _entityToMap(collection));
      await _trimCache();
    } on Exception catch (_) {}
  }

  Future<void> removeCachedCollection(String id) async {
    try {
      await _box.delete(id);
    } on Exception catch (_) {}
  }

  @override
  Future<void> clearAll() async {
    try {
      await _box.clear();
    } on Exception catch (_) {}
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  CollectionEntity? _mapToEntity(Map<dynamic, dynamic> raw) {
    try {
      return CollectionEntity.fromJson(Map<String, dynamic>.from(raw));
    } on Object {
      return null;
    }
  }

  Map<String, dynamic> _entityToMap(CollectionEntity entity) {
    return entity.toJson();
  }

  Future<void> _trimCache() async {
    if (_box.length <= _maxCacheSize) return;
    final entries = _box.toMap().entries.toList();
    final parsed = <MapEntry<String, DateTime>>[];
    for (final entry in entries) {
      if (entry.key is! String) {
        await _box.delete(entry.key);
        continue;
      }
      try {
        final json = Map<String, dynamic>.from(entry.value);
        final createdAt = DateTime.parse(json['createdAt'] as String);
        parsed.add(MapEntry(entry.key as String, createdAt));
      } on Exception catch (_) {
        await _box.delete(entry.key);
      }
    }
    parsed.sort((a, b) => b.value.compareTo(a.value));
    final keysToRemove = parsed.skip(_maxCacheSize).map((e) => e.key);
    await _box.deleteAll(keysToRemove);
  }
}
