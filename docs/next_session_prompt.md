# 다음 세션 프롬프트

아래 내용을 그대로 붙여넣기해서 다음 세션을 시작하세요.

---

```
Session 33 — Wave 5 Link P1 PR 머지 + P2/P3 수정 스프린트

## 미션 한 줄

Wave 5 Link P1 수정 PR을 머지하고, P2/P3 잔여 수정으로 Wave 5를 마무리한다.

## 배경

Session 32에서:
- 사용하지 않는 브랜치 정리 (로컬 3개 + 리모트 5개 삭제)
- Wave 5 대상 "Link 고급 시나리오" 선정 + 리뷰 문서 `docs/review/wave5_link_review.md` 작성 (16건: P1:4, P2:6, P3:6)
- **P1 4건 + P2-A 수정 완료** (TDD RED→GREEN):
  - P1-A: OgTagService `Result<OgTagResult>` 전환 + 한국어 에러 피드백
  - P1-B: HTTPS→HTTP redirect downgrade 차단 (수동 hop 추적, 최대 3회)
  - P1-C: `og_tag_service_test.dart` 신규 13 test cases
  - P1-D: moveToCollection 후 `linkDetailProvider(linkId)` invalidate
  - P2-A: UrlSanitizer `_maxLength = 2048` DOS 가드
- 베이스라인: **426 tests GREEN**, analyze 0
- 커밋: `ba61c0f` on `chore/wave5-link-review`

현재 상태:
- **브랜치**: `chore/wave5-link-review` (main에서 분기, 커밋 1개 ahead)
- **PR 미생성** — 머지 대기
- **Branch Protection 활성화** — PR + CI 4 job green 필수
- **docs-only 단독 PR 금지** 원칙 유지

## 가장 먼저 할 일 (순서 엄수)

### 0. 상태 확인
```bash
cd ~/AndroidStudioProjects/LinkNote
git status && git log --oneline -5
flutter analyze --fatal-warnings
flutter test --reporter compact 2>&1 | tail -3   # 426 GREEN 확인
```

### 1. PR 생성 + CI + 머지
- `chore/wave5-link-review` → main PR 생성
- CI 4 job green 확인
- **사용자 승인 후 머지**

### 2. Wave 5 P2/P3 수정 브랜치
```bash
git checkout main && git pull
git checkout -b fix/wave5-p2-p3
```

### 3. P2 수정 (6건)
아래는 `docs/review/wave5_link_review.md` 참조:
- **P2-B**: IDN (유니코드 도메인) 정책 결정 + 테스트
- **P2-C**: OgTagService 대용량 응답 제한 (max body size)
- **P2-D**: moveToCollection optimistic rollback 명시
- **P2-E**: null → null 컬렉션 이동 early return 가드
- **P2-I (잔존)**: link_repository_impl dead branch — 현재 코드 재검증 (Session 32에서 이미 정상 확인, 실제로는 미수정 필요)

### 4. P3 수정 (선택적, 시간 허용 시)
- **P3-A**: Share Intent 부재 — 별도 PRD로 이관 결정
- **P3-B**: Provider autoDispose 명시
- **P3-C**: LinkFormProvider dispose 시 CancelableOperation cancel
- Wave 3 잔존 P3: LinkFormWidget 추출 (P3-D'), 태그 색상 하드코딩 (P3-C'), favorite toggle detail 갱신 (P3-E')

### 5. PR + 머지 + 문서 마무리

## 불변 원칙

- **git push / merge 사용자 명시 승인 필수**
- **Branch Protection 활성화** — PR + CI 4 job green 필수
- **TDD RED → GREEN** 준수 (테스트 실패 로그 확보)
- `.env`, keystore, Firebase service account key 커밋 금지
- Provider Failure 전파는 `Error.throwWithStackTrace(failure, StackTrace.current)` 패턴 사용
- docs-only 단독 PR 지양 — 코드와 묶음
- **집계(count) 배지 규칙**: cascade invalidate (Session 31 교훈)
- **OgTagService testability**: 생성자 `Dio? dio` 주입 패턴 유지. 테스트는 `_FakeAdapter` + `Dio()..httpClientAdapter = adapter`

## 완료 기준

- [ ] Wave 5 P1 PR 머지 (CI 4 job green)
- [ ] P2 수정 + 테스트 + PR 머지
- [ ] (Optional) P3 부분 수정
- [ ] Session 33 daily log + memory 업데이트

## 참조 문서

- **Wave 5 리뷰**: `docs/review/wave5_link_review.md`
- **Wave 3 Link 리뷰**: `docs/review/wave3_link_review.md`
- **Session 32 로그**: `docs/daily_task_log/2026-04-18_session32.md`
- **Aggregate badge invalidate 메모리**: `~/.claude/projects/-Users-kaywalker-AndroidStudioProjects-LinkNote/memory/feedback_aggregate_invalidate.md`

## Session 32 lessons (반드시 검토)

- **OgTagService DI 패턴**: 생성자에 `Dio? dio` 파라미터 → 테스트에서 `_FakeAdapter`로 HTTP 계층 모킹. production은 null로 기본 Dio 사용
- **per-request Options vs BaseOptions**: 테스트에서 user-provided `Dio()`가 BaseOptions를 override하지 않으므로, `followRedirects`/`validateStatus`/`responseType`은 `static Options`로 분리하여 `_dio.get(url, options: _requestOptions)`로 요청마다 적용
- **`package:async` Result 충돌**: `import 'package:async/async.dart'`는 자체 `Result` 클래스를 노출. 프로젝트 `Result<T>` typedef와 충돌 → `show CancelableOperation`으로 narrowing
- **Wave 3 잔여 확인**: Wave 5 시작 전 반드시 이전 Wave 리뷰 잔여 상태를 코드 기반으로 재검증. 문서의 "Open" 마킹이 실제 코드와 불일치할 수 있음

## 세션 경계

Wave 5 P1 PR 머지 + P2 수정 PR 머지까지. P3는 시간 허용 시 부분 처리.
```
