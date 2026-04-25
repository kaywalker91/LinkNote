# 다음 세션 프롬프트

아래 내용을 그대로 붙여넣기해서 다음 세션을 시작하세요.

---

```
Session 42 — Session 41 fix 머지 + Hive cache 정상화 (LinkEntity.toJson nested)

## 미션 한 줄

Session 41 (2026-04-25) 의 `fix/link-list-tag-parse-error` 브랜치(커밋 `d6dd524`)를 PR + 머지하고, 진단 중 노출된 별개 잠재 이슈 — `LinkEntity.toJson` 의 nested `TagEntity` 직렬화 누락으로 `cacheLinks` 가 매번 silent fail 하는 문제 — 를 별도 PR 로 정상화한다.

## 배경

Session 41 (2026-04-25, 본 세션 직전):
- Session 40 머지 후 사용자가 첫 태그 추가 → 홈 진입 시 link list 가 빈 ErrorStateWidget 으로 빠지는 회귀 노출
- 실기기 (SM A346N RFCW615RBFT) 진단으로 root cause 가 `cacheLinks` 의 `HiveError: Cannot write, unknown type: _TagEntity` 였음을 확정
- HiveError 가 Dart `Error` 자식이라 `on Exception catch` 로 안 잡혀 위로 전파 → AsyncValue.error 에 raw Error 저장 → 화면 빈 fallback
- fix: catch 12곳 `on Exception` → `on Object` 통일, `LinkTagDto.tags` nullable, `failure_ui` debug 분기, 단위 +3 / widget 7곳 textContaining
- 검증: 466 tests GREEN, analyze 0 issues, 실기기 통과

별개로 노출된 잠재 이슈 (Session 41 에서 의도적으로 deferred):
- `cacheLinks` 가 매번 silent fail (콘솔에 `cacheLinks failed` 로그)
- root cause 가설: `LinkEntity.toJson()` 의 `tags` 필드가 `List<TagEntity>` 그대로 반환됨 (nested toJson 미호출)
- 영향: offline fallback (`LinkRepositoryImpl` 의 `_localDataSource.getCachedLinks`) 가 항상 빈 cache 로 동작. 사용자가 비행기모드일 때 빈 화면이 됨
- 화면 영향은 현재 없음 (Session 41 fix 가 silent 처리)

## 작업 범위

### Stage 1 — Session 41 fix 머지 (PR 단일 머지)
- `fix/link-list-tag-parse-error` 푸시 (사용자 명시 승인 필수)
- PR 생성 → CI 4 jobs green 확인 → 사용자 승인 후 머지
- 로컬 브랜치 정리 + main pull

### Stage 2 — Hive cache 정상화 (별도 PR `fix/cache-link-tojson-nested`)

**가설 검증 (RED 단계)**:
- 신규 단위 테스트: `LinkEntity.toJson()` 결과의 `tags` 가 `List<Map<String, dynamic>>` 인지 검증
  - 현재 동작 가설: `List<_TagEntity>` 그대로 반환 → 실패(RED)
- `LinkLocalDataSource.cacheLinks` mock-box 통합 테스트로 HiveError 재현

**Fix 후보 (GREEN)**:
- **A**. `freezed` annotation 에 `@JsonSerializable(explicitToJson: true)` 추가
  - freezed 4.x 의 정확한 syntax 는 context7 로 검증 필요
  - 영향: LinkEntity / TagEntity / LinkDto / LinkTagDto / TagDto / CollectionNameDto 등 모두 검토
- **B (권장)**. `LinkLocalDataSource._entityToMap` 에서 boundary 처리:
  ```dart
  Map<String, dynamic> _entityToMap(LinkEntity entity) {
    final map = entity.toJson();
    map['tags'] = entity.tags.map((t) => t.toJson()).toList();
    return map;
  }
  ```
  - 장점: entity 정의 무손, 명시적 boundary 처리
  - 단점: 다른 nested 필드 추가 시 매번 수동 추가
- **C**. `jsonDecode(jsonEncode(entity.toJson()))` — 비효율, 비추천

**REFACTOR**:
- 실기기 회귀: `flutter run --flavor dev` → 콘솔에 `cacheLinks failed` 로그 사라짐 확인
- offline 시나리오: 비행기모드 토글 후 홈 진입 → cached 링크 정상 표시

### Stage 3 (선택) — DateRangePicker MaterialLocalizations
- Session 41 monitor 로그에서 노출:
  ```
  No MaterialLocalizations found.
  DateRangePickerDialog widgets require MaterialLocalizations to be provided
  ```
- `lib/app/app.dart` 의 MaterialApp 에 `flutter_localizations` delegates 추가
- pubspec 에 `flutter_localizations` SDK 의존성 + `intl` 보조
- locale: `Locale('ko'), Locale('en')`

## 검증 절차

```bash
cd ~/AndroidStudioProjects/LinkNote

