# 다음 세션 프롬프트

아래 내용을 그대로 붙여넣기해서 다음 세션을 시작하세요.

---

```
Session 41 — 태그 추가 후 link list UnknownFailure 진단 + 근본 수정

## 미션 한 줄

Session 40 (Phase 2 i18n) 머지 직후, 사용자가 LinkAdd/LinkEdit 폼에서 첫 태그("news")를 추가하고 홈 진입 시 link list 가 "오류가 발생했습니다 / 잠시 후 다시 시도해 주세요" (UnknownFailure UI) 로 빈 화면이 되는 잠재 버그가 노출됨. 정확한 stack trace 를 캡처하여 근본 원인을 확정하고 별도 PR 로 수정한다.

## 배경

Session 40 (2026-04-25, PR Phase 2):
- LinkEdit amber + LinkAdd/Collection i18n 머지
- 실기기 시각 검증 통과 직후 사용자가 태그 1개("news") 추가
- 홈 재진입 시 link list 화면이 ErrorStateWidget 으로 전환

증상 분석 (Session 40 중 수행):
- 화면 표기: title="오류가 발생했습니다", message="잠시 후 다시 시도해 주세요." → `failureUiFromError` 의 fallback (`error is Failure` false 케이스)
- 즉, AsyncValue.error 에 들어 있는 객체가 `Failure` sealed class 가 아닌 raw `Error`/`Object`
- 첫 태그 추가 직후 트리거 → 이전엔 `link_tags` 가 빈 배열이라 파싱 분기 미진입, tag 1개 생기자 노출

가설 (확정 필요):
- `lib/features/link/data/datasource/link_remote_datasource.dart:60-64` 의 `getLinks` 가 `on PostgrestException` + `on Exception` 만 catch
- `LinkDto.fromJson` → `LinkTagDto.fromJson` → `tags: TagDto.fromJson(json['tags'] as Map<String, dynamic>)` 에서 `json['tags']` 가 `null` 이면 cast `_TypeError` (=`Error`) 발생
- Dart 에서 `Error` 는 `Exception` 의 자식이 아님 → `on Exception catch` 가 못 잡고 위로 전파
- `AsyncValue.guard` (또는 build 내 throw) 가 raw Error 를 그대로 AsyncValue.error 에 저장 → UnknownFailure UI

왜 `tags` 가 null 이 될 수 있나 (후보):
1. **Supabase RLS** — `tags` 테이블 SELECT 정책 부재 → join 응답에서 `tags` 만 null
2. **FK/관계 정의 미일치** — `link_tags(tags(*))` join 자체가 결과를 못 만들고 null 채움
3. **데이터 정합성** — `_syncTags` upsert 후 `link_tags.tag_id` 가 가리키는 `tags` row 가 RLS/삭제로 안 보임

## 작업 범위

### Stage 1 — 진단 (임시 변경, 커밋 금지)
- `lib/features/link/data/datasource/link_remote_datasource.dart` `getLinks` catch 블록을 `on Object catch (e, st)` 로 확장 + `appLogger.e('getLinks', error: e, stackTrace: st)` 추가
- 또는 `lib/bootstrap.dart` 에 `ProviderObserver` 등록하여 모든 provider 의 `providerDidFail` 을 로깅
- 재빌드 → 사용자 재시도 → flutter run stdout 에서 stack trace 확보

### Stage 2 — 근본 수정 (별도 PR)
가설 확정 시점에 두 트랙 병행:
- **데이터 레이어 방어**:
  - `LinkTagDto.tags` 를 `TagDto?` 로 변경 + `LinkMapper.toEntity` 에서 `dto.linkTags.where((lt) => lt.tags != null).map((lt) => _tagToEntity(lt.tags!))` 필터
  - 또는 `LinkDto.fromJson` 에 custom converter 로 null tags 무시
  - `on Exception` → `on Object` 통일 (Error 도 Failure.unknown 으로 래핑)
- **Supabase 측 정책 점검**:
  - dashboard 에서 `tags` 테이블 RLS SELECT policy 확인 (`auth.uid() = user_id` 같은 정책 존재 여부)
  - 없으면 정책 추가
  - `link_tags(tags(*))` join 의 응답 형태를 supabase REST 직접 호출로 검증

### Stage 3 — UnknownFailure UI 개선 (선택)
- 현재 `lib/core/error/failure_ui.dart` 의 UnknownFailure 는 message 무시하고 하드코딩
- debug 모드에서만 실제 message 노출하도록 분기 → 향후 비슷한 잠재 버그 조기 발견

## 검증 절차

```bash
cd ~/AndroidStudioProjects/LinkNote
git fetch origin && git checkout main && git pull --ff-only
git checkout -b fix/link-list-tag-parse-error

