# Phase 4 Plan — Local Cache & Performance Optimization

> **기반**: `docs/research-phase4.md`
> **scope**: Link feature 로컬 캐시 (Hive CE) + Remote-First/Local-Fallback + 즐겨찾기 캐시 동기화

---

## 변경 파일 목록

| # | Action | File | 변경 내용 |
|---|--------|------|----------|
| 1 | **CREATE** | `lib/features/link/data/datasource/link_local_datasource.dart` | Hive 기반 로컬 CRUD |
| 2 | **MODIFY** | `lib/core/storage/storage_service.dart` | links box 열기 |
| 3 | **MODIFY** | `lib/features/link/data/repository/link_repository_impl.dart` | Remote-first + Local fallback |
| 4 | **MODIFY** | `lib/features/link/presentation/provider/link_di_providers.dart` | Local DS provider 추가, Repository 생성자 변경 |

**총 4파일** (1 신규, 3 수정). UseCase, Entity, Provider(list/detail/form), Screen은 변경 없음.

---

## 단계별 구현 순서

### Step 1: LinkLocalDataSource 생성

**파일**: `lib/features/link/data/datasource/link_local_datasource.dart`

```dart
class LinkLocalDataSource {
  LinkLocalDataSource(this._box);
  final Box<Map> _linksBox;

  // Read
  Result<PaginatedState<LinkEntity>> getCachedLinks({bool favoritesOnly});
  Result<LinkEntity> getCachedLinkById(String id);

  // Write (cache management)
  Future<void> cacheLinks(List<LinkEntity> links);
  Future<void> cacheSingleLink(LinkEntity link);
  Future<void> removeCachedLink(String id);
  Future<void> updateCachedFavorite(String id, {required bool isFavorite});
  Future<void> clearAll();
}
```

**설계**:
- `Box<Map>` 사용 — Entity의 `toJson()`으로 저장, `fromJson()`으로 복원
- key: `link.id` (String)
- 최대 100개 유지 (`_trimCache()`)
- Read는 동기 (Hive의 in-memory cache 활용), `Result<T>` 반환
- Write 실패는 silent (Remote 결과에 영향 없음)

### Step 2: storage_service.dart 수정

**파일**: `lib/core/storage/storage_service.dart`

변경:
- `initHive()`에 `await Hive.openBox<Map>('links');` 추가

### Step 3: LinkRepositoryImpl 수정

**파일**: `lib/features/link/data/repository/link_repository_impl.dart`

변경:
- 생성자에 `LinkLocalDataSource` 추가
- 각 메서드에 Remote-First + Local-Fallback 패턴 적용:

```
getLinks():
  Remote 호출 → 성공 시 Local에 캐시 저장 + 반환
                 실패 시 Local에서 읽기 → 없으면 CacheFailure

getLinkById():
  Remote → 성공 시 cacheSingleLink + 반환
           실패 시 getCachedLinkById

createLink() / updateLink():
  Remote → 성공 시 cacheSingleLink + 반환
           실패 시 에러 반환 (offline create 미지원)

deleteLink():
  Remote → 성공 시 removeCachedLink + 반환
           실패 시 에러 반환

toggleFavorite():
  Remote → 성공 시 updateCachedFavorite + 반환
           실패 시 에러 반환 (Provider의 optimistic rollback이 처리)
```

### Step 4: DI Provider 수정

**파일**: `lib/features/link/presentation/provider/link_di_providers.dart`

변경:
- `linkLocalDataSourceProvider` 추가 (Hive box 주입)
- `linkRepositoryProvider` 생성자에 local DS 전달

---

## 수정하지 않는 것

- `ILinkRepository` 인터페이스 — 변경 없음 (Repository 내부 구현만 바뀜)
- UseCase 계층 — Repository에 위임하므로 변경 불필요
- `LinkList`, `LinkDetail`, `LinkForm` Provider — Repository 인터페이스 불변이므로 변경 없음
- Screen/Widget — Provider 구독 패턴 동일
- Collection, Search feature — Phase 4 scope 밖

---

## 검증 방법

1. `flutter analyze` — 정적 분석 에러 0
2. `dart run build_runner build` — 코드 생성 정상
3. 수동 확인:
   - 앱 실행 → 링크 목록 정상 로드 (Remote)
   - 비행기 모드 → 앱 재시작 → 캐시된 링크 표시
   - 즐겨찾기 토글 → Remote 실패 시 UI 롤백
