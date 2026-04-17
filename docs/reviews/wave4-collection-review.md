# Wave 4 Code Review — Collection Feature

**Reviewer**: Claude Code
**Date**: 2026-04-15
**Baseline**: main `ab9803b` (PR#9 Wave 3 P2 머지 후, 379 tests GREEN, `flutter analyze --fatal-warnings` 0)
**Scope**: `lib/features/collection/` (14 프로덕션 파일, ~940 lines) + `test/features/collection/` (11 테스트 파일)

---

## Summary

| Severity | Count | 대상 세션 |
|----------|-------|-----------|
| P0 (Critical) | 1 | Session 30 |
| P1 (High) | 3 | Session 30 |
| P2 (Medium) | 4 | Session 30 또는 31 |
| P3 (Nit) | 2 | Session 31 optional |

---

## 파일 트리

```
lib/features/collection/
├── data/
│   ├── datasource/
│   │   ├── collection_local_datasource.dart    (125 lines)
│   │   └── collection_remote_datasource.dart   (127 lines)
│   ├── dto/collection_dto.dart                 (33 lines)
│   ├── mapper/collection_mapper.dart           (41 lines)
│   └── repository/collection_repository_impl.dart (75 lines)
├── domain/
│   ├── entity/collection_entity.dart           (21 lines)
│   ├── repository/i_collection_repository.dart (19 lines)
│   └── usecase/ (create/delete/get_detail/get_list/update  5종)
└── presentation/
    ├── provider/
    │   ├── collection_di_providers.dart        (68 lines)
    │   ├── collection_detail_provider.dart     (26 lines)
    │   ├── collection_links_provider.dart      (16 lines)
    │   └── collection_list_provider.dart       (122 lines)
    └── screens/
        ├── collection_detail_screen.dart       (185 lines)
        ├── collection_form_screen.dart         (129 lines)
        └── collection_list_screen.dart         (121 lines)
```

---

## P0 Findings (Critical)

### P0-A: `collectionLinksProvider` — Failure 침묵으로 데이터 유실 오인

**File**: `lib/features/collection/presentation/provider/collection_links_provider.dart:14`

```dart
final result = await usecase(collectionId: collectionId);
return result.data?.items ?? [];
```

`FetchLinksUsecase`가 `Failure`를 리턴하면 provider는 빈 리스트를 그대로 반환. UI는 "컬렉션에 링크 없음"으로 표시되어 네트워크 실패와 실제 빈 상태를 구별할 수 없고, 재시도 경로도 없음. 장기 저장된 링크가 "사라진 것처럼 보이는" UX 데이터 유실 오인.

**Fix**: 실패를 throw 해 `AsyncError`로 전파 (다른 provider들과 일관).
```dart
final result = await usecase(collectionId: collectionId);
if (result.isFailure) {
  Error.throwWithStackTrace(result.failure!, StackTrace.current);
}
return result.data!.items;
```

---

## P1 Findings (High)

### P1-A: Remote DataSource update/delete — `user_id` 명시 필터 부재

**File**: `lib/features/collection/data/datasource/collection_remote_datasource.dart:94-118` (update), `116-125` (delete), `54-70` (getById)

```dart
await _client.from('collections').update(json).eq('id', collection.id).select(...);
await _client.from('collections').delete().eq('id', id);
```

`collections` 테이블 RLS 정책이 `user_id = auth.uid()`를 강제한다는 **암묵적 서버 보안**에 의존. 리포지토리 레이어는 `userId`를 주입 받고 있음(`collection_repository_impl.dart:17`)에도 불구하고 업데이트/삭제 쿼리에 `user_id` 필터를 추가하지 않음. RLS 정책이 누락/느슨해지면 임의 ID로 타인의 컬렉션을 수정·삭제 가능.

**Fix**: (1) Supabase 대시보드에서 `collections` RLS UPDATE/DELETE 정책을 확인해 문서화 `docs/security/rls_policies.md` 신설, (2) 2중 방어 차원에서 쿼리에 `.eq('user_id', userId)` 추가.

```dart
await _client
    .from('collections')
    .update(json)
    .eq('id', collection.id)
    .eq('user_id', userId)  // explicit ownership
    .select(_selectQuery)
    .single();
```

### P1-B: `CollectionLocalDataSource._trimCache()` — Hive key unsafe cast

**File**: `lib/features/collection/data/datasource/collection_local_datasource.dart:111-122`

```dart
for (final entry in entries) {
  try {
    final json = Map<String, dynamic>.from(entry.value);
    final createdAt = DateTime.parse(json['createdAt'] as String);
    parsed.add(MapEntry(entry.key as String, createdAt));  // unsafe
  } on Exception catch (_) {
    await _box.delete(entry.key);
  }
}
```

`entry.key as String`이 `CastError`를 던지면 (Hive CE는 dynamic key 허용) `on Exception` catch에서 잡히지 않아 `_trimCache()` 전체가 터짐. 단일 오염 엔트리로 trim 중단 → 캐시 용량 제한 붕괴.

**Fix**: 타입 가드 선행.
```dart
if (entry.key is! String) {
  await _box.delete(entry.key);
  continue;
}
final key = entry.key as String;
```

### P1-C: `CollectionListProvider.create/update` 실패가 UI로 전파되지 않음

**File**: `lib/features/collection/presentation/provider/collection_list_provider.dart:50-102`

```dart
final result = await ref.read(createCollectionUsecaseProvider).call(entity);
if (result.isSuccess) { ... }
// ← 실패 분기 없음
```

Form 화면(`collection_form_screen.dart:70-76`)은 provider 호출 직후 무조건 success snackbar("컬렉션이 생성되었습니다")를 띄우고 `pop()`. 실제로 create가 실패해도 성공 메시지가 나가고 리스트엔 아무 변화 없음 — 동일한 P3-B의 근본 원인.

**Fix**: provider에서 Failure를 throw, form 화면은 try/catch로 error snackbar 표시.
```dart
if (result.isFailure) {
  Error.throwWithStackTrace(result.failure!, StackTrace.current);
}
```

---

## P2 Findings (Medium)

### P2-A: `CollectionMapper.toEntity()` — linkCount single-aggregate 가정

**File**: `lib/features/collection/data/mapper/collection_mapper.dart:8`

```dart
final linkCount = dto.links.isNotEmpty ? dto.links.first.count : 0;
```

Supabase select `*, links(count)`가 현재는 단일 aggregate를 리턴하지만, 이 불변을 enforcement 하는 곳이 없음. 스키마 변경(예: 상태별 aggregate)에서 `.first` 만 취해 조용히 손실 → 테스트가 잡아내기 어려움.

**Fix**: fold 누산 + 길이 assertion 로그.
```dart
final linkCount = dto.links.fold<int>(0, (sum, e) => sum + e.count);
```

### P2-B: `getCollectionById` — 로컬 캐시 폴백 없음

**File**: `lib/features/collection/data/repository/collection_repository_impl.dart:40-42`

```dart
Future<Result<CollectionEntity>> getCollectionById(String id) =>
    _remote.getCollectionById(id);
```

`getCollections()`는 cursor null 시 로컬 폴백을 수행(29-36) 하지만 detail 조회는 리모트 직통. 리스트에서 방금 본 컬렉션을 탭해서 상세로 진입할 때 네트워크 실패 시 즉시 에러. 게다가 `CollectionLocalDataSource.getCachedCollectionById`는 이미 구현되어 있어 사용만 하면 됨.

**Fix**:
```dart
Future<Result<CollectionEntity>> getCollectionById(String id) async {
  final remote = await _remote.getCollectionById(id);
  if (remote.isSuccess) {
    await _local.cacheSingleCollection(remote.data!);
    return remote;
  }
  return _local.getCachedCollectionById(id);
}
```

### P2-C: `deleteCollection` 낙관적 롤백 — 사용자에게 실패 무통지

**File**: `lib/features/collection/presentation/provider/collection_list_provider.dart:104-120`

```dart
state = AsyncData(current.copyWith(items: ...));  // 낙관적 제거
final result = await ref.read(deleteCollectionUsecaseProvider).call(id);
if (result.isFailure) {
  state = AsyncData(previous);  // 롤백만
}
```

삭제 실패 시 리스트에 컬렉션이 갑자기 "돌아오는" 사이드이펙트만 발생, 사용자는 이유를 모름. 리스트 P2-C는 P1-C와 같은 계열 — 제공자 레벨 에러 채널 통일 필요.

**Fix**: `PaginatedState`에 transient error 필드 추가 or `AsyncError`로 throw 후 screen SnackBar.

### P2-D: `createCollection` 후 `collectionDetailProvider` invalidate 누락

**File**: `lib/features/collection/presentation/provider/collection_list_provider.dart:63-72`

create/update 시 `collectionListProvider.state` 만 갱신. `collectionDetailProvider(id)` 캐시는 그대로 남음. 사용자가 동일 id에 빠르게 재진입하면 `linkCount` 등 stale data 노출 가능.

**Fix**: `ref.invalidate(collectionDetailProvider(result.data!.id))` 추가 (update 경로 필수, create 경로는 신규 id라 사실상 무해 — 업데이트에만 적용해도 무방).

---

## P3 Findings (Nit)

### P3-A: `collection_form_screen._submit()` — 실패 시에도 success snackbar

**File**: `lib/features/collection/presentation/screens/collection_form_screen.dart:70-76`

```dart
if (mounted) {
  context
    ..showSuccessSnackBar(_isEditMode ? '컬렉션이 수정되었습니다' : '컬렉션이 생성되었습니다')
    ..pop();
}
```

P1-C가 선행 수정되면 이 블록은 try/catch로 감싸서 실패 메시지 분기 필요. 현재는 provider가 조용히 실패하므로 항상 success.

**Fix**: P1-C와 묶어서 처리.

### P3-B: `CollectionListProvider.updateCollection` — `firstWhere` throws on missing id

**File**: `lib/features/collection/presentation/provider/collection_list_provider.dart:82`

```dart
final existing = current.items.firstWhere((c) => c.id == id);
```

리스트에 없는 id가 들어오면 `StateError`를 던짐. 현재는 form이 목록에서 진입하므로 실무상 불가능하지만, 외부(딥링크·알림)에서 호출되면 터짐. `orElse`로 graceful fail.

**Fix**:
```dart
final existing = current.items.firstWhereOrNull((c) => c.id == id);
if (existing == null) return;  // or fetch fresh
```

---

## Test Coverage 분석

### 커버된 영역 ✅
- **Repository**: `collection_repository_impl_test.dart` — cache fallback, CRUD 성공/실패 분기, no-cache on paginated cursor (강건)
- **UseCase 5종**: 전부 커버됨 (`create/delete/get_list/get_detail/update`)
- **Local DataSource**: `collection_local_datasource_test.dart` 존재 (cache read/write/trim)
- **Mapper**: `collection_mapper_test.dart` 존재 (DateTime 파싱, linkCount 추출)
- **Screens 3종**: `collection_list_screen_test.dart`, `collection_form_screen_test.dart`, `collection_detail_screen_test.dart` 모두 존재

### 갭 ❌
- **`collection_remote_datasource_test.dart` 부재** — Supabase 에러 경로(PostgrestException, Exception)와 `_selectQuery` 파싱 로직 검증 없음. Wave 3 Session 28에서 link 쪽엔 신규로 추가됨 — 동일 패턴 적용 필요.
- **Provider 단위 테스트 부재** — `collection_list_provider_test.dart`, `collection_detail_provider_test.dart`, `collection_links_provider_test.dart` 모두 없음. Wave 3 Session 28에서 link 3개 provider test 추가한 것과 대조. 낙관적 업데이트 롤백, P0-A failure propagation, createCollection 에러 경로 등 중요 로직이 screen 테스트로만 간접 커버됨.

### 권장 신규 테스트 (Session 31 과제 후보)
1. `collection_remote_datasource_test.dart` — `~6` tests (CRUD × success/fail)
2. `collection_list_provider_test.dart` — `~5` tests (build, loadMore, create success/fail, delete rollback)
3. `collection_detail_provider_test.dart` — `~2` tests (success/fail)
4. `collection_links_provider_test.dart` — `~2` tests (success, P0-A failure throws)

**예상 추가**: 약 15 tests (현재 379 → 394 GREEN 목표).

---

## Observations (Wave 2/3 대비)

### Clean Architecture 준수 ✅
- Layer boundary 명확 (presentation → domain → data)
- Repository가 userId를 주입받아 DataSource로 전달하는 DI 패턴 일관
- Freezed entity + manual DTO mapper 분리 (link feature와 동일)

### Riverpod 패턴 ✅
- `@riverpod` 코드 생성 일관 사용
- `AsyncValue.guard` (`refresh`), `ref.watch` (di providers) 적절

### 불일치 / 개선 포인트 ⚠️
- **링크와의 에러 전파 일관성 부족**: `collection_list_provider._fetch`는 `throwWithStackTrace` 쓰지만(21), create/update/delete는 조용히 실패 (P1-C/P2-C). 링크 feature는 Session 28에서 통일됨.
- **Session 28에서 링크가 받은 혜택(provider/DS 테스트)이 컬렉션엔 미적용**.
- **검색/필터 기능 부재** — 컬렉션 수가 늘면 로드된 100개를 사용자가 스크롤로 찾아야 함. 현 리뷰 범위 밖이지만 로드맵 관점.

---

## Top 3 즉시 수정 권고 (Session 30)

1. **P0-A** — `collection_links_provider.dart:14` failure throw 변경 (3줄)
2. **P1-A** — Supabase RLS 정책 재확인 + `user_id` 명시 필터 추가 (update/delete)
3. **P1-C** — `collection_list_provider` create/update 에러 propagate + form 화면 try/catch

**Session 31 백로그**: P1-B, P2-A~D, P3-A~B + 테스트 갭 보강 (remote DS / provider 3종).

---

## 참고 링크

- **Wave 3 리뷰**: `docs/review/wave3_link_review.md`
- **Wave 2 리뷰**: `docs/code_review/2026-04-13_wave2_core.md`
- **Session 28 로그**: `docs/daily_task_log/2026-04-14_session28.md`
