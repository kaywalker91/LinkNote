# ADR-002: Hive CE over sqflite for Local Cache

**Status:** Accepted
**Date:** 2026-02-20

## Context

LinkNote follows a remote-first, local-fallback caching strategy. When the network is unavailable, the app should display the last-known data from a local cache. The cache layer needs to:

- Store serialized domain entities (JSON maps)
- Support key-value lookups by entity ID
- Require zero schema migrations for evolving entity shapes
- Be lightweight — this is a cache, not a source of truth

## Options Considered

| Criteria | Hive CE | sqflite | Isar | drift |
|----------|---------|---------|------|-------|
| Schema | Schema-less (key-value) | SQL tables | Schema-based | SQL + code gen |
| Migrations | Not needed | Manual SQL | Auto | Code gen |
| Setup complexity | Low | Medium | Medium | High |
| Query power | Basic (key lookup) | Full SQL | Indexed queries | Full SQL |
| Performance | Fast (binary) | Good | Fast | Good |
| Package size | Small | Medium | Large (native) | Medium |

## Decision

**Hive CE** (Community Edition) as a lightweight key-value cache.

### Reasons

1. **Cache, not database**: LinkNote's local storage is a read cache, not a relational database. We only need `put(id, json)` and `get(id)` — no joins, no complex queries. sqflite's relational power would be unused overhead.

2. **Zero migrations**: Entity shapes evolve during development. With Hive, adding a field to `LinkEntity` requires no migration — old cached entries simply have `null` for the new field, and `fromJson` handles it gracefully. sqflite would require `ALTER TABLE` migrations.

3. **Dart-native setup**: Hive CE requires no native platform configuration. `await Hive.initFlutter()` + `Hive.openBox()` — two lines. sqflite requires platform-specific SQLite binaries.

4. **LRU trim strategy**: Each box has a 100-entry max. A simple `_trimCache()` method sorts by `createdAt` and deletes the oldest entries. This is natural with key-value stores but awkward with SQL tables.

## Consequences

- **Positive**: Minimal boilerplate — `CollectionLocalDataSource` and `LinkLocalDataSource` are ~120 lines each.
- **Positive**: No migration files to maintain as entities evolve.
- **Negative**: No relational queries — cannot query "all links in collection X" from cache alone. The app falls back to the full cached list and filters in Dart.
- **Negative**: `Box<Map<dynamic, dynamic>>` type required (Hive CE does not support `Box<Map<String, dynamic>>`). Requires explicit `Map<String, dynamic>.from(raw)` cast when reading.

## Lessons Learned

During development, using `Box<Map<String, dynamic>>` caused a runtime crash (`typedMapOrIterableCheck` error in Hive CE). The fix was changing to `Box<Map<dynamic, dynamic>>` across storage initialization, datasource classes, and DI providers. This is a known Hive CE limitation that should be documented for future contributors.

## References

- [Hive CE on pub.dev](https://pub.dev/packages/hive_ce)
- [sqflite on pub.dev](https://pub.dev/packages/sqflite)
