# 다음 세션 프롬프트

아래 내용을 그대로 붙여넣기해서 다음 세션을 시작하세요.

---

```
Session 58 — Sprint-3 머지 직후 Track D (Linux golden) / Track H (다크 모드 검증) / Track I (anti-pattern Cat C) / Phase 5 (Lock·Globe pill) 중 단일 트랙

## 미션 한 줄

Session 57 Track B+ (Sprint-3 LnLinkCard mini ReadingStats badge) Mode B PASS 75/80, 706→714 GREEN, AC 12/12, observed_followups 3건 동일 PR 흡수 머지 완료. F-Sprint2-1/-2/-3/-4 RESOLVED (Planner Self-Validation 강화 + Sprint-3 검증으로 closure). Session 58 은 사용자 합의 후 단일 트랙.

## 배경

**Session 57 (2026-05-14 → 2026-05-21) 결과** — Harness Sprint-3 풀 사이클:
- Phase 1 (사전 강화): `~/.claude/agents/harness-planner.md` 에 F-Sprint2-4 (ERROR `verified_canonical_evidence`) + F-Sprint2-3 (WARN silent-fallback async-throw widget test) jq 게이트 신설. 8 sanity 검증 통과.
- Phase 2 (Sprint-3 정식 사이클):
  - Planner: Confidence 92%, AC 10개, uncertainty 5.05, tier 2 final
  - Mode A R1: 8 concerns (3 HIGH wording-only) + 1 Impact Map gap
  - Mode A R2: confirm (8/8 verbatim 반영, AC 12개, 4 LOW Mode B 위임)
  - Generator: option_chosen=`extend_existing_compact_param`, 2 prod + 11 test, 706→713 GREEN
  - Mode B simplified: PASS 75/80 (94%), 5 dimension floor 모두 met, observed_followups 3건
- Phase 3 (PR 묶음): observed_followup 3건 흡수 (Padding(top:6) compact 분기 / Sprint-2 baseline regression test / Impact Map metadata 9→10). 706→714 GREEN.

**RESOLVED follow-ups** (이 PR 머지로):
- F-Sprint2-1 → AC-10 (silent-fallback semantics spec.md 명시)
- F-Sprint2-2 → Impact Map 10 transitive files (link_detail_screen_test.dart reuse-site 포함)
- F-Sprint2-3 → Planner WARN gate + Sprint-3 0 forbidden async-throw 검증
- F-Sprint2-4 → Planner ERROR gate + Sprint-3 R1 verified_canonical_evidence 100% 검증

**남은 follow-up** (`docs/harness-followups.md`):
- F3 (`_writeQueue identical()` dead code, low)
- F4 ~ F9 backlog
- Sprint-3 Hand-off Next Sprint Context Seed: (a) Linux golden / (b) Phase 5 Lock/Globe / (c) F7 perf gate

## 작업 범위 — 후보 트랙

### Track D — Linux golden 재생성 (Phase 4.5 alchemist 잔여)

- **규모**: 소
- **의존성**: 없음 (GitHub Actions workflow_dispatch)
- **가치**: Phase 4.5 머지(`61e5c5b`) 시 CI 가 `--exclude-tags golden` 임시 상태. Linux baseline 생성하면 CI 가 다시 golden 검증 가능. Sprint-3 의 mini badge 도 자동 보호 (zero-stats 미렌더 정책으로 회귀 위험 0).

### Track H — 다크 모드 추가 화면 실기기 검증 (Session 55 후속)

- **규모**: 소
- **의존성**: 실기기 또는 에뮬레이터
- **범위**: Search / Collection Detail / Login / Edit / Form / Skeleton 다크 모드 시각 회귀 zero 확인. Sprint-3 mini badge 의 ink3 톤 다크 가독성도 함께 확인.

### Track I — anti-pattern script Category C 추가

- **규모**: 소~중
- **의존성**: 없음
- **범위 후보**:
  - freezed nested toJson `explicitToJson: true` 누락 검출 (mechanical 검증 가능 시)
  - 누적 lesson 중 grep 검출 가능 패턴 추가
- **현실성**: Docs-only PR 금지 규칙에 따라 다음 실코드 PR 에 묶거나 단독 Track 으로 진행

### Track L — Phase 5 Lock·Globe pill (LnLinkCard._trailing)

- **규모**: 중~대
- **의존성**: `CollectionEntity` 에 `visibility` / `lockedAt` 필드 확장 (`lib/features/collection/domain/` 변경)
- **범위**: 공개/비공개 표시 + 잠금 상태 표시. LinkDetail 진입 차단 정책 결정 필요.
- **harness 사용**: 정식 Planner-Mode A-Generator-Mode B 사이클 권고 (Sprint-3 정합)

### Track F7 — O(n) read-aggregation perf gate

- **규모**: 소
- **의존성**: Sprint-1 datasource 변경 가능 (`forbidden_files` 정책 재확인 필요)
- **범위**: 500+ events/link 환경 시뮬레이션 + Hive read 시간 측정 + `lastReadAt` 별도 필드 저장 (events 리스트 walk 회피). F7 deferred 해소.
- **현실성**: 사용자 데이터 1000+ events/link 도달 전까진 benign. 보류 가능.

**기본 추천**:
- 우선순위 1: **D (Linux golden 재생성)** — CI golden 복원, 소규모
- 우선순위 2: **H (다크 모드 잔여 화면 검증)** — Session 55 + 57 보수적 follow-up
- 우선순위 3: **L (Phase 5 Lock·Globe pill)** — 다음 정식 sprint 진입 시

## 검증 절차

```bash
cd ~/AndroidStudioProjects/LinkNote
git checkout main && git pull --ff-only

# Track 선택 후 새 브랜치
git checkout -b <verify/...|sprint-N/...|harness/...>

# 푸시 전 강제 시퀀스 (Session 52~57 학습)
dart format lib/ test/
bash tool/check_anti_patterns.sh              # PASS (Session 56 게이트)
flutter analyze --fatal-warnings              # 0 issues
flutter test --reporter=failures-only         # 714+ GREEN
# 넷 다 통과 후에만 push

git push -u origin <branch>
gh pr create --base main --title "..." --body "..."
```

## 알려진 인접 이슈 (Session 58 무관, 별도 세션)

- **dev/staging Supabase URL DNS 실패** — Session 55 실기기 빌드 시 반복 (`jzcduhgatmbobevxjdhy.supabase.co` 호스트 lookup 실패).
- **Supabase RLS / FK 점검** — dashboard 액세스 별도 트랙
- **`StatefulShellRoute.indexedStack` 탭 전환 `logScreenView`** — `app_router.dart` NOTE 주석, 별도 세션
- **`CollectionEntity` 모델 확장** (visibility / color / emoji) — Track L 진입 시 함께 처리
```
