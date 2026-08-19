# LinkNote 개선 처방 — 회고록 후속

**작성일** 2026-08-19
**선행 문서** [`2026-08-19-development-retrospective.md`](./2026-08-19-development-retrospective.md)
**작성 방식** 회고록 + 저장소 통제 수단 인벤토리를 브리프로 만들어 **Grok · Codex · Antigravity(agy)** 에 2라운드 교차 논의 — R1 독립 처방 → R2에서 서로의 답을 공개하고 "틀렸거나 위험한 제안을 지목하라"고 요구. 제기된 주장은 전부 저장소에서 직접 실측해 검증했다.

> 회고록이 "무엇이 있었나"라면 이 문서는 "그래서 무엇을 할 것인가"다. 파일·라인·수치는 2026-08-19 기준 실측이다.

---

## 0. 이 논의가 실제로 한 일

교차 논의의 값어치는 합의문이 아니라 **오답 제거**였다. R1 처방 중 상당수가 R2에서 철회되거나 실측으로 뒤집혔다.

**모델 스스로 철회한 것**
- agy·codex 모두 "포트폴리오 문서의 대외 리스크 대응"을 철회 — 해당 폴더는 `.gitignore` 대상이라 공개된 적이 없다.
- codex가 자신의 "새 `docs/release/device-regression.md` 생성"을 철회 — 같은 목적의 체크리스트가 이미 2종 있다.
- codex가 "public-collection을 pending+bootstrap/listener로 재설계(2일)"를 **0.75일 이동 작업으로 하향** — 수정 방법이 이미 코드 주석에 적혀 있다.

**서로가 잡아낸 것**
- grok의 "CI에서 훅을 `grep`으로 잠그자" → codex: 주석·미실행 분기에 문자열만 있어도 통과한다. **기각.**
- agy의 "AAB를 `strings`/`apktool`로 열어 env 값 grep" → codex: envied 난독화로 평문이 없어 오판한다. **실측 확인 — `env_*.g.dart` 3종 모두 XOR 바이트 배열. 기각.**
- codex의 "공유 스크립트에 `flutter analyze` 포함" → grok: 훅은 `--fatal-infos`, CI는 `--fatal-warnings`다. **실측 확인. 기각.**
- agy의 "`enforce_admins: true`가 가장 중요한 처방" → grok·codex 모두 반대. **아래 7장에서 데이터로 판정.**

**내가 틀렸던 것**
- 나는 "PR 템플릿이 없다"고 확인했으나 **오류였다** (zsh glob 에러로 명령이 중단된 결과를 "없음"으로 읽음). `.github/pull_request_template.md`는 존재하며, 이 사실이 아래 1.1의 발견을 더 강하게 만든다.

---

## 1. 논의가 뒤집은 사실 5가지

### 1.1 ★ 검증 시퀀스가 5곳에 4가지 다른 정의로 존재한다

