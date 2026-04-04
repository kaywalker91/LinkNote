# Phase 4 Research — Local Cache & Performance Optimization

## 1. Current Architecture Summary

### Data Flow (현재)
```
Screen → Provider → UseCase → Repository → RemoteDataSource → Supabase
```

### Key Files

| Layer | File | Role |
|-------|------|------|
| Entity | `link/domain/entity/link_entity.dart` | `@freezed` + `fromJson/toJson` |
| Entity | `link/domain/entity/tag_entity.dart` | `@freezed` + `fromJson/toJson` |
| Repository I/F | `link/domain/repository/i_link_repository.dart` | 6 methods |
| Repository Impl | `link/data/repository/link_repository_impl.dart` | Remote only, passthrough |
| Remote DS | `link/data/datasource/link_remote_datasource.dart` | Supabase client |
| DTO | `link/data/dto/link_dto.dart` | 4 freezed classes |
| Mapper | `link/data/mapper/link_mapper.dart` | DTO ↔ Entity |
| DI | `link/presentation/provider/link_di_providers.dart` | Riverpod providers |
| List Provider | `link/presentation/provider/link_list_provider.dart` | Optimistic update 포함 |
| Detail Provider | `link/presentation/provider/link_detail_provider.dart` | |
| Form Provider | `link/presentation/provider/link_form_provider.dart` | Create/Update |
| Connectivity | `shared/providers/connectivity_provider.dart` | `isOnlineProvider` |
| Hive Init | `core/storage/storage_service.dart` | `initHive()` — settings box만 |

### Existing Hive CE Setup
- `hive_ce` + `hive_ce_flutter` 의존성 설치 완료
- `initHive()` → `Hive.initFlutter()` + 'settings' box 열림
- **아직 없는 것**: Hive adapter, local datasource, cache box

### Error Handling
- `Failure` sealed class: `ServerFailure`, `NetworkFailure`, `CacheFailure`, `AuthFailure`, `UnknownFailure`
- `Result<T>` typedef: `({T? data, Failure? failure})`
- `CacheFailure` 이미 정의되어 있어 로컬 캐시 에러 처리에 사용 가능

### Optimistic Update (현재)
- `LinkList.toggleFavorite()`: UI 즉시 반영 → Remote 호출 → 실패 시 `previous` state 롤백
- `LinkList.deleteLink()`: 동일 패턴
- **이미 rollback 로직 존재** — Remote 실패 시 정상 작동

### Connectivity
- `isOnlineProvider` (keepAlive) — `connectivity_plus` 기반
- `OfflineBannerWidget` — offline 시 오렌지 배너 표시

---

## 2. Target Data Flow (Phase 4)

```
Screen → Provider → UseCase → Repository → Remote (try first)
                                          ↘ Local (fallback on failure)
                                          ↗ Local (cache on success)
```

### 변경 범위

| 변경 유형 | 파일 |
|----------|------|
| **신규 생성** | `link/data/datasource/link_local_datasource.dart` |
| **신규 생성** | `link/data/model/cached_link.dart` (Hive model) |
| **수정** | `link/data/repository/link_repository_impl.dart` (Local fallback 추가) |
| **수정** | `link/presentation/provider/link_di_providers.dart` (Local DS DI 추가) |
| **수정** | `core/storage/storage_service.dart` (adapter 등록 + box 열기) |
| **수정 없음** | `i_link_repository.dart`, UseCase, Provider, Screen — 인터페이스 불변 |

---

## 3. Design Decisions

### 3.1 Hive 저장 포맷: JSON Map 방식
Entity는 이미 `@freezed` + `toJson/fromJson` 지원. Hive TypeAdapter를 수동 작성하는 대신 `Box<Map>` (JSON)으로 저장하면:
- 스키마 변경 시 adapter 재생성 불필요
- Entity의 freezed 직렬화를 그대로 활용
- Trade-off: 약간의 직렬화 오버헤드 (수십 개 링크 수준에서 무시 가능)

### 3.2 Cache Strategy: Remote-First + Local Fallback
- **Online**: Remote 호출 → 성공 시 Local에 캐시 저장 → 결과 반환
- **Offline / Remote 실패**: Local 캐시에서 읽기 → 캐시 없으면 `CacheFailure`
- **쓰기 작업 (Create/Update/Delete)**: Online에서만 수행, Offline 시 에러 반환
  - Offline write queue는 Phase 4 scope 밖 (과설계 방지)

### 3.3 Cache Scope
- **캐시 대상**: 링크 목록 (최근 N개), 즐겨찾기 목록, 개별 링크 상세
- **캐시 미대상**: 검색 결과, 컬렉션 (Phase 4에서는 link만)
- **TTL**: 없음 (Remote 성공 시 항상 덮어쓰기, 앱 재시작 시에도 유지)

### 3.4 Favorites Optimistic Update + Rollback
현재 `LinkList.toggleFavorite()`에 이미 구현되어 있음:
1. UI 즉시 반영 (optimistic)
2. Remote 호출
3. 실패 시 previous state 복원 (rollback)

Phase 4 추가: Remote 성공 시 Local 캐시도 업데이트.

---

## 4. Potential Side Effects

- `initHive()`에 adapter 등록 추가 → 기존 settings box에 영향 없음
- `LinkRepositoryImpl` 생성자에 `LinkLocalDataSource` 추가 → DI provider 수정 필요
- `CacheFailure` 사용 시 UI에서 이미 Failure 처리 패턴 존재 → 추가 UI 변경 불필요

---

## 5. Edge Cases

1. **캐시 비어 있는 상태 + Offline** → `CacheFailure` 반환 → 기존 에러 UI 표시
2. **Remote 성공 + 캐시 저장 실패** → Remote 결과 그대로 반환 (캐시 실패는 무시)
3. **앱 업데이트 후 캐시 스키마 변경** → JSON Map 방식이므로 하위 호환 유지 (새 필드는 null)
4. **대량 캐시** → 최근 100개만 유지 (LRU 정리)
5. **동시 읽기/쓰기** → Hive는 단일 isolate에서 thread-safe
