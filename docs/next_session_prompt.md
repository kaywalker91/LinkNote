# 다음 세션 프롬프트

아래 내용을 그대로 붙여넣기해서 다음 세션을 시작하세요.

---

```
Session 29 — Wave 3 P2 PR 생성 & Wave 4 진입

## 미션 한 줄

fix/wave3-p1 브랜치의 Wave 3 P2 수정 + 테스트 + CI 정리를 PR로 머지하고, Wave 4(Collection feature) 리뷰에 진입한다.

## 배경

Session 28에서:
- Wave 3 P2 8건 수정 완료 (OG cancel, UUID tag ID, URL sanitizer, dead branch 등)
- Provider 단위 테스트 3종 신규 + RemoteDataSource 보강
- CI lint 정리 2회 (dart format, directives_ordering, redundant args 등)
- `flutter analyze --fatal-warnings` PASS, 379 tests GREEN

현재 상태:
- **브랜치**: `fix/wave3-p1` (HEAD `87c3556`)
- **main HEAD**: `4ca3c96` (Wave 3 P1 PR#8 머지 후)
- **main에 없는 커밋**: bac508b (P2 + 테스트) + 518ca9a (format) + 87c3556 (lint)
- **Branch Protection 활성화** — PR + CI green 경로 필수

## 가장 먼저 할 일 (순서 엄수)

### 0. 상태 확인
```bash
cd ~/AndroidStudioProjects/LinkNote
git status && git log --oneline main..HEAD
flutter analyze --fatal-warnings
flutter test --reporter compact | tail -3
```

### 1. fix/wave3-p1 PR 생성 (사용자 승인 후)
- **base**: main, **head**: fix/wave3-p1
- 제목: `fix: Wave 3 P2 code review fixes (8 issues) + Provider/DataSource tests`
- 본문: Session 28 로그 요약 (`docs/daily_task_log/2026-04-14_session28.md`)
- CI green 대기 → 머지 (사용자 승인 후)

### 2. Wave 4 진입 — Collection feature 리뷰

**리뷰 범위**: `lib/features/collection/`

**리뷰 관점** (Wave 2/3과 동일):
- Clean Architecture 준수
- Result/Failure 에러 핸들링
- 리소스 관리
- 테스트 갭 (특히 Provider)

### 3. 보고서 작성
- `docs/review/wave4_collection_review.md` 생성
- P0~P3 분류 + 권장 픽스

### 4. PR
- `chore/wave4-review` 브랜치 생성
- 보고서 커밋 → PR (사용자 승인 후)

## 불변 원칙

- **git push는 사용자 명시 승인 필수**
- **Branch Protection 활성화 상태** — PR + CI green 경로 필수
- **`flutter analyze --fatal-warnings` 0 / 379+ tests GREEN** 유지
- Wave 4는 리뷰 보고서만 작성, **코드 수정은 Session 30에서**

## 완료 기준

- [ ] fix/wave3-p1 PR 생성 → CI green → 머지
- [ ] Collection feature 전수 리뷰
- [ ] `docs/review/wave4_collection_review.md` 작성
- [ ] Wave 4 리뷰 PR 생성 → CI green
- [ ] 메모리 업데이트 + Session 29 daily log

## 참조 문서

- **Wave 3 P1 로그**: `docs/daily_task_log/2026-04-13_session27.md`
- **Wave 3 P2 로그**: `docs/daily_task_log/2026-04-14_session28.md`
- **Wave 3 리뷰**: `docs/review/wave3_link_review.md`
- **Wave 2 리뷰**: `docs/code_review/2026-04-13_wave2_core.md`
- **아키텍처**: CLAUDE.md → Architecture 섹션

## CI 정리 교훈 (Session 28 lessons)

- `very_good_analysis`의 `directives_ordering`은 전체 import 알파벳순 (외부/프로젝트 그룹 구분 X, 빈 줄 금지)
- freezed `@Default([])` 필드에 `const []` 명시 금지 → `avoid_redundant_argument_values`
- supabase `.select()` 결과에 타입 어노테이션 금지 → `omit_local_variable_types`
- pre-commit은 `--fatal-warnings` 없이 통과하므로 CI 전에 `flutter analyze --fatal-warnings` 직접 검증

## 세션 경계

PR#9 머지 → Wave 4 리뷰 PR 생성까지. Wave 4 코드 수정은 Session 30에서.
```
