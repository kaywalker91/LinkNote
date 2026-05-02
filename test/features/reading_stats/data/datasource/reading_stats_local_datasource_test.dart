import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:linknote/features/reading_stats/data/datasource/reading_stats_local_datasource.dart';
import 'package:linknote/features/reading_stats/domain/entity/reading_event_entity.dart';

// ---------------------------------------------------------------------------
// FakeBox — in-memory Box<Map<dynamic,dynamic>> that exercises the real
// dynamic/dynamic key/value types so that Map<dynamic,dynamic> -> DTO casts
// are actually exercised (AC-10 mock fidelity requirement).
// Hive Box is NOT mocked so that cast paths remain uncheated.
// ---------------------------------------------------------------------------
class FakeBox extends Fake implements Box<Map<dynamic, dynamic>> {
  final Map<dynamic, Map<dynamic, dynamic>> _store = {};

  @override
  Map<dynamic, dynamic>? get(dynamic key, {Map<dynamic, dynamic>? defaultValue}) {
    return _store[key] ?? defaultValue;
  }

  @override
  Future<void> put(dynamic key, Map<dynamic, dynamic> value) async {
    _store[key] = value;
  }

  @override
  Map<dynamic, Map<dynamic, dynamic>> toMap() => Map.unmodifiable(_store);

  @override
  Iterable<Map<dynamic, dynamic>> get values => _store.values;

  @override
  bool get isEmpty => _store.isEmpty;

  @override
  bool get isNotEmpty => _store.isNotEmpty;

  @override
  int get length => _store.length;
}

