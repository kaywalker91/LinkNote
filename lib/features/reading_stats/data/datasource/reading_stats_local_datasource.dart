import 'dart:async';

import 'package:hive_ce/hive_ce.dart';
import 'package:linknote/features/reading_stats/data/dto/reading_event_dto.dart';
import 'package:linknote/features/reading_stats/domain/entity/reading_event_entity.dart';
import 'package:linknote/features/reading_stats/domain/entity/reading_stats_entity.dart';

// AC-10 + AC-11: ReadingStatsLocalDatasource
// Stores events as a list inside a Hive Box<Map<dynamic,dynamic>> keyed by linkId.
// Each box entry is a Map<dynamic,dynamic> with structure:
//   { 'events': [ { 'linkId': ..., 'timestamp': ..., 'durationSeconds': ... }, ... ] }
//
// AC-11 Concurrency: a per-linkId Future write-queue serialises concurrent
// recordEvent calls for the same linkId, eliminating read-modify-write races.
// The queue is hand-rolled (no extra pubspec dependency) as a simple Future chain:
//   _writeQueue[id] = prev.then((_) => _doRecord(id, event))
// When a chain completes it removes itself via whenComplete, preventing unbounded
// growth for linkIds that are no longer being written.
class ReadingStatsLocalDatasource {
  ReadingStatsLocalDatasource(this._box);

  final Box<Map<dynamic, dynamic>> _box;

  // AC-11: per-linkId Future queue to serialise concurrent writes.
  final Map<String, Future<void>> _writeQueue = {};

  // Public entry point — enqueues the write behind any in-flight write for the
  // same linkId and returns the Future that resolves when this write is done.
  Future<void> recordEvent(String linkId, ReadingEventEntity event) {
    final prev = _writeQueue[linkId] ?? Future<void>.value();
    final next = prev.then((_) => _doRecord(linkId, event));
    // Store the whenComplete variant so subsequent enqueues chain after cleanup.
    // The whenComplete callback is intentionally a side-effect (queue eviction);
    // callers await `next` which resolves when the actual write is done.
    _writeQueue[linkId] = next.whenComplete(() {
      // Remove from queue only if no newer write has been registered since.
      if (identical(_writeQueue[linkId], next)) {
        // unawaited: Map.remove returns the removed Future<void> value;
        // we intentionally discard it — cleanup does not need to be awaited.
        unawaited(Future<void>.value(_writeQueue.remove(linkId)));
      }
    });
    return next;
  }

  // Internal write — always called serially per linkId via the queue.
  Future<void> _doRecord(String linkId, ReadingEventEntity event) async {
    final existing = _box.get(linkId);
    final List<dynamic> events;

    if (existing == null) {
      events = [];
    } else {
      // Existing entry: retrieve the stored events list.
      events = List<dynamic>.from(existing['events'] as List<dynamic>? ?? []);
    }

    final dto = ReadingEventDto(
      linkId: event.linkId,
      timestamp: event.timestamp.toUtc().toIso8601String(),
      durationSeconds: event.durationSeconds,
    );

    events.add(dto.toJson());

    await _box.put(linkId, <dynamic, dynamic>{'events': events});
  }

  // AC-10 (c) + (d): compute aggregate stats from stored events.
  // Returns ReadingStatsEntity with totalReads=0 and lastReadAt=null when
  // no events exist for the given linkId.
  Future<ReadingStatsEntity> getStats(String linkId) async {
    final stored = _box.get(linkId);

    if (stored == null) {
      return ReadingStatsEntity(linkId: linkId);
    }

    final rawEvents = stored['events'] as List<dynamic>? ?? [];

    if (rawEvents.isEmpty) {
      return ReadingStatsEntity(linkId: linkId);
    }

    DateTime? lastReadAt;
    for (final raw in rawEvents) {
      final map = raw as Map<dynamic, dynamic>;
      // Cast dynamic keys to String for DTO fromJson — exercises the real
      // dynamic/dynamic cast path mandated by AC-10.
      final stringMap = map.cast<String, dynamic>();
      final dto = ReadingEventDto.fromJson(stringMap);
      final ts = DateTime.parse(dto.timestamp).toUtc();
      if (lastReadAt == null || ts.isAfter(lastReadAt)) {
        lastReadAt = ts;
      }
    }

    return ReadingStatsEntity(
      linkId: linkId,
      totalReads: rawEvents.length,
      lastReadAt: lastReadAt,
    );
  }
}
