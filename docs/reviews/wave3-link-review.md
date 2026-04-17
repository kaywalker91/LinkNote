# Wave 3 Code Review — Link Feature

**Reviewer**: Claude Code  
**Date**: 2026-04-13  
**Baseline**: main `42eed5e` (352 tests GREEN, analyze 0, CI 4/4 pass)  
**Scope**: `lib/features/link/` (23 files, ~1,972 lines) + cross-feature integration

---

## Summary

| Severity | Count | Status |
|----------|-------|--------|
| P0 (Critical) | 0 | - |
| P1 (High) | 4 | Session 27 fix |
| P2 (Medium) | 8 | Session 28 fix (4 backlog + 4 new) |
| P3 (Nit) | 4 | Session 29 optional |

---

## P1 Findings (High)

### P1-A: `_syncTags` non-transactional — mid-failure loses all tags

**File**: `link_remote_datasource.dart:162-191`

`_syncTags()` performs 3 sequential operations: delete all `link_tags`, upsert each tag (N+1 calls), insert `link_tags`. If the method fails mid-way (e.g., network drop after deleting old `link_tags` but before inserting new ones), the link loses all its tags permanently.

**Fix**: Batch tag upserts into a single request. Wrap in try/catch that re-throws so callers (`createLink`/`updateLink`) surface the failure.

### P1-B: `collectionId` filter never passed from presentation to list provider

**Files**: `link_filter_provider.dart`, `link_list_provider.dart:15`

`LinkFilter` only has `favoritesOnly`. The repository and `FetchLinksUsecase` accept `collectionId`, but `LinkListProvider._fetch()` never passes it. Collection-filtered link views are broken or require a separate code path.

**Fix**: Add `String? collectionId` to `LinkFilter`. Forward in `_fetch()`.

### P1-C: Edit mode overwrites `createdAt` with `DateTime.now()`

**File**: `link_form_provider.dart:140-152`

When editing (linkId != null), `submit()` constructs `LinkEntity(createdAt: now)`. While `LinkMapper.toUpdateJson` excludes `created_at`, the re-fetch may fail, leaving the cache with a fabricated `createdAt`.

**Fix**: Preserve original entity's `createdAt` in edit mode.

### P1-D: No `updateCollectionId()` — link-to-collection assignment impossible from UI

**File**: `link_form_provider.dart`

`LinkFormState` has a `collectionId` field, and it's preserved during edit-mode initialization (line 42), but no `updateCollectionId()` method exists. Neither add nor edit screens have collection selection UI.

**Fix**: Add `updateCollectionId()` method. Collection picker UI deferred to separate task.

---

## P2 Findings (Medium)

### P2-E: No cancellation on OG tag parsing — duplicate HTTP requests

**File**: `link_form_provider.dart:49`

`parseOgTags` has no mechanism to cancel in-flight requests when triggered again.

**Fix**: Use `CancelableOperation` for cancellation.

### P2-F: Tag ID uses `millisecondsSinceEpoch` — collision risk

**File**: `link_add_screen.dart:108`

`TagEntity(id: 'tag_${DateTime.now().millisecondsSinceEpoch}', ...)` — rapid double-tap produces duplicate IDs.

**Fix**: Use `uuid` package or counter suffix.

### P2-G: `UrlSanitizer.extract('hello')` returns `https://hello` (backlog P2-B)

**File**: `url_sanitizer.dart`

Scheme-less fallback prepends `https://` to any non-whitespace string. Single words pass validation.

**Fix**: Require host to contain at least one `.` (or be `localhost`).

### P2-H: `isValidUrl` extension unused + logic error (backlog P2-C)

**File**: `string_extensions.dart`

`hasAbsolutePath` check rejects valid URLs like `https://example.com`.

**Fix**: Remove or replace with `hasScheme && host.isNotEmpty`.

### P2-I: Repository `getLinks` dead branch (backlog P3-A, upgraded)

**File**: `link_repository_impl.dart:33-40`

if/else branches perform identical `cacheLinks` operations.

**Fix**: Remove conditional, call `cacheLinks` unconditionally.

### P2-J: `timeAgo()` negative for future dates (backlog P3-B, upgraded)

**File**: `date_time_extensions.dart`

Clock skew from server produces negative durations.

**Fix**: Guard with `if (diff.isNegative) return 'just now'`.

### P2-K: Cache trim by `createdAt` evicts recently-viewed items (backlog P2-D)

**File**: `link_local_datasource.dart:145-163`

LRU trim sorts by entity `createdAt`, not cache-write time. Deep-scrolled old links get evicted even though user just viewed them.

**Fix**: Add `_cachedAt` timestamp, sort by it.

### P2-L: `OgTagService._cache` unbounded growth

**File**: `og_tag_service.dart`

In-memory cache map never evicts entries except by TTL on read. Long sessions leak memory.

**Fix**: Add max-size LRU eviction.

---

## P3 Findings (Nit)

### P3-C: ~150 lines duplicated between add/edit screens

**Files**: `link_add_screen.dart` (261 lines), `link_edit_screen.dart` (222 lines)

Nearly identical form layout code.

**Fix**: Extract `LinkFormWidget` with configuration.

### P3-D: Hardcoded tag color `'#6750A4'`

**Files**: `link_add_screen.dart`, `link_edit_screen.dart`

All new tags get fixed purple color despite `TagEntity.color` field existing.

### P3-E: Mixed Korean/English strings in screens

Inconsistent i18n: Korean snackbar messages, English empty states.

### P3-F: Detail screen favorite toggle doesn't update detail UI

**File**: `link_detail_screen.dart:38-39`

Calls `linkListProvider.notifier.toggleFavorite()` which only updates list state, not `linkDetailProvider`.

---

## Test Coverage Gaps

| Layer | Coverage | Needed |
|-------|----------|--------|
| Provider unit tests | 0% | LinkListProvider, LinkFormProvider, LinkDetailProvider |
| RemoteDataSource | ~10% (1 test) | CRUD + `_syncTags` failure paths |
| Repository | ~70% | `updateLink` test missing |

---

## Backlog Mapping

| Wave 2 ID | Wave 3 ID | Status |
|-----------|-----------|--------|
| P2-B | P2-G | Confirmed |
| P2-C | P2-H | Confirmed |
| P2-D | P2-K | Confirmed |
| P3-A | P2-I | Upgraded to P2 |
| P3-B | P2-J | Upgraded to P2 |
| P2-G (PaginatedListView) | - | Carry forward |