두 번 재발한 CI format 실패(Session 38 PR #18, Session 52 PR #35)에 대해 이 프로젝트는 ① `lessons.md`에 교훈 기록 ② CI에 게이트 추가 를 했다. 그런데 **③ 사람과 에이전트가 실제로 읽고 따르는 "완료의 정의"는 두 번의 실패 이후에도 그대로다.**

| # | 위치 | format | analyze | anti-pattern |
|---|---|---|---|---|
| 1 | `.git/hooks/pre-commit:14` (**미추적**) | `lib/` **만** | `--no-pub --fatal-infos` | **없음** |
| 2 | `.github/workflows/ci.yml:33,39` | `lib/ test/` | `--fatal-warnings` | 있음 |
| 3 | `docs/ai-guidelines.md:11-15` (**AI 규칙 정본**, `:15`가 "완료 선언 전" 기준 정의) | **없음** | 플래그 없음 | **없음** |
| 4 | `CLAUDE.md:21,24` / `AGENTS.md:9-10` (Claude·Codex 진입점) | **없음** | 플래그 없음 | **없음** |
| 5 | `.github/pull_request_template.md` (수동 체크박스) | "적용됨" | "경고 없음" | **없음** |

같은 명령이 다섯 곳에 복제됐고, format 범위는 2가지, analyze 플래그는 3가지, anti-pattern은 **1곳에만** 있다.

두 번의 실패가 **둘 다 `test/` 파일 포맷**이었다는 점이 핵심이다. 훅은 `lib/`만 본다 — **재발을 막으라고 만든 게이트가 정확히 그 재발 케이스를 통과시키며 초록불을 준다.** 그리고 훅은 이미 analyze를 돌리고도 그걸 놓쳤으므로, **부족한 검사는 analyze가 아니다.**

추가로 `docs/code-review-process.md:27`은 훅 경로를 `.git/hooks/pre-commit`(버전 관리 안 되는 경로)으로 명시해 그 드리프트를 공식 절차로 고정한다.

> 회고록 5장의 "잘못된 프록시를 불변조건으로 일반화했다"가 **문서화된 형태로 저장소에 박혀 있다.** grok만 `AGENTS.md`를 짚었고, codex가 "정본은 `ai-guidelines.md`이고 `CLAUDE.md`도 별도 진입점"이라고 확장했으며, grok이 R2에서 "내 R1은 반쪽이었다"며 이를 수용했다.

### 1.2 ★ 컬렉션 피커 20개 한계는 미구현이 아니라 **배선 누락**이다

세 모델이 R1에서 비용을 1~1.5일로 잡고 "페이지네이션 상태를 새로 추가"하자고 했다. 실측 결과 **이미 다 있다.**

```
collection_list_provider.dart:32   Future<void> loadMore()
                            :34   hasMore / isLoadingMore 가드
                            :48   loadMoreError
collection_list_screen.dart:53     ← 같은 provider에 loadMore() 이미 배선됨
collection_picker_sheet.dart       ← loadMore/hasMore/ScrollController 호출 0건
```

provider는 페이지네이션을 완전히 지원하고, 컬렉션 탭 화면은 이미 쓰며, **피커 시트만 안 쓴다.** 수정은 `collection_list_screen.dart:53`의 기존 배선을 시트로 복사하는 일이다.

> 이건 **PR #73과 정확히 같은 패턴의 재발**이다 — 당시에도 `LinkFormState.collectionId → submit() → LinkEntity` 경로와 테스트가 다 있는데 `updateCollectionId()`를 호출하는 UI만 없었다. **도메인/데이터가 앞서고 UI 배선이 뒤처지는 것이 이 코드베이스의 재현되는 결함 클래스다.**

### 1.3 ★ public-collection race의 수정 방법이 코드 주석에 이미 적혀 있다

`lib/app/router/app_router.dart:76-90` 실측:

- `:79` — redirect **안에서** `ref.read(pendingPublicCollectionProvider.notifier).consume()` 호출 중
- 바로 아래 share-intent 주석이 "Do NOT consume here"를 설명하며:
  > *"(pendingPublic above has the same latent race — a rarer cold deep-link path; **fix it the same way when that screen gains an init hook**.)"*
- 올바른 패턴은 `link_add_screen.dart:40-48` — `addPostFrameCallback` 안에서 `mounted` 확인 후 consume

**남은 실제 작업량**: `PublicCollectionDetailScreen`은 `ConsumerWidget`(stateless, `:24`)이라 init 훅이 없다. `ConsumerStatefulWidget` 전환이 일의 전부다. codex는 R1의 "2일"을 R2에서 **0.75일**로, grok은 **1일**로 산정했다.

### 1.4 레이아웃 예약 구멍은 `LnTopBar`에서 이미 닫혔다

agy·codex가 R1에서 "geometry 테스트를 추가하자"고 했으나 이미 있다.

```
test/shared/widgets/ln/ln_top_bar_test.dart:25  expect(bar.preferredSize.height, 56 + 92);
                                          :63  expect(tester.getSize(find.byType(LnTopBar)).height, 56);
```

PR #68의 교훈(좌표 단언 필수)이 테스트로 고정돼 있다. 남는 것은 이 패턴을 다른 `PreferredSizeWidget`으로 확산할지이며, grok의 판정 — "전 화면 일반 게이트는 만들지 말고 리뷰 질문 한 줄로" — 이 이 프로젝트의 골든 이력(Skia 차이로 한 번 해제)과 일관된다.

### 1.5 로컬 포트폴리오 문서 팩은 대외 리스크가 아니다

`docs/work_performance/`는 `.gitignore:61` "# Private docs"에 등록돼 커밋된 적이 없고 GitHub·`site/` 어디에도 노출되지 않는다. 공개 표면인 `site/`·README는 8월에 실측값으로 정정됐다(`c14504d`).

**agy·codex 모두 R2에서 이 항목의 심각도 평가를 철회했다.** 남는 실질 문제는 `06_growth_and_reflection.md:55`가 Hive 암호화를 코드(`storage_service.dart:17`, `HiveAesCipher`)와 **반대로** 기술한다는 것 하나뿐이며, 다음 이력서 준비의 입력으로 재사용될 때만 밖으로 나간다. 우선순위 최하.

---

## 2. 그대로 가져갈 자산 (3/3 합의)

| 자산 | 재사용 형태 | 근거 |
|---|---|---|
| `tool/check_anti_patterns.sh` + CI 강제 | 새 스크립트를 만들지 말고 **이 파일에 카테고리 함수 추가**. 현재 A(AppColors)/B(`on Exception catch`)/C(`Failure.message` raw exception) | `on Exception catch`가 Session 28·41 두 번의 수동 sweep 뒤에도 34곳까지 재증식했고, 스크립트+CI 승격 후에야 끊겼다 |
| Session 56의 risk-profile PR 분할 | 인프라(게이트) → semantic(일괄 치환) → behavior(동작). 앞 PR이 뒤 PR을 검사 | #39의 게이트가 #40의 sweep 결과를 ENFORCE. 회귀 추적 단위가 커밋이 아니라 리스크 종류가 됨 |
| 구현 전 가정 검증 | 리뷰 소견은 SDK 소스·`gh api`·기존 코드로 먼저 깨보고 뒤집힌 항목만 구현. 템플릿 `tasks/wave1_fix_research.md` | Wave 1에서 `userDeleted`/`allowBackup`/브랜치 보호 3건의 방향이 구현 전에 뒤집힘 |
| 진단 우선 + `UrlSanitizer` 3계층 | 공유·딥링크 결함에 로그 없는 추정 패치를 열지 않는다 | analyze와 714 테스트가 통과시킨 클래스를 실기기 로그 한 번이 끝냄 (Session 18→19) |
| consume-on-arrival 패턴 | `link_add_screen.dart:40-48`을 **복사**. 새 프레임워크 아님 | 공유 인텐트 P0의 근본 수정. public-collection에 그대로 적용 가능(1.3) |
| `next-session-prompt.md` + 세션 로그 | 상단 최신 블록만 읽고 하단 stale 백업은 무시하는 인계 파일 | 커밋 45%가 주말·29%가 심야, 최장 공백 13일 |
| **"같은 실수 2회 → 실행 게이트로 승격" 규칙** | 승격 대상은 CI만이 아니라 **완료의 정의**까지 (1.1이 그 빈칸) | codex가 일반화했고 grok이 R2에서 "내가 놓쳤다"며 채택 |

**가져가지 말 것** (3/3 합의): Planner–Generator–Evaluator를 **기본 개발 경로로 삼기**(선택 도구로만 남긴다 — 자산 목록에 올리면 다음 기능에서 기본값으로 되살아난다는 grok 지적 반영), 테스트 개수를 품질 프록시로 쓰기, `docs/work_performance/`의 수치.

---

## 3. 보완 항목 (심각도 순)

### P1. 검증 시퀀스가 5곳에 복제돼 서로 다르다 (1.1)

**처방** — 갭들은 별개가 아니라 **원본이 없어서 생긴 하나의 결함**이다. 훅에 `test/`만 추가하면 다음 달에 또 갈라진다. **검사 명령을 한 곳에만 적는다.**

1. `tool/static_checks.sh` 신설 — `dart format --set-exit-if-changed lib/ test/` + `bash tool/check_anti_patterns.sh`
   > **`flutter analyze`는 넣지 않는다.** 훅은 `--fatal-infos`, CI는 `--fatal-warnings`로 이미 다르고(실측), 합치면 둘 중 하나를 깨거나 매 커밋에 전체 analyze 비용을 얹는다. 재발 2건의 원인은 analyze 부재가 아니다 — **훅은 analyze를 돌리고도 `test/` format을 놓쳤다.**
2. `.git/hooks/pre-commit` → **`tool/git-hooks/pre-commit`으로 옮겨 커밋.** 인라인 검사는 `bash tool/static_checks.sh` 호출로 교체(secrets 스캔·analyze는 훅에 유지)
3. `tool/install-hooks.sh` — `git config core.hooksPath tool/git-hooks` 한 줄
   > agy의 "`.git/hooks/`에 심링크" 안은 **채택하지 않는다.** 훅이 다시 미추적 경로에 떨어져 `code-review-process.md:27`이 고정한 바로 그 버그를 재생산한다(grok).
4. `ci.yml`의 format step과 anti-pattern step을 `bash tool/static_checks.sh` **한 호출**로 교체. analyze step은 유지
5. **지시문·템플릿 정렬** — `docs/ai-guidelines.md`(정본), `CLAUDE.md`, `AGENTS.md`의 완료 기준을 `bash tool/static_checks.sh` exit 0 + `flutter analyze` + 관련 테스트로 통일. `.github/pull_request_template.md`의 "기타" 체크박스도 같은 문구로. `docs/code-review-process.md:27`의 훅 경로 정정

**검증** — 포맷이 깨진 `test/` 픽스처와 금지 패턴을 각각 넣고 **훅과 CI가 같은 검사에서 실패**해야 한다. 새 클론에서 설치 후 `git config --get core.hooksPath`가 `tool/git-hooks`인지 확인. 검사 명령 원문이 CI·훅 어디에도 중복되지 않아야 한다.

### P2. public-collection redirect가 아직 순수하지 않다 (1.3)

**결함** refreshListenable 다중 펄스에서 첫 평가가 소비하고 이후 splash 평가가 null을 보고 home으로 떨어뜨린다. 내부테스트 빌드(1.1.7+15)에 포함된 상태이며 북마크 앱의 공유 수신 루프다.
**처방** redirect에서 `consume()` 삭제 → 경로만 반환. `PublicCollectionDetailScreen`을 `ConsumerStatefulWidget`으로 전환해 `link_add_screen.dart:40-48` 패턴대로 post-frame 소비. **새 상태·리스너·부트스트랩 계층을 만들지 않는다**(codex R1 안은 R2에서 철회).
**검증** 단위 — redirect를 두 번 평가해도 pending이 유지되고 목적지가 public 상세. 실기기(A34) — 로그아웃 상태에서 `linknote://collections/public/<id>` 콜드 스타트 → 로그인 → 읽기전용 상세. **home 착륙이면 실패.**

### P3. 릴리스 체크리스트가 존재하지만 두 달째 닫히지 않았다

**현재** 실기기 QA 체크리스트가 **이미 2종** — `play-release-execution-guide.md` §5(10항목), `release-checklist.md` §2(2026-06-21 실측 기록). 문서 전체 미체크 `- [ ]` 13개.
**결함** 목록의 부재가 아니라 **실행의 부재**다. §2 "잔여" 5건이 2026-06-21 이후 미체크이고, 그중 2건은 **공개 컬렉션 비소유자 왕복(RLS private 누출 0 확인)** 과 **읽기통계 증가 경로** — 보안·핵심 기능 검증이다. 그 사이 1.1.6+12/+13, 1.1.7+15가 내부테스트에 올라갔다.
**처방** 새 문서를 만들지 않는다(codex 자진 철회). 기존 2종 중 하나를 **실행 정본**으로 지정하고 잔여 5건을 현재 prod 후보에서 실행. 판정을 기록이 아니라 **업로드 차단 조건**으로 — *하나라도 미체크면 내부테스트에 올리지 않는다.* DebugView·Crashlytics처럼 콘솔 대기가 필요한 항목은 날짜만 적고 90일로 넘긴다.
**검증** 다음 두 release candidate에서 같은 체크리스트가 기기·OS·빌드 SHA·실행일과 함께 채워졌는지, 실패 항목이 있는 후보가 업로드되지 않았는지 릴리스 기록과 대조.

### P4. 릴리스 검증이 "빌드 성공"에서 끝난다

**현재** envied placeholder가 prod AAB에 박힌 사고 2회. `env_dev/staging/prod.g.dart` 모두 XOR 난독화 바이트 배열이라 **평문 grep으로 탐지 불가**(실측).
**처방** (새 스크립트를 만들지 않는다 — codex의 `verify_release_artifact.sh` 2일 안은 grok 반박으로 축소)
- **소스층 (자동)**: 생성된 env 값을 디코드해 **placeholder/도메인 shape만** 단언하는 테스트. **값 출력 금지.** — 과거 임시 테스트는 **커밋된 적 없다**(`git log --diff-filter=D` 0건). 신규 작성이다.
- **동일성 (기존 자산 활용)**: `release-checklist.md`에 **AAB 무결성 SHA-256 칸이 이미 있다**(§ 주석에 "업로드본 대조용"으로 명시). 리허설한 바이너리와 업로드한 바이너리가 같음을 이 칸으로 묶는다. 새 스크립트 불필요.
- **인간층**: 그 산출물을 설치 → 로그인 → 세션 복원 → 핵심 경로 1개
- **문서 한 줄**: `release-checklist.md` §2가 기록한 2차 근본원인을 릴리스 절차에 박는다 — envied가 `.env` 변경을 build_runner 입력으로 추적하지 못해 `--delete-conflicting-outputs`만으로는 캐시가 재사용되므로 **`dart run build_runner clean`이 필수**. prod는 실키 커밋으로 우회했지만 **dev/staging에는 함정이 그대로 남아 있다.**

**검증** 의도적으로 placeholder를 넣으면 소스층 테스트가 실패해야 한다. 릴리스 정의를 **"빌드 성공"이 아니라 "설치 후 로그인 성공"** 으로 고정.

### P5. 컬렉션 피커 20개 한계 (1.2) — 조건부

**현재** provider에 `loadMore()` 완비, 컬렉션 탭은 이미 사용, 피커 시트만 미배선.
**결함** 21번째 이후 컬렉션을 **선택할 수 없다**. 편집 모드에서 첫 페이지 밖 컬렉션은 라벨이 `선택한 컬렉션`으로 표시된다(값은 유지·저장).
**처방** 7장 쟁점 1의 판정에 따른다 — 21개 이상 보유 시 기존 배선 복사(≈0.5일), 아니면 `hasMore` 안내 한 줄(≈0.25일). codex 지적대로 안내로 갈 경우 **"최근 20개"라는 문구는 정렬 기준을 확인하기 전엔 쓰지 말 것.**

### P6. Hive 암호화 오기 (최하)

`06_growth_and_reflection.md:55` 한 줄 정정 + 파일 상단 스냅샷 일자 표기. 이력서 준비 직전에.

---

## 4. 만들어야 할 통제 — 자동화 가능/불가 판정

세 모델이 R2에서 수렴한 판정. **자동화 불가를 자동화하자는 제안은 전부 기각됐다.**

| 층 | 판정 | 통제 |
|---|---|---|
| 정적 검사 (format·anti-pattern) | **완전 자동화** | P1의 `tool/static_checks.sh` 단일 원본. analyze는 별도 유지 |
| 라우팅 순수성 | **대부분 자동화** | redirect를 입력→경로 순수 함수로 분리해 단위 테스트. 같은 입력 2회 평가 시 상태 불변 단언. `check_anti_patterns.sh` Category D 승격은 **같은 실수가 한 번 더 난 뒤에**(현재는 `consume()` 한 패턴에 과적합 위험) |
| 릴리스 바이너리 | **부분 자동화** | 자동: env shape 테스트. 기존 자산: AAB SHA-256 칸. 불가: 설치 후 실제 로그인 |
| 레이아웃 예약 | **이미 일부 적용** | `ln_top_bar_test.dart` 높이 단언 패턴 복사. 전 화면 일반 게이트·골든 증설은 하지 않는다 |
| 실기기 경로 | **자동화 불가** | 공유 시트 페이로드, 콜드 딥링크, 외부 앱 VIEW/SEND, 설치본 로그인. 새 디바이스 팜·프레임워크 금지, **기존 체크리스트를 실행 정본으로**(P3) |
| 문서 정합성 | **의미적 주장은 불가** | 수치 생성 파이프라인은 로컬 전용 팩에 과투자(codex 안 기각). 기준일·근거 파일을 요구하는 인간 리뷰로 |

**자동화하지 않기로 한 인간 절차** (릴리스마다 동일 순서):
AAB SHA-256 기록 → 동일 산출물 설치 → 신규 로그인 → 재시작 후 세션 복원 → 외부 앱에서 공유 저장 → 프로세스 종료 상태 딥링크 → 서버에서 저장 결과 확인 → 실행자·기기·OS·시각 기록.

---

## 5. 30일 계획

**제약** 1인 개발, 주말·야간 중심, 월 가용 약 9일(회고록 4.1 실측 페이스).
**원칙** 새 도구·새 문서·새 프레임워크를 만들지 않는다. 이미 있는 것을 하나로 묶고, 열린 것을 닫는다.

| # | 작업 | 예상 | 이걸 안 하면 |
|---|---|---:|---|
| 1 | **public-collection consume 이동** — `ConsumerStatefulWidget` 전환 + 이중 펄스 테스트 + A34 콜드 딥링크 1회 (P2) | 1.0일 | 1.1.7+15에 들어간 콜드 딥링크가 로그인 후 홈으로 유실된다. 북마크 앱의 수신 루프다 |
| 2 | **검증 시퀀스 단일화** — `tool/static_checks.sh` + 추적 훅 + CI 한 호출 + **지시문 3종·PR 템플릿·`code-review-process.md` 정렬** (P1) | 1.5일 | 다음 에이전트 PR이 Session 38·52처럼 `test/` 포맷으로 CI에서 죽는다. 1번 픽스가 그 구멍에 걸린다 |
| 3 | **피커** — 쟁점 1 판정에 따라 배선 복사 또는 안내 한 줄 (P5) | 0.25~0.5일 | 21번째 이후 컬렉션을 못 고르는 것을 테스터가 고장으로 본다 |
| 4 | **릴리스 잔여 5건 + §5 실행** — RLS private 누출 0, 읽기통계 +1, 공유 "제목+URL", 콜드 딥링크, prod AAB 로그인. 설치·업로드 AAB SHA를 같은 칸에 기록. **미체크면 업로드 금지** (P3) | 3.5~4.0일 | RLS·읽기통계가 또 미확인인 채로 다음 내부테스트가 나간다. +12/+13/+15가 그 경로다 |
| 5 | **env placeholder 테스트** + 릴리스 문서에 `build_runner clean` 함정 한 줄 (P4) | 0.5일 | flavor를 `build_runner`만 돌리면 세 번째 placeholder AAB가 나온다. CI는 또 초록이다 |

**합계 6.75~7.5일 / 버퍼 1.5~2.25일.** 버퍼는 4번에서 나온 버그 수정에만 쓴다. **6번째 트랙을 열지 않는다.**

**30일에서 명시적으로 제외**: iOS, `docs/work_performance/` 갱신(P6는 버퍼 여유 시 한 줄만), `enforce_admins`(쟁점 2), 골든 증설, AAB 스캐너 신설, 새 QA 문서, lefthook/pre-push, 훅에 analyze 추가, 커버리지 상향, 하네스 재가동, 알림 재도입.

---

## 6. 90일 (그다음 약 18~27일)

1. **내부테스트 피드백 한 사이클을 닫는다.** 새 기능 후보(warm share 시트, 피커 loadMore 등)는 **테스터가 실제로 막힌 것만** 연다.
2. **DebugView·Crashlytics 등 콘솔 대기 항목** 마무리 (30일에서 이월).
3. **redirect 계약 테스트 확산** — P2와 같은 순수성 계약을 나머지 라우팅 분기에. Category D 승격은 같은 실수가 한 번 더 났을 때.
4. **자동화 가능한 앱 내부 경로만** `integration_test/`로 (현재 디렉터리 없음). 실기기 검증을 대체한다고 선언하지 않는다.
5. **iOS 경계 확정 spike** — 쟁점 3의 형태로, 1일.
6. `site/` 수치만 실측 유지. `work_performance/`는 스냅샷 동결.

---

## 7. 끝내 갈린 쟁점 — 결정 기준

### 쟁점 1. 피커 — 지금 `loadMore` 배선(codex) vs 한계 명시(grok, agy 폴백)

내 실측은 codex 쪽을 지지한다 — 구현이 `collection_list_screen.dart:53` 복사라 안내 문구보다 별로 비싸지 않다. grok의 반론은 **9일 예산에서 0.5일도 잔여 QA(RLS·읽기통계)를 밀어낸다**는 것이고, 이 프로젝트가 두 달간 그 QA를 못 닫았다는 사실이 그 반론을 뒷받침한다.

> **결정 기준 (grok 제안, 사용자만 확인 가능)**: **지금 prod 계정에 컬렉션이 21개 이상 있는가.**
> 있으면 pagination이 제품 결함이므로 배선(0.5일). 없으면 안내 한 줄(0.25일)로 두고, 테스터가 실제로 그 한계에 부딪힌 뒤 연다.

### 쟁점 2. `enforce_admins: true`를 켤 것인가 — **데이터로 판정 가능**

| | 입장 |
|---|---|
| **agy** | 켠다. "게이트를 우회할 뒷문이 열려 있는 한 어떤 자동화도 결정적 순간에 무력화된다" |
| **codex** | 아직 아니다. "이번 재발의 직접 원인은 관리자 우회가 아니라 불완전한 완료 기준이다. 긴급 복구까지 막는다" |
| **grok** | 켜지 않는다. "`enforce_admins: false`는 Wave 1 사전 검증의 명시적 선택(긴급 머지 경로)이다. format 재발 2건은 bypass가 아니라 **푸시 후 CI가 잡은 것**" |

grok이 제시한 판정 기준은 측정 가능해서 **내가 직접 확인했다.**

> **머지된 74개 PR 전부에 대해 head 커밋의 check-run 결론을 조회한 결과, 실패(failure/timed_out/cancelled) 체크를 안고 머지된 PR은 0건이다.**

이 0이 두 방향으로 읽힌다는 점이 이 쟁점의 본질이다.
- grok의 기준 문장대로면 — *"0이면 true는 공짜 보험이다"* — 켜는 쪽이다. (다만 grok의 최종 권고는 "켜지 않음"이라 자기 기준과 어긋난다.)
- codex 기준으로는 — 우회 이력이 없으므로 **지금 고칠 문제가 아니다.**

**세 모델과 데이터가 함께 지지하는 결론은 하나뿐이다: 이건 30일 우선순위가 아니다.** 실제 재발 원인은 1.1의 복제된 완료 정의이지 admin 우회가 아니었다. 켜는 것 자체는 클릭 한 번이고 현재 이력상 잃을 게 없으므로, **P1을 끝낸 뒤 켜고 싶으면 켜라 — 다만 그것이 무언가를 고쳤다고 세지는 말 것.**

### 쟁점 3. iOS spike의 시점과 산출물

R1에서 갈렸고(agy: 지금 / codex: 90일 1일 / grok: 90일 이후), **iPhone 실기기가 없다는 제약을 알고 나서 agy가 자기 입장을 수정했다** — "빌드 성공 = 배포 성공이라는 거짓 신호를 안드로이드 때와 똑같이 낳는다."

**수렴된 형태: 30일 제외, 90일에 1일, 산출물은 "iOS 검증 완료"가 아니라 경계표.**

| 시뮬레이터로 확인 가능 | 정적으로만 확인 | **확인 불가 — `UNKNOWN`으로 남길 것** |
|---|---|---|
| 컴파일, 앱 부팅, 기본 화면 렌더, Dart 레벨 딥링크 처리, plugin 등록 오류 | entitlement, URL scheme, Share Extension 구성 | 실기기 공유 시트 페이로드, 실제 cold-start lifecycle, 서명·설치, TestFlight, universal link 종단 동작 |

Phase 8 진입 판단에는 **기기 확보 또는 TestFlight 협력자 계획**이 선결 조건으로 들어가야 한다. 이 프로젝트에서 실제로 터진 결함 대부분이 오른쪽 열의 클래스였다.

### 쟁점 4. 실기기 QA를 PR 템플릿으로 강제할 것인가

agy는 "이미 안 읽는 문서에 항목을 추가해봐야 똑같이 방치된다"며 `.github/pull_request_template.md`(이미 존재)에 실기기 체크를 넣자고 했다. grok의 반론 — **"매 PR에 실기기 QA를 걸면 월 9일이 그 칸을 채우다 끝난다"** — 이고, 실제로 이 저장소의 PR 대부분은 릴리스가 아니다.

**절충** (양쪽 논거를 모두 만족): PR 템플릿에는 **"이 변경이 릴리스 후보인가" 한 줄만** 두고, 예이면 기존 체크리스트를 여는 형태. 매 PR 부담 없이 릴리스 경로만 강제된다. 미체크 13개가 방치됐다는 사실은 agy 쪽 증거이므로, 이 한 줄은 P1의 템플릿 정렬 작업에 얹는다.

---

## 8. 다음 프로젝트 첫날에 세팅할 것

세 모델이 "일반화 가능"으로 분류한 것만.

1. **검사 명령은 추적되는 스크립트 한 곳에만 적는다.** `core.hooksPath` + CI가 그 스크립트를 호출. format 범위를 훅과 CI에 따로 적지 않는다. **플래그가 갈리는 검사(analyze)는 억지로 합치지 말고 어디가 정본인지만 정한다.**
2. **빈 `check_anti_patterns.sh`를 첫 커밋에 넣는다.** 내용은 비어 있어도 호출 경로는 첫날부터 CI에 있다.
3. **"완료의 정의"를 에이전트 지시문에 정확히 적는다.** 이 프로젝트의 두 번째 CI 실패는 지시문이 불완전해서 났다.
4. **릴리스 DoD를 "빌드 성공"이 아니라 "설치 후 핵심 경로 1개 성공"으로 한 줄 적는다.**
5. **실제 불변조건 목록을 먼저 쓴다.** "빌드 성공", "요소 없음(`findsNothing`)", "테스트 GREEN" 같은 프록시 대신 최종 산출물·상태 전이·좌표·외부 연동 결과를 무엇으로 검증할지 기록한다.
6. **간헐적 작업용 인계 파일 하나.** 주말·야간 프로젝트라면 첫날에.
7. **한 PR에 게이트 신설·일괄 치환·동작 변경을 섞지 않는다는 규칙 한 줄.**
8. **자동화 경계를 명시한다.** 실기기·외부 앱·스토어·인증 서버는 첫 릴리스 전부터 고정된 인간 체크리스트로.

**첫날에 하지 말 것**: 멀티에이전트 하네스, 커버리지 숫자 목표, 포트폴리오 문서 팩, 골든 테스트를 플랫폼 무관 진실로 취급하기.

---

## 9. 한 줄 결론

세 모델이 서로 다른 말로 같은 곳에 도달했다 — **다음 9일은 테스트도 사이트도 iOS도 늘리지 말고, 이미 테스터 손에 있는 저장·분류 루프를 닫는 데 쓴다.** 그리고 그 커밋이 다시 빠져나가지 못하도록 훅·CI·지시문·PR 템플릿이 같은 스크립트 하나를 부르게 묶는다. grok이 덧붙인 한 문장이 이 논의의 요약이다 — *"그 커밋을 에이전트가 올리기 전에, 완료의 정의가 format·anti-pattern을 포함해야 한다."*

이 논의가 새로 더한 것은 처방이 아니라 **비용의 정정**이다. P2는 주석이 이미 답을 적어 두었고, P5는 provider가 이미 구현돼 있어 배선만 남았다. 회고록이 "가장 큰 리스크"로 지목한 두 항목이 **합쳐 1.25~1.5일짜리 작업**이었다. 열려 있던 이유는 어려워서가 아니라 **아무도 그것들이 열려 있다고 세지 않아서**다.

---

## 부록 — 근거 파일

- 선행 회고록: [`2026-08-19-development-retrospective.md`](./2026-08-19-development-retrospective.md)
- 코드: `lib/app/router/app_router.dart:76-90` · `lib/features/link/presentation/screens/link_add_screen.dart:40-48` · `lib/features/collection/presentation/provider/collection_list_provider.dart:32-48` · `lib/features/collection/presentation/screens/collection_list_screen.dart:53` · `lib/features/collection/presentation/widgets/collection_picker_sheet.dart` · `lib/core/storage/storage_service.dart:17` · `test/shared/widgets/ln/ln_top_bar_test.dart:25-74`
- 검증 시퀀스 5곳: `.git/hooks/pre-commit:14`(format `lib/`)·`:24`(analyze `--fatal-infos`) · `.github/workflows/ci.yml:33`(format `lib/ test/`)·`:36`(anti-pattern)·`:39`(analyze `--fatal-warnings`) · `docs/ai-guidelines.md:11-15` · `CLAUDE.md:21,24` · `AGENTS.md:9-10` · `.github/pull_request_template.md` · (경로 오기) `docs/code-review-process.md:27`
- 체크리스트: `docs/release-checklist.md` §2 및 AAB SHA-256 칸 · `docs/play-release-execution-guide.md` §5
- 통제: `tool/check_anti_patterns.sh` · `.github/workflows/ci.yml` · `.gitignore:61`
