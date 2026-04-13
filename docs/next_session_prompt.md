# 다음 세션 프롬프트

아래 내용을 그대로 붙여넣기해서 다음 세션을 시작하세요.

---

```
Session 25 — Wave 2 코드 리뷰: Core 인프라 & Cross-cutting

## 미션 한 줄

lib/core/ + lib/app/ + lib/shared/ cross-cutting 약 55파일에 대해 아키텍처·로직·컨벤션 코드 리뷰를 실행하고 보고서를 생성한다.

## 배경

Session 24(2026-04-13)에서 PR #4(`07c13fe`) 머지로 docs/artifacts 정리 완료. Wave 1(보안) 코드 리뷰 + 픽스는 PR #2/#3로 main 반영 완료. 이번 세션은 Wave 2 — Core 인프라 코드 리뷰 전용.

현재 상태:
- **main은 `07c13fe`** (353 tests GREEN, analyze 0)
- **Branch Protection 활성화** — PR + CI green 경로 필수
- **Session 24 daily log + next_session_prompt 미커밋** (세션 시작 시 확인)

## 가장 먼저 할 일 (순서 엄수)

### 0. 현재 상태 확인
```bash
git status
git log --oneline -5
flutter analyze
flutter test
```

### 1. Wave 2 코드 리뷰 실행

계획서: `~/.claude/plans/resilient-imagining-starfish.md` Wave 2 섹션 참조.

**오케스트레이션 패턴 (Stage A → D)**:

#### Stage A: 준비 (10분)
1. qmd로 Wave 2 관련 메모리 리콜: `feedback_result_type.md`, `project_architecture.md`, `feedback_omit_local_var_types.md`
2. Serena `get_symbols_overview`로 `lib/core/`, `lib/app/`, `lib/shared/` 구조 맵
3. `git log --oneline --since="2026-04-08"` — 해당 범위 최근 변경 이력

#### Stage B: 1차 리뷰 — Claude 서브에이전트 (30~60분)
4. `flutter-architect` 서브에이전트: 아키텍처 시각
5. `feature-dev:code-reviewer` 서브에이전트: 버그·로직 시각

**범위 (~55 파일)**:
- `lib/core/` 전체 (network, error, storage, services, config, logger) — Wave 1 중복분 제외
- `lib/app/` 전체 — `app.dart`, `app_router.dart`(203 LOC), `app_theme.dart`(178 LOC), `routes.dart`
- `lib/shared/` cross-cutting — `providers/`, `extensions/`, `utils/debouncer`, `utils/result`
- `lib/core/error/failure.dart`, `failure_ui.dart`, `result.dart`

**검사 차원**:
- Clean Architecture 레이어 경계: `presentation → domain → data` 단방향. 역참조 탐지
- Riverpod 3.x 컨벤션: `@riverpod` 코드 생성, `Ref` 시그니처, `ref.onDispose` 누수
- GoRouter 라우트 계약: deep link, guard, redirect, type-safe route 일관성
- `Failure` sealed union 망라성 (exhaustive switch), `Result<T>` typedef 사용 주의사항
- `AsyncValueView` 기본 폴백 + 에러 UI 분기 일관성
- `Error.throwWithStackTrace` 패턴 일관 적용 여부
- 로거: 프로덕션 빌드 민감 정보 필터링, log level 정책
- DI 그래프 순환 참조: ProviderScope 오버라이드 정합성
- Hive box 초기화 순서 (links, collections, notifications, settings, search_history)
- 테마: Material 3 light/dark, `withValues(alpha:)` 최신 API 일관성

#### Stage C: 2차 의견 (10~20분)
6. `/sc:codex --diff-review` — 세션 #12~#19 diff 표층 버그 스캔

#### Stage D: 통합 보고서 (10분)
7. `docs/code_review/2026-04-13_wave2_core.md` 생성
8. P0/P1/P2/P3 분류 + 파일:라인 인용 + 권장 픽스
9. `tasks/lessons.md`에 신규 교훈 추가 (있을 경우)

### 2. 보고서 PR

보고서 작성 완료 후:
1. `chore/wave2-review` 브랜치 생성
2. 보고서 + daily log + next_session_prompt 커밋
3. push → PR → CI green → merge (사용자 승인 후)

## 불변 원칙

- **코드 수정 금지** — 리뷰 웨이브는 읽기 전용. 모든 픽스는 별도 구현 세션에서.
- **git push는 사용자 명시 승인 필수**
- **Branch Protection 활성화 상태** — PR + CI green 경로 필수
- **`flutter analyze` 0 / `flutter test` 353+ GREEN** 유지

## 완료 기준

- [ ] Wave 2 보고서 `docs/code_review/2026-04-XX_wave2_core.md` 생성
- [ ] P0/P1 지적에 파일:라인 인용 + 재현 방법 + 권장 픽스 포함
- [ ] 보고서 PR — CI green + main 머지
- [ ] 메모리 업데이트: `project_code_review_roadmap.md`에 Wave 2 완료 기록

## 참조 문서

- **계획서**: `~/.claude/plans/resilient-imagining-starfish.md` (Wave 2 섹션)
- **Wave 1 보고서**: `docs/code_review/2026-04-12_wave1_security.md`
- **코드 리뷰 로드맵**: 메모리 `project_code_review_roadmap.md`
- **아키텍처 결정사항**: 메모리 `project_architecture.md`
- **Result 타입 주의사항**: 메모리 `feedback_result_type.md`
- **daily log**: `docs/daily_task_log/2026-04-13_session.md`

## 세션 경계

Wave 2 리뷰 + 보고서 PR까지. 픽스 구현은 별도 세션(Session 26)에서 진행.
```

---

## 참고: Session 24 요약 (2026-04-13)

### Session 24
1. Step 0: main `ac1dc64` HEAD, analyze 0, 353 tests GREEN 확인
2. `chore/session22-docs` 브랜치 생성, 8파일 staging (planning artifacts + docs)
3. 커밋 `dcefe32` — pre-commit 통과
4. Push → PR #4 생성 → CI 4 job ALL GREEN
5. PR #4 main 머지 (`07c13fe`)
6. Wave 2~6 로드맵 브리핑, Wave 2를 다음 세션 대상으로 확정
