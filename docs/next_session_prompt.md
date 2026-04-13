# 다음 세션 프롬프트

아래 내용을 그대로 붙여넣기해서 다음 세션을 시작하세요.

---

```
Session 24 — 세션 문서/아티팩트 PR + Wave 2~6 방향 결정

## 미션 한 줄

Session 20~22의 planning artifacts와 세션 문서를 PR B로 정리한 뒤, Wave 2~6 코드 리뷰 일정을 계획하거나 기능 개발(Phase 7)로 전환한다.

## 배경

Session 23(2026-04-13)에서 Session 19 URL launcher 미커밋 코드 15파일을 PR #3(`ac1dc64`)으로 main에 머지했다. Branch Protection이 main에 활성화되어 모든 변경은 feature branch → PR → CI green → merge 워크플로우를 따른다.

현재 상태:
- **main은 `ac1dc64`** (PR #3 머지, 353 tests GREEN, analyze 0)
- **작업트리에 미커밋 변경 3파일**: `.gitignore`, `docs/linknote_workflow.md`, `docs/next_session_prompt.md`
- **미커밋 planning artifacts**: `tasks/wave1_fix_research.md`, `tasks/wave1_fix_plan.md`, `tasks/lessons.md`, `docs/code_review/2026-04-12_wave1_security.md`, `docs/daily_task_log/2026-04-12_session.md`

## 가장 먼저 할 일 (순서 엄수)

### 0. 현재 상태 확인
```bash
git status
git log --oneline -5
flutter analyze
flutter test
```
- main 브랜치, `ac1dc64` HEAD 확인.
- 작업트리에 미커밋 변경 존재 확인.
- analyze 0 issues, test 353 GREEN 전제.

### 1. PR B — Planning artifacts + 세션 문서

Session 20~22의 읽기 전용 문서와 planning artifacts + Session 23 업데이트분.

**대상 파일**:
- `tasks/wave1_fix_research.md` (신규)
- `tasks/wave1_fix_plan.md` (신규)
- `tasks/lessons.md` (신규)
- `docs/code_review/2026-04-12_wave1_security.md` (신규)
- `docs/daily_task_log/2026-04-12_session.md` (업데이트)
- `docs/next_session_prompt.md` (업데이트)
- `docs/linknote_workflow.md` (업데이트)
- `.gitignore` (업데이트)

**절차**:
1. `git checkout -b chore/session22-docs` from main
2. 위 파일들 `git add` + 커밋 메시지: `docs: session 20-23 planning artifacts + daily log + workflow update`
3. push → PR → CI green → merge (사용자 승인 후)

### 2. Wave 2~6 방향 결정

PR B 머지 후:

1. 계획서 `~/.claude/plans/resilient-imagining-starfish.md`에서 Wave 2~6 로드맵 확인
2. Wave 2 범위를 다음 세션의 코드 리뷰 대상으로 선정
3. 또는 사용자가 기능 개발(Phase 7 체크리스트)을 우선하고 싶다면 그 방향으로 전환

## 불변 원칙

- **git push는 사용자 명시 승인 필수** (CLAUDE.md 전역 규칙)
- **Branch Protection 활성화 상태** — main 직접 push 불가. 반드시 PR + CI green 경로.
- **`flutter analyze` 0 / `flutter test` 353+ GREEN** 유지.

## 완료 기준

- [ ] PR B (docs/artifacts) — CI green + main 머지
- [ ] Wave 2~6 방향 결정 (코드 리뷰 계속 vs 기능 개발 전환)
- [ ] 메모리 업데이트: `project_code_review_roadmap.md`에 PR B 해시 기록

## 참조 문서

- **PR #3 머지**: 커밋 `ac1dc64` (Session 19 URL launcher fix)
- **PR #2 머지**: 커밋 `72ade27` (Wave 1 security fixes)
- **Wave 1 보고서**: `docs/code_review/2026-04-12_wave1_security.md`
- **계획서**: `~/.claude/plans/resilient-imagining-starfish.md` (Wave 1~6 전체 로드맵)
- **daily log**: `docs/daily_task_log/2026-04-12_session.md` Session 22-23 섹션
- **이전 보안 감사 이력**: 메모리 `project_code_review_roadmap.md`

## 세션 경계

Session 24의 기대 범위는 "문서 PR + 방향 결정"으로 가벼운 세션. 코드 리뷰(Wave 2)나 기능 개발을 시작하려면 새 세션(Session 25)으로 경계를 나눈다.
```

---

## 참고: Session 23 요약 (2026-04-13)

### Session 23
1. Step 0: main `72ade27` HEAD, analyze 0 issues, 353 tests GREEN 확인
2. `session19/url-launcher-fix` 브랜치 생성, Session 19 URL launcher 관련 15파일 선택적 staging
3. 커밋 `5dcb345` — pre-commit 체크 통과 (dart format + analyze + secrets scan)
4. Push → PR #3 생성 → CI 4 job ALL GREEN (Analyze 56s / Test 2m51s / Build 6m10s / Security Scan 18s)
5. PR #3 main 머지 (`ac1dc64`), 브랜치 자동 삭제
6. PR B (docs/artifacts)는 다음 세션으로 이월 결정
7. daily_task_log, next_session_prompt, memory 업데이트