# Stage 1
git fetch origin
git checkout fix/link-list-tag-parse-error
git log --oneline -1                          # d6dd524 확인
git push -u origin fix/link-list-tag-parse-error    # 사용자 명시 승인 필수
gh pr create --base main --title "..." --body "..."
# CI green → 사용자 승인 → squash merge
git checkout main && git pull --ff-only
git branch -d fix/link-list-tag-parse-error

# Stage 2
git checkout -b fix/cache-link-tojson-nested
# 1) RED 테스트 추가 (LinkEntity.toJson tags 직렬화 검증)
# 2) Fix 옵션 B 적용 + 추가 unit/integration 테스트
dart format lib/ test/
flutter analyze --fatal-warnings              # 0 issues 기대
flutter test --reporter=failures-only         # 466+ tests GREEN

flutter run --flavor dev -t lib/main_dev.dart -d RFCW615RBFT
# → 홈 진입 시 cacheLinks failed 로그 0건
# → 비행기모드 + 홈 진입 시 cached 링크 표시
```

## 단위/위젯 테스트 (Stage 2)

- `test/features/link/data/datasource/link_local_datasource_test.dart` — 신규 또는 갱신:
  - tags 가진 LinkEntity cacheLinks → Hive box 에 저장 성공 (현재 RED)
  - getCachedLinks → tags 복원 정상
- `test/features/link/domain/entity/link_entity_test.dart` (신규):
  - `LinkEntity.toJson()['tags']` 가 `List<Map<String, dynamic>>` 인지

## 알려진 인접 이슈 (Session 42 무관)

- **Supabase RLS / FK 점검** — Session 41 fix 가 null tags 응답 방어 처리. 본질 정책 점검은 dashboard 액세스 별도 트랙
- **HomeScreen 빈 상태 한글화** — 'No links yet'/'Add Link' 등 영문 잔존
- **Collection 화면 디자인 토큰 정합성** — LnIconBtn/AppRadius/forest 토큰화 화면별 단독 PR
- **Search / LnTabBar / share-sheet / Dark mode** — Phase 4+ 디자인 오버홀

## 불변 원칙

- **git push / merge 사용자 명시 승인 필수**
- **Branch Protection** — PR + CI 4 job green 필수
- **TDD RED → GREEN** — 데이터 레이어 변경은 테스트 선행 필수
- **i18n Option B** — UI 사용자 대면 카피는 한글, snackbar/Exception/Failure.message 는 영문
- **CI dart format 선행** — 푸시 전 로컬 `dart format`
- **omit_local_variable_types** — 로컬 변수는 `var`
- **on Exception 만 catch 금지** — Dart `Error` 는 `Exception` 의 자식이 아님 (Session 41 학습)
- **수치 기준 창작 금지** — 사용자가 정성 표현 쓰면 `AskUserQuestion` 으로 확인

## 완료 기준

- [ ] Stage 1: fix/link-list-tag-parse-error PR 머지 + 로컬 브랜치 정리
- [ ] Stage 2: fix/cache-link-tojson-nested PR 머지
  - [ ] RED 테스트 작성 + 실패 확인
  - [ ] GREEN 통과 (cacheLinks 정상 저장)
  - [ ] 실기기 cacheLinks failed 로그 0건
  - [ ] (이상적) 비행기모드 offline fallback 검증
- [ ] flutter analyze 0
- [ ] 메모리 갱신:
  - [ ] `project_code_review_roadmap.md` Session 41/42 entry
  - [ ] `feedback_dart_error_vs_exception.md` Session 41 적용 결과
  - [ ] `feedback_freezed_nested_tojson.md` (신규, Stage 2 결과)
  - [ ] `MEMORY.md` 인덱스 갱신

## 참조 문서/메모리

- **Session 41 commit**: `d6dd524` (fix/link-list-tag-parse-error)
  - lib (5): failure_ui, link_local_ds, link_remote_ds, link_dto + freezed/g, link_mapper
  - test (8): mapper +2, datasource +1, async_value_view, 5 widget screens
- **버그 진단 컨텍스트**: 본 문서 "배경" 섹션 + Session 41 commit message
- **i18n 정책**: `feedback_i18n_policy.md`
- **Failure 분류**: `lib/core/error/failure.dart`, `lib/core/error/failure_ui.dart`
- **Error vs Exception**: `feedback_dart_error_vs_exception.md`

## 세션 경계

Session 41 fix PR 머지 + Hive cache 정상화 PR 머지까지. DateRangePicker localizations 는 시간 여유 시 같은 세션 OK 또는 별도. HomeScreen 한글화 / Collection 디자인 토큰 / Search / LnTabBar / Dark mode 는 별도 세션.
```
