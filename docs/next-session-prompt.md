# 다음 세션 프롬프트

아래 내용을 그대로 붙여넣기해서 다음 세션을 시작하세요.

---

```
Session 35 — Wave 5 Link P3 수정 + Wave 3 잔존 리팩터링

## 미션 한 줄

Wave 5 Link P3 6건 수정(또는 의도적 이월 결정) + Wave 3 잔존 4건 cleanup으로 Link feature 리뷰 로드맵 마무리.

## 배경

최근 세션 히스토리:
- **Session 32 (2026-04-18)** — Wave 5 P1 머지 (PR #13, `1ceba65`): OgTagService Result/redirect/detail invalidate/URL length. 426 tests GREEN
- **Session 33 (2026-04-18)** — Wave 5 P2 머지 (PR #14, `45f2386`): OgTag body size cap / moveToCollection optimistic+rollback+guard / IDN 정책 / dead branch 재검증. **436 tests GREEN**, analyze 0
  - 교훈: `feedback_riverpod_async_notifier_inflight.md` (AsyncNotifier mid-flight optimistic 관찰 불가)
- **Session 34 (2026-04-18)** — docs 구조 정리 (PR #15, `b9bd88b`): `code_review/ + review/ → reviews/` 통합, 루트/security 파일 kebab-case 정규화, 참조 갱신. 스테일 원격 브랜치(`fix/wave5-p2`) 삭제

현재 상태:
- main 최신: `b9bd88b` 이후(Session 34 daily log + next-session-prompt 갱신 commit 포함)
- 테스트: **436 GREEN**, analyze 0
- 로컬 브랜치: main 단일, 원격도 main 단일 (정리 완료)
- **Branch Protection 활성화** — PR + CI 4 job green 필수
- **docs-only 단독 PR 금지** 원칙 유지 (Session 34의 docs 정리는 `chore` 범주로 단독 PR 예외)

## 가장 먼저 할 일 (순서 엄수)

### 0. 상태 확인
```bash
cd ~/AndroidStudioProjects/LinkNote
git checkout main && git pull
git branch -vv                            # 원격 추적 확인
flutter analyze --fatal-warnings
flutter test --reporter compact 2>&1 | tail -3   # 436 GREEN 기대
```

### 1. Wave 5 P3 스프린트 브랜치
```bash
git checkout -b fix/wave5-p3
```

### 2. P3 수정 (6건 — `docs/reviews/wave5-link-review.md` 참조)
- **P3-A — Share Intent (feature request)**: PRD 작성 → 별도 Wave로 이관 결정. 본 세션에서는 결정만 내리고 구현 제외 가능
- **P3-B — Provider autoDispose 명시**: `link_list_provider`, `link_detail_provider`, `link_form_provider`에 `@Riverpod(keepAlive: true/false)` 명시
- **P3-C — LinkFormProvider dispose 시 CancelableOperation cancel**: `_pendingOgParse?.cancel()`을 `ref.onDispose`에 추가
- **Wave 3 잔존 (4건)**:
  - **P3-D'**: `LinkFormWidget` 추출 (add/edit ~50줄 중복)
  - **P3-C'**: 태그 색상 `'#6750A4'` 하드코딩 제거 (design token 또는 Theme 기반)
  - **P3-E'**: `link_detail_screen.dart:37-39` favorite 토글 후 `linkDetailProvider` 미갱신
  - **i18n 혼재**: snackbar 한글 / AppBar 영문 일치화

### 3. Workflow 문서 동기화 (Session 34에서 식별, 본 PR에 묶음)
`docs/linknote-workflow.md` stale/불일치 항목 정정:
- **(필수) Section 4.1 브랜치 전략**: `develop` 브랜치 줄 삭제 — 실제로는 `main` 단일 + `feature/*`/`fix/*`/`chore/*` 직접 PR 운영. Branch Protection도 `main`에만 적용. Phase 6 체크리스트의 "develop 머지 시 Firebase App Distribution"도 미실행/미사용 상태와 일관시킴
- **(필수) Phase 5 헤더 + Line 209**: "315개 테스트" → 현재 수치(436+)로 갱신. 표현은 "300+ → 436개" 또는 단순 "436+개" 권장
- **(필수) Phase 7 릴리스 서명 항목**: "Release `signingConfig` 골격 작성" 옆에 **"실 keystore 미생성, 서명 빌드 검증 미완"** 명시 (현재 `[x]`로 보여 오해 소지)
- **(선택) 코드 리뷰 Wave 1~5 반영**: Phase 6과 Phase 7 사이에 "Phase 6.5 — 보안 감사 & 코드 리뷰 강화" 신설 검토 (보안 감사 P0/P1/P2 10건 + Wave 1~5). Session 35 범위 부담되면 별도 chore PR로 이월 가능

### 4. PR + 머지 + 문서 마무리
- 세션 문서: `docs/daily_task_log/YYYY-MM-DD_session35.md` (세션 시작일 기준)
- CHANGELOG Session 35 섹션 추가
- Session 35 문서는 본 코드 PR에 묶음 (docs-only 단독 PR 지양)

## 불변 원칙

- **git push / merge 사용자 명시 승인 필수**
- **Branch Protection 활성화** — PR + CI 4 job green 필수
- **TDD RED → GREEN** 준수 (테스트 실패 로그 확보)
- `.env`, keystore, Firebase service account key 커밋 금지
- Provider Failure 전파는 `Error.throwWithStackTrace(failure, StackTrace.current)` 패턴 사용
- docs-only 단독 PR 지양 — 코드와 묶음 (chore 성격의 구조 정비는 예외)
- **집계(count) 배지 규칙**: cascade invalidate (`feedback_aggregate_invalidate.md`)
- **AsyncNotifier optimistic 테스트**: mid-flight 관찰 불가. 완료 후 최종 상태만 검증 (`feedback_riverpod_async_notifier_inflight.md`)
- **문서 네이밍**: 신규 문서는 `kebab-case` (Session 34 규약). 기존 `daily_task_log/`, `work_performance/` 는 snake_case 유지

## 완료 기준

- [ ] Wave 5 P3 6건 처리 (수정 또는 의도적 이월 결정)
- [ ] `docs/linknote-workflow.md` stale 항목 정정 (브랜치 전략 / 테스트 수치 / 릴리스 서명 표시)
- [ ] Wave 3 잔존 4건 cleanup (또는 일부 이월 결정)
- [ ] CI 4 job green + 사용자 승인 머지
- [ ] Session 35 daily log + CHANGELOG + memory 업데이트

## 참조 문서

- **Wave 5 리뷰**: `docs/reviews/wave5-link-review.md`
- **Wave 3 Link 리뷰**: `docs/reviews/wave3-link-review.md`
- **Session 33 로그**: `docs/daily_task_log/2026-04-18_session33.md` (Wave 5 P2)
- **Session 34 로그**: `docs/daily_task_log/2026-04-18_session34.md` (docs 정리)
- **Aggregate invalidate 메모리**: `feedback_aggregate_invalidate.md`
- **AsyncNotifier in-flight 메모리**: `feedback_riverpod_async_notifier_inflight.md`
- **Wave 5 P3 코드 리뷰**: `docs/reviews/wave5-link-review.md` 의 P3 섹션

## 세션 경계

Wave 5 P3 PR 머지 + Wave 3 잔존 cleanup까지. Share Intent(P3-A)는 PRD만 작성하고 별도 Wave로 이관.
```