void main() {
  late ReadingStatsLocalDatasource sut;
  late FakeBox fakeBox;

  setUp(() {
    fakeBox = FakeBox();
    sut = ReadingStatsLocalDatasource(fakeBox);
  });

  final tTimestamp1 = DateTime(2026, 1, 10, 9).toUtc();
  final tTimestamp2 = DateTime(2026, 1, 10, 11).toUtc();
  final tTimestamp3 = DateTime(2026, 1, 10, 8).toUtc();

  final tEvent1 = ReadingEventEntity(
    linkId: 'link-1',
    timestamp: tTimestamp1,
    durationSeconds: 60,
  );
  final tEvent2 = ReadingEventEntity(
    linkId: 'link-1',
    timestamp: tTimestamp2,
    durationSeconds: 90,
  );

  // ---------------------------------------------------------------------------
  // AC-10 (a): recordEvent on empty box creates entry with one event
  // ---------------------------------------------------------------------------
  group('recordEvent — AC-10 (a) empty box creates entry', () {
    test('should create a new entry with one event for unknown linkId',
        () async {
      // Act
      await sut.recordEvent('link-1', tEvent1);

      // Assert
      final stored = fakeBox.get('link-1');
      expect(stored, isNotNull);
      final events = stored!['events'] as List<dynamic>;
      expect(events, hasLength(1));
    });
  });

  // ---------------------------------------------------------------------------
  // AC-10 (b): recordEvent on existing entry appends event
  // ---------------------------------------------------------------------------
  group('recordEvent — AC-10 (b) appends to existing entry', () {
    test('should append a second event to an existing entry', () async {
      // Arrange — pre-populate
      await sut.recordEvent('link-1', tEvent1);

      // Act
      await sut.recordEvent('link-1', tEvent2);

      // Assert
      final stored = fakeBox.get('link-1');
      expect(stored, isNotNull);
      final events = stored!['events'] as List<dynamic>;
      expect(events, hasLength(2));
    });
  });

  // ---------------------------------------------------------------------------
  // AC-10 (c): getStats returns totalReads=count and lastReadAt=max(timestamps)
  // ---------------------------------------------------------------------------
  group('getStats — AC-10 (c) aggregate', () {
    test('should return totalReads == 2 and lastReadAt == max timestamp',
        () async {
      // Arrange
      await sut.recordEvent('link-1', tEvent1); // 09:00
      await sut.recordEvent('link-1', tEvent2); // 11:00

      // Act
      final stats = await sut.getStats('link-1');

      // Assert
      expect(stats.totalReads, 2);
      expect(stats.lastReadAt, tTimestamp2); // max is 11:00
    });

    test('should pick the maximum timestamp regardless of insertion order',
        () async {
      // Arrange — three events with out-of-order timestamps
      final eventA = ReadingEventEntity(
        linkId: 'link-2',
        timestamp: tTimestamp2, // 11:00
      );
      final eventB = ReadingEventEntity(
        linkId: 'link-2',
        timestamp: tTimestamp3, // 08:00
      );
      final eventC = ReadingEventEntity(
        linkId: 'link-2',
        timestamp: tTimestamp1, // 09:00
      );
      await sut.recordEvent('link-2', eventA);
      await sut.recordEvent('link-2', eventB);
      await sut.recordEvent('link-2', eventC);

      // Act
      final stats = await sut.getStats('link-2');

      // Assert
      expect(stats.totalReads, 3);
      expect(stats.lastReadAt, tTimestamp2);
    });
  });

  // ---------------------------------------------------------------------------
  // AC-10 (d): getStats for unknown linkId returns totalReads=0, lastReadAt=null
  // ---------------------------------------------------------------------------
  group('getStats — AC-10 (d) unknown linkId', () {
    test('should return totalReads=0 and lastReadAt=null for unknown linkId',
        () async {
      // Act
      final stats = await sut.getStats('unknown-link');

      // Assert
      expect(stats.totalReads, 0);
      expect(stats.lastReadAt, isNull);
      expect(stats.linkId, 'unknown-link');
    });
  });

  // ---------------------------------------------------------------------------
  // AC-11: concurrent recordEvent x10 for same linkId — final count == 10
  // ---------------------------------------------------------------------------
  group('recordEvent — AC-11 concurrency', () {
    test(
      'should store exactly 10 events when recordEvent is called 10 times in '
      'parallel for the same linkId',
      () async {
        // Arrange — 10 events with distinct timestamps
        final events = List.generate(
          10,
          (i) => ReadingEventEntity(
            linkId: 'link-concurrent',
            timestamp: DateTime(2026, 1, 1, i).toUtc(),
            durationSeconds: i * 10,
          ),
        );

        // Act — fire all 10 concurrently (this is the real race condition test)
        await Future.wait(
          events.map((e) => sut.recordEvent('link-concurrent', e)),
        );

        // Assert — all 10 timestamps preserved, no lost writes
        final stats = await sut.getStats('link-concurrent');
        expect(stats.totalReads, 10);

        // Verify all distinct timestamps are present
        final stored = fakeBox.get('link-concurrent');
        expect(stored, isNotNull);
        final storedEvents = stored!['events'] as List<dynamic>;
        expect(storedEvents, hasLength(10));

        final storedTimestamps = storedEvents
            .map((e) => (e as Map<dynamic, dynamic>)['timestamp'] as String)
            .toSet();
        // All 10 timestamps must be unique and preserved
        expect(storedTimestamps, hasLength(10));
      },
    );
  });

  // ---------------------------------------------------------------------------
  // AC-12: getStats returns correct entity for linkId with durationSeconds=null
  // ---------------------------------------------------------------------------
  group('recordEvent — null durationSeconds', () {
    test('should persist event without durationSeconds field', () async {
      // Arrange
      final eventNoDuration = ReadingEventEntity(
        linkId: 'link-nodur',
        timestamp: tTimestamp1,
      );

      // Act
      await sut.recordEvent('link-nodur', eventNoDuration);
      final stats = await sut.getStats('link-nodur');

      // Assert
      expect(stats.totalReads, 1);
      expect(stats.lastReadAt, tTimestamp1);
    });
  });
}
