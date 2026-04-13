import 'package:hive_ce/hive_ce.dart';
import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/core/storage/i_clearable_cache.dart';
import 'package:linknote/features/notification/domain/entity/notification_entity.dart';
import 'package:linknote/shared/models/paginated_state.dart';

class NotificationLocalDataSource implements IClearableCache {
  const NotificationLocalDataSource(this._box);

  final Box<Map<dynamic, dynamic>> _box;

  static const int _maxCacheSize = 100;

  // ---------------------------------------------------------------------------
  // Read
  // ---------------------------------------------------------------------------

  Result<PaginatedState<NotificationEntity>> getCachedNotifications() {
    try {
      if (_box.isEmpty) {
        return error(
          const Failure.cache(message: 'No cached notifications'),
        );
      }

      final entities =
          _box.values.map(_mapToEntity).whereType<NotificationEntity>().toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return success(
        PaginatedState<NotificationEntity>(items: entities),
      );
    } on Exception catch (e) {
      return error(Failure.cache(message: e.toString()));
    }
  }

  // ---------------------------------------------------------------------------
  // Write
  // ---------------------------------------------------------------------------

  Future<void> cacheNotifications(
    List<NotificationEntity> notifications,
  ) async {
    try {
      final entries = <String, Map<String, dynamic>>{
        for (final n in notifications) n.id: _entityToMap(n),
      };
      await _box.putAll(entries);
      await _trimCache();
    } on Exception catch (_) {
      // Silent failure — cache write should not break the app
    }
  }

  Future<void> updateCachedReadStatus(
    String id, {
    required bool isRead,
  }) async {
    try {
      final raw = _box.get(id);
      if (raw == null) return;
      final updated = Map<String, dynamic>.from(raw);
      updated['isRead'] = isRead;
      await _box.put(id, updated);
    } on Exception catch (_) {}
  }

  Future<void> markAllCachedAsRead() async {
    try {
      for (final key in _box.keys.toList()) {
        final raw = _box.get(key);
        if (raw == null) continue;
        final updated = Map<String, dynamic>.from(raw);
        if (updated['isRead'] == true) continue;
        updated['isRead'] = true;
        await _box.put(key, updated);
      }
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

  NotificationEntity? _mapToEntity(Map<dynamic, dynamic> raw) {
    try {
      return NotificationEntity.fromJson(Map<String, dynamic>.from(raw));
    } on Exception catch (_) {
      return null;
    }
  }

  Map<String, dynamic> _entityToMap(NotificationEntity entity) {
    return entity.toJson();
  }

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
        await _box.delete(entry.key);
      }
    }

    parsed.sort((a, b) => b.value.compareTo(a.value));
    final keysToRemove = parsed.skip(_maxCacheSize).map((e) => e.key);
    await _box.deleteAll(keysToRemove);
  }
}