# Stage 1 — 임시 진단 변경 (이 변경은 커밋 X)
flutter run --flavor dev -t lib/main_dev.dart -d RFCW615RBFT
# → 사용자 휴대폰: 홈 진입 → 오류 화면 → "다시 시도" 탭
# → flutter run stdout 에서 TypeError stack trace 확보 → 가설 확정

# Stage 2 — 진단 변경 되돌리고 근본 수정 작성
dart format <변경 파일>
flutter analyze --fatal-warnings              # 0 issues 기대
flutter test --reporter=failures-only         # 463+ tests GREEN

# 실기기 회귀 검증
flutter run --flavor dev -t lib/main_dev.dart -d RFCW615RBFT
# → 홈 진입 시 태그 있는 링크 정상 표시
# → 새 태그 추가 후에도 정상
# → 일부러 잘못된 응답 시뮬레이션 (Stage 2 단위테스트 추가 권장)
```

## 단위/위젯 테스트

- `test/features/link/data/datasource/link_remote_datasource_test.dart` — 신규 또는 갱신:
  - `link_tags: [{tags: null}]` 응답에 대해 빈 tags 로 처리되는지
  - parse 실패 시 Failure.unknown 로 래핑되는지 (Error → Failure)
- `test/features/link/data/mapper/link_mapper_test.dart` — null-tags 필터링 검증

## 알려진 인접 이슈 (이번 PR 무관)

- **DateRangePicker MaterialLocalizations 누락** — Search/Collection date filter 시 발견. `lib/app/app.dart` 에 `flutter_localizations` 등록 필요. 별도 PR.
- **Collection 화면들의 디자인 토큰 정합성** — Phase 2 에서는 카피 한글화만. LnIconBtn/AppRadius/forest 토큰화는 화면별 단독 PR 권장.
- **HomeScreen 빈 상태 한글화** — 'No links yet'/'Add Link' 등 영문. 디자인 오버홀 Phase 3 에 묶기.

## 불변 원칙

- **git push / merge 사용자 명시 승인 필수**
- **Branch Protection** — PR + CI 4 job green 필수
- **TDD RED → GREEN** — 데이터 레이어 변경은 테스트 선행 필수 (rules/testing-rules.md Domain/Data 필수)
- **i18n Option B** — UI 사용자 대면 카피는 한글, snackbar/Exception/Failure.message 는 영문
- **CI dart format 선행** — 푸시 전 로컬 `dart format`
- **omit_local_variable_types** — 로컬 변수는 `var`
- **수치 기준 창작 금지** — 사용자가 정성 표현 쓰면 `AskUserQuestion` 으로 확인
- **on Exception 만 catch 금지** — Dart `Error` 는 `Exception` 의 자식이 아님. raw cast/parse 실패까지 잡으려면 `on Object` 또는 명시적 `on TypeError, on FormatException` 추가

## 완료 기준

- [ ] Stage 1 stack trace 확보 + 가설 확정 (RLS / FK / null tags 중 어느 것)
- [ ] Stage 2 근본 수정 + 회귀 테스트 추가 GREEN
- [ ] flutter analyze 0
- [ ] 실기기 회귀 검증 통과 (태그 있는 링크/없는 링크 모두 정상 표시)
- [ ] PR 생성 + 사용자 승인 머지 + 로컬 브랜치 정리
- [ ] 메모리 갱신: 새 feedback 메모 (`feedback_dart_error_vs_exception.md` 등), `project_code_review_roadmap.md` Session 41 entry, MEMORY.md 인덱스

## 참조 문서/메모리

- **Session 40 PR (Phase 2 i18n)**: 머지 후 SHA 갱신
- **버그 진단 컨텍스트**: 본 문서 "배경" + "가설" 섹션
- **i18n 정책**: `feedback_i18n_policy.md`
- **Failure 분류**: `lib/core/error/failure.dart`, `lib/core/error/failure_ui.dart`

## 세션 경계

태그-induced UnknownFailure 진단 + 근본 수정 PR 단일 머지까지. UnknownFailure UI 개선(Stage 3), DateRangePicker localizations, HomeScreen 한글화, Collection 화면 디자인 토큰 정합성은 별도 세션.
```
