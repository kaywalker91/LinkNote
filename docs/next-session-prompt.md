# 다음 세션 프롬프트

아래 내용을 그대로 붙여넣기해서 다음 세션을 시작하세요.

---

```
Session 34 — Wave 5 Link P3 수정 + Wave 3 잔존 리팩터링

## 미션 한 줄

Wave 5 Link P3 6건 수정(또는 의도적 이월 결정) + Wave 3 잔존 4건 cleanup으로 Link feature 리뷰 로드맵 마무리.

## 배경

Session 33에서:
- **Wave 5 P1 PR #13 머지** (`1ceba65`): OgTagService Result/redirect/detail invalidate/URL length — 426 tests GREEN
- **Wave 5 P2 PR #14 머지** (`45f2386`): OgTag body size cap / moveToCollection optimistic+rollback+guard / IDN 정책 문서화 / dead branch 재검증 — **436 tests GREEN**, analyze 0
- 교훈 `feedback_riverpod_async_notifier_inflight.md` 기록: AsyncNotifier 비동기 메서드 중 state가 AsyncLoading으로 래핑돼 mid-flight 관찰 불가

현재 상태:
- main 최신: `45f2386`, 436 tests GREEN, analyze 0
- 로컬 브랜치: main만 (정리 완료)
- **Branch Protection 활성화** — PR + CI 4 job green 필수
- **docs-only 단독 PR 금지** 원칙 유지

## 가장 먼저 할 일 (순서 엄수)

### 0. 상태 확인
```bash
cd ~/AndroidStudioProjects/LinkNote
git checkout main && git pull
git branch -vv                            # upstream 확인 (filter-repo 흔적 주의)
flutter analyze --fatal-warnings
flutter test --reporter compact 2>&1 | tail -3   # 436 GREEN 확인
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

### 3. PR + 머지 + 문서 마무리
- 세션 문서: `docs/daily_task_log/2026-04-19_session34.md` (또는 세션 시작일)
- CHANGELOG Session 34 섹션
- Session 33 daily log + CHANGELOG는 본 PR에 묶음 (docs-only 금지 원칙)

## 불변 원칙

- **git push / merge 사용자 명시 승인 필수**
- **Branch Protection 활성화** — PR + CI 4 job green 필수
- **TDD RED → GREEN** 준수 (테스트 실패 로그 확보)
- `.env`, keystore, Firebase service account key 커밋 금지
- Provider Failure 전파는 `Error.throwWithStackTrace(failure, StackTrace.current)` 패턴 사용
- docs-only 단독 PR 지양 — 코드와 묶음
- **집계(count) 배지 규칙**: cascade invalidate (`feedback_aggregate_invalidate.md`)
- **AsyncNotifier optimistic 테스트**: mid-flight 관찰 불가. 완료 후 최종 상태만 검증 (`feedback_riverpod_async_notifier_inflight.md`)

## 완료 기준

- [ ] Wave 5 P3 6건 처리 (수정 또는 의도적 이월 결정)
- [ ] Wave 3 잔존 4건 cleanup
- [ ] CI 4 job green + 사용자 승인 머지
- [ ] Session 34 daily log + CHANGELOG + memory 업데이트

## 참조 문서

- **Wave 5 리뷰**: `docs/reviews/wave5-link-review.md`
- **Wave 3 Link 리뷰**: `docs/reviews/wave3-link-review.md`
- **Session 33 로그**: `docs/daily_task_log/2026-04-18_session33.md`
- **Aggregate invalidate 메모리**: `feedback_aggregate_invalidate.md`
- **AsyncNotifier in-flight 메모리**: `feedback_riverpod_async_notifier_inflight.md`

## 세션 경계

Wave 5 P3 PR 머지 + Wave 3 잔존 cleanup까지. Share Intent는 PRD만 작성하고 별도 Wave로 이관.
```
