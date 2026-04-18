# 다음 세션 프롬프트

아래 내용을 그대로 붙여넣기해서 다음 세션을 시작하세요.

---

```
Session 36 — Wave 5 P3 PR 머지 후속 + Share Intent PRD 초안 + Collection/Search i18n 정리

## 미션 한 줄

Wave 5 Link 리뷰 로드맵 클로즈아웃. (1) Session 35 PR(`fix/wave5-p3`) 머지 후속, (2) 이월된 Share Intent PRD 초안, (3) Collection/Search 화면 i18n 잔존 정리.

## 배경

최근 세션 히스토리:
- **Session 33 (2026-04-18)** — Wave 5 P2 머지 (PR #14, `45f2386`): OgTag body size cap / moveToCollection optimistic+rollback+guard / IDN 정책 / dead branch 재검증. 436 GREEN
- **Session 34 (2026-04-18)** — docs 구조 정리 (PR #15, `b9bd88b`): `reviews/` 통합 + kebab-case 정규화
- **Session 35 (2026-04-18)** — Wave 5 P3 + Wave 3 잔여 cleanup + Workflow sync (`fix/wave5-p3` 브랜치):
  - P3-B autoDispose 명시, P3-C onDispose cancel, P3-E' favorite→detail invalidate, P3-C' 태그 색상 토큰화, P3-i18n Link snackbar 영문 통일
  - P3-D' LinkFormFields 위젯 추출 (ref.listen 기반 controller 미러링)
  - Workflow doc 3건 정정 + Phase 6.5 신설 + Q&A 갱신
  - P3-A Share Intent 이월 결정 기록 (PRD 선결 과제 4건 명시)
  - **437 GREEN**, analyze 0

현재 상태 (Session 36 시작 전):
- `fix/wave5-p3` 브랜치가 Session 35 작업 포함한 채 **미푸시**일 수 있음 (PR 단계에 따라 확인)
- 테스트: 437 GREEN, analyze 0
- 로컬 브랜치: main + fix/wave5-p3
- Branch Protection 활성화 — PR + CI 4 job green 필수
- docs-only 단독 PR 금지 (chore 성격 구조 정비는 예외)

## 가장 먼저 할 일 (순서 엄수)

### 0. 상태 확인
```bash
cd ~/AndroidStudioProjects/LinkNote
git branch -vv
git status
flutter analyze --fatal-warnings
flutter test --reporter=failures-only 2>&1 | tail -3   # +437: All tests passed! 기대
```

### 1. Session 35 PR 후속 처리

- `fix/wave5-p3` 미푸시 상태면 → `git push -u origin fix/wave5-p3` (사용자 명시 승인 후)
- PR 생성 → CI 4 job green → 사용자 승인 후 머지
- 머지 완료 후 `git checkout main && git pull && git branch -d fix/wave5-p3`
- 원격 tracking 브랜치 정리: `git fetch --prune`

### 2. Share Intent PRD 초안 (P3-A 이월분)

`docs/prds/share-intent.md` (신규) — 별도 Wave 진입 전 선결 과제 4건을 PRD 형식으로:

1. **Payload 타입 분기** — URL / plain text / image 각각의 UX (URL: 자동 파싱 + 폼 이동 / text: URL 추출 시도 / image: 링크 + 썸네일)
2. **앱 상태별 동작** — cold start: 초기 라우트를 `link/add` 로 분기 / warm resume: 현재 화면 위로 bottom sheet 혹은 전환
3. **iOS App Extension** — Share Extension 필요 여부 + App Groups 설정 (공유 UserDefaults) 검토
4. **패키지 선정** — `receive_sharing_intent` (커뮤니티) vs 플랫폼 채널 직접 구현. 장단점 비교

(PRD 는 "초안" 수준: 옵션 / 결정 사항 / 미해결 질문 기록. 실제 구현은 Share Intent Wave 에서 별도 진행)

### 3. Collection / Search i18n 정리 (Wave 3 P3-E 확장)

**Collection (`lib/features/collection/`)**:
- `collection_detail_screen.dart:59` `'컬렉션이 삭제되었습니다'` → `'Collection deleted'`
- `collection_form_screen.dart:71,79` 수정/생성/실패 메시지 영문화
- 테스트에 해당 한글 문자열 references 있으면 동시 갱신 (기존 grep: 0 hits 확인)

**Search (`lib/features/search/`)**:
- `search_screen` UI 문구(`'링크를 검색하세요'`, `'링크, 메모, 태그 검색'`): 의도적으로 사용자 대면 한글로 유지할지 결정 필요 — 세션 초반 사용자 확인
  - Option A: 모두 영문 통일 (기존 Wave 3 P3-E 방향)
  - Option B: 사용자 대면 UX 카피는 한글 유지, 개발자 snackbar 만 영문 (현재 앱의 실제 언어 타겟을 확인)
- `url_launcher_helper.dart` 에러 문구 3건도 같은 질문에 답이 필요

**불확실성이 있으면 사용자에게 먼저 `AskUserQuestion` 으로 확인**.

### 4. (선택) Auth Remote 한글 메시지
`auth_remote_datasource.dart:67` `이메일 확인 링크가 발송되었습니다...` — 서버 메시지 경로. 사용자 대면이므로 Step 3 의 결정과 연동.

### 5. PR + 머지 + 세션 마무리
- 세션 문서: `docs/daily_task_log/YYYY-MM-DD_session36.md`
- CHANGELOG Session 36 섹션
- Session 36 문서는 본 코드 PR 에 묶음

## 불변 원칙

- **git push / merge 사용자 명시 승인 필수**
- **Branch Protection 활성화** — PR + CI 4 job green 필수
- **TDD RED → GREEN** 준수 (Domain/Data 레이어 필수, Presentation 권장)
- `.env`, keystore, Firebase service account key 커밋 금지
- Provider Failure 전파: `Error.throwWithStackTrace(failure, StackTrace.current)`
- docs-only 단독 PR 지양 — 코드와 묶음 (chore 성격 예외)
- **집계(count) 배지 규칙**: cascade invalidate (`feedback_aggregate_invalidate.md`)
- **AsyncNotifier optimistic 테스트**: mid-flight 관찰 불가. 완료 후 최종 상태만 검증 (`feedback_riverpod_async_notifier_inflight.md`)
- **문서 네이밍**: 신규 문서는 `kebab-case`. 기존 `daily_task_log/`, `work_performance/` 는 snake_case 유지

## 완료 기준

- [ ] Session 35 PR (`fix/wave5-p3`) 머지 완료 + 브랜치 정리
- [ ] Share Intent PRD 초안 작성 (`docs/prds/share-intent.md`)
- [ ] Collection/Search i18n 정책 결정 + 해당 정책대로 정리
- [ ] CI 4 job green + 사용자 승인 머지
- [ ] Session 36 daily log + CHANGELOG + memory 업데이트

## 참조 문서

- **Wave 5 리뷰**: `docs/reviews/wave5-link-review.md` (P3-A Deferred 결정 기록됨)
- **Wave 3 Link 리뷰**: `docs/reviews/wave3-link-review.md` (P3-E i18n 원항목)
- **Session 35 로그**: `docs/daily_task_log/2026-04-18_session35.md`
- **Aggregate invalidate 메모리**: `feedback_aggregate_invalidate.md`
- **AsyncNotifier in-flight 메모리**: `feedback_riverpod_async_notifier_inflight.md`

## 세션 경계

Session 35 PR 머지 후속 + Share Intent PRD 초안 + Collection/Search i18n 정리까지. Share Intent 실구현은 별도 Wave.
```
