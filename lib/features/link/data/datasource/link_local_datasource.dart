import 'package:hive_ce/hive_ce.dart';
import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/core/storage/i_clearable_cache.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/shared/models/paginated_state.dart';
import 'package:linknote/shared/utils/url_sanitizer.dart';

class LinkLocalDataSource implements IClearableCache {
  const LinkLocalDataSource(this._box);

  final Box<Map<dynamic, dynamic>> _box;

  static const int _maxCacheSize = 100;

  // ---------------------------------------------------------------------------
  // Read
  // ---------------------------------------------------------------------------

  Result<PaginatedState<LinkEntity>> getCachedLinks({
    bool favoritesOnly = false,
    String? collectionId,
  }) {
    try {
      if (_box.isEmpty) {
        return error(const Failure.cache(message: 'No cached links'));
      }

      var entities =
          _box.values.map(_mapToEntity).whereType<LinkEntity>().toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (favoritesOnly) {
        entities = entities.where((e) => e.isFavorite).toList();
      }
      if (collectionId != null) {
        entities = entities
            .where((e) => e.collectionId == collectionId)
            .toList();
      }

      return success(
        PaginatedState<LinkEntity>(items: entities),
      );
    } on Exception catch (e) {
      return error(Failure.cache(message: e.toString()));
    }
  }

  Result<LinkEntity> getCachedLinkById(String id) {
    try {
      final raw = _box.get(id);
      if (raw == null) {
        return error(const Failure.cache(message: 'Link not found in cache'));
      }
      final entity = _mapToEntity(raw);
      if (entity == null) {
        return error(
          const Failure.cache(message: 'Failed to parse cached link'),
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

  Future<void> cacheLinks(List<LinkEntity> links) async {
    try {
      final entries = <String, Map<String, dynamic>>{
        for (final link in links) link.id: _entityToMap(link),
      };
      await _box.putAll(entries);
      await _trimCache();
    } on Exception catch (_) {
      // Silent failure — cache write should not break the app
    }
  }

  Future<void> cacheSingleLink(LinkEntity link) async {
    try {
      await _box.put(link.id, _entityToMap(link));
      await _trimCache();
    } on Exception catch (_) {}
  }

  Future<void> removeCachedLink(String id) async {
    try {
      await _box.delete(id);
    } on Exception catch (_) {}
  }

  Future<void> updateCachedFavorite(
    String id, {
    required bool isFavorite,
  }) async {
    try {
      final raw = _box.get(id);
      if (raw == null) return;
      final updated = Map<String, dynamic>.from(raw);
      updated['isFavorite'] = isFavorite;
      await _box.put(id, updated);
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

  LinkEntity? _mapToEntity(Map<dynamic, dynamic> raw) {
    try {
      final json = Map<String, dynamic>.from(raw);
      // Defensive sanitize at the local-cache boundary: legacy records that
      // were saved with "title - URL" pastes or hidden chars are transparently
      // repaired on read. Mirrors LinkMapper.toEntity. See Session 19 RCA.
      final rawUrl = json['url'];
      if (rawUrl is String) {
        final cleaned = UrlSanitizer.extract(rawUrl);
        if (cleaned != null && cleaned != rawUrl) {
          json['url'] = cleaned;
        }
      }
      return LinkEntity.fromJson(json);
    } on Object {
      return null;
    }
  }

  Map<String, dynamic> _entityToMap(LinkEntity entity) {
    return entity.toJson();
  }

  /// Keeps only the most recent [_maxCacheSize] links by removing the oldest.
  Future<void> _trimCache() async {
    if (_box.length <= _maxCacheSize) return;

    final entries = _box.toMap().entries.toList();
    final parsed = <MapEntry<String, DateTime>>[];
    for (final entry in entries) {
      try {
        final json = Map<String, dynamic>.from(entry.value);
        final createdAt = DateTime.parse(json['createdAt'] as String);
        parsed.add(MapEntry(entry.key as String, createdAt));
      } on Exception catch (_) {
        // Remove unparseable entries
        await _box.delete(entry.key);
      }
    }

    parsed.sort((a, b) => b.value.compareTo(a.value));
    final keysToRemove = parsed.skip(_maxCacheSize).map((e) => e.key);
    await _box.deleteAll(keysToRemove);
  }
}
