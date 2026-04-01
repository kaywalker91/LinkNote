# 코드 리뷰 프로세스

LinkNote 프로젝트의 4-Layer 코드 리뷰 시스템.

## 아키텍처 개요

```
[코드 작성]
     ↓
Layer 1: Pre-commit Hooks (로컬, 결정론적)
  → dart format 체크 → flutter analyze → 시크릿 탐지
     ↓
Layer 2: 로컬 AI 에이전트 검토 (커밋 전 선택적)
  → Claude Code에서 /feature-dev:code-reviewer 실행
     ↓
Layer 3: CI/CD 자동 검사 (PR 생성 시 자동)
  → GitHub Actions: analyze → test → build → security scan
     ↓
Layer 4: 사람의 최종 검토 (PR 머지 전)
  → PR 체크리스트 기반 아키텍처·비즈니스 로직 리뷰
```

---

## Layer 1: Pre-commit Hooks

**파일:** `.git/hooks/pre-commit`

커밋 시 자동 실행됩니다.

| 검사 | 실패 조건 | 해결 방법 |
|------|----------|----------|
| dart format | 포맷 불일치 | `dart format lib/` |
| flutter analyze | 린트 오류 | 오류 내용 확인 후 수정 |
| 시크릿 탐지 | API 키 패턴 감지 | envied로 환경변수 처리 |

**훅 우회 (긴급 시에만):**
```bash
git commit --no-verify -m "emergency fix"
```
> 우회 후 반드시 이슈를 기록하고 다음 커밋에서 해결할 것.

---

## Layer 2: 로컬 AI 에이전트 검토

**트리거:** Dart 파일 편집 후 Claude Code가 리마인더 출력

**수동 실행:**
```
/feature-dev:code-reviewer
```

**검토 항목:**
- 비즈니스 로직 버그 및 논리 오류
- Riverpod 패턴 준수 (`@riverpod` annotation 사용)
- Clean Architecture 레이어 경계 위반
- 보안 취약점 (하드코딩된 값, 미검증 입력)
- 성능 이슈 (불필요한 rebuild, Widget 트리 낭비)

---

## Layer 3: GitHub Actions CI

**파일:** `.github/workflows/ci.yml`

PR 생성/업데이트 시 자동 실행됩니다.

### Jobs

| Job | 목적 | 실패 시 |
|-----|------|--------|
| `analyze` | dart format + flutter analyze | 머지 불가 |
| `test` | flutter test + coverage 측정 | 머지 불가 |
| `build` | Android APK 빌드 검증 | 머지 불가 |
| `security` | Semgrep + 시크릿 스캔 | 경고 (soft fail) |

### 커버리지 목표

| 레이어 | 목표 |
|--------|------|
| Domain (UseCase, Entity) | ≥ 80% |
| Data (Repository, DataSource) | ≥ 80% |
| Presentation (Provider, Widget) | ≥ 70% |

### Semgrep 설정 (선택)

GitHub Actions의 `SEMGREP_APP_TOKEN` 시크릿을 설정하면 더 상세한 보안 리포트를 받을 수 있습니다.
미설정 시에도 기본 시크릿 탐지는 실행됩니다.

---

## Layer 4: 사람의 최종 검토

**파일:** `.github/pull_request_template.md`

PR 생성 시 체크리스트가 자동으로 나타납니다.

### 필수 사람 리뷰 항목

다음에 해당하는 변경은 반드시 사람이 직접 검토합니다:

- **인증/인가 변경** — 보안 흐름에 영향
- **데이터베이스 스키마 변경** — 마이그레이션 필요 여부
- **외부 API 연동 변경** — 사이드 이펙트 범위

---

## 업계 벤치마크 참고

| 지표 | 수치 | 출처 |
|------|------|------|
| AI 생성 코드 취약점 | 1 in 3 스니펫에 취약점 | Veracode 2024 |
| 자동화 도입 후 버그 감소 | 62% | Qodo State of AI Code Quality |
| PR 머지 시간 단축 | 32% | Graphite 분석 |
| CodeRabbit 버그 탐지율 | 46% | CodeRabbit 2025 |

---

## 로컬 설정 확인

```bash
# pre-commit hook 실행 가능 여부 확인
ls -la .git/hooks/pre-commit

# 수동으로 pre-commit hook 테스트
.git/hooks/pre-commit

# flutter analyze 직접 실행
flutter analyze

# 테스트 + 커버리지 실행
flutter test --coverage
```
