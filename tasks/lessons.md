# LinkNote Lessons Learned

프로젝트 로컬 교훈. `~/.claude/rules/continuous-improvement.md` 규칙에 따라 기록.

---

## 2026-04-12 — Stage 1 사전 검증이 플랜 방향을 바꾼다

**무엇을 배웠나**: Wave 1 보안 리뷰가 도출한 6개 이슈에 대해 Stage 1(Research) 진입 전, 보고서의 "Unverified assumptions" 5건을 코드/SDK 소스/`gh api`로 직접 검증했더니 **3개 이슈의 픽스 방향이 달라졌다.**

**구체 사례**:
1. **P1-C (userDeleted 이벤트 미처리)**: 사전 검증으로 `gotrue-2.18.0/lib/src/constants.dart`에서 `userDeleted('')`가 `@Deprecated` + 빈 `jsName`임을 확인. 추가 분기를 넣는 것이 **완전 무의미**(영원히 false)임을 알아냄. 대신 `userUpdated` 분기 추가 + 주석 정합성 수정으로 방향 전환.
2. **P2-A (AndroidManifest allowBackup)**: `storage_service.dart`가 이미 `HiveAesCipher`로 모든 박스를 암호화하고 있음을 확인. 위험도가 "실질 데이터 유출"에서 "defense-in-depth baseline"으로 재평가되어 플랜의 긴급도가 조정됨.
3. **P2-B (CI gating)**: 보고서는 "`security` job을 required checks에 등록해야 실효성 있음"이라고 기술했으나, `gh api`로 확인해보니 `main`에 **보호 규칙 자체가 전무** (404). 원 픽스 범위의 2배 규모 작업으로 재스코핑됨.

**근본 원인**: 리뷰 보고서가 "Unverified"로 명시한 가정을 검증 없이 Stage 2로 넘어갔다면, Stage 4(구현) 중에 "코드 추가했는데 동작 안 함", "픽스했는데 실질 강제력 없음" 같은 블로커 발생 후 Stage 1 복귀 필요.

**예방 규칙**:
- 코드 리뷰 보고서를 입력으로 받는 Stage 1 세션은 **Unverified assumptions를 맨 먼저 검증**한다. 검증 전에 리서치.md를 쓰지 않는다.
- 검증 가능한 가정(SDK enum, `gh api`, 파일 존재 여부, 설정 값)은 즉시 확인. 사용자 확인이 필요한 가정(Dashboard 설정, 권한)은 AskUserQuestion으로 묶음 질의.
- 검증 결과는 리서치.md의 맨 앞 섹션 "사전 확인 결과"로 박아 후속 단계 전체가 그 결과를 참조하게 한다.

---

## 2026-04-12 — P3-A proguard Hive keep rules: YAGNI, 보류

**무엇을 배웠나**: Wave 1 리뷰의 P3-A(선제 Hive keep rules)는 현재 `Map<dynamic, dynamic>` 박스만 사용하는 구조에서 **즉시 위험이 없다.** 미래에 `@HiveType` 모델 클래스 도입 시에만 R8 minification 위험이 생긴다.

**결정**: 본 스프린트에서 제외. 향후 `@HiveType` 도입 PR에서 함께 추가한다. 선제 추가는 YAGNI 위반.

**예방 규칙**:
- "미래 방어" 목적 픽스는 **트리거 조건이 코드에 실제로 등장하는 시점**까지 보류한다.
- Wave 1의 P3는 원칙적으로 지금 수정하지 않는 방향이 기본값. "Low confidence, 현재 코드 기준 미사용" 표기가 있으면 더욱 그렇다.

---

## 2026-04-12 — `failure_ui.dart` 하드코딩이 datasource 메시지를 삼키고 있었다

**무엇을 배웠나**: Wave 1 P1-B 플랜 작성 중 `lib/core/error/failure_ui.dart:30-35`의 `AuthFailure()` 분기가 **패턴의 message 필드를 완전히 무시하고** "다시 로그인해 주세요"를 하드코딩하는 것을 발견.

**영향**: `auth_remote_datasource.dart`의 `Failure.auth(message: e.message)` 호출들(signIn/signUp/signOut 전부)이 만든 정교한 Supabase 에러 메시지(e.g., "Invalid login credentials", "User already registered")가 전부 한 문자열로 덮어써지고 있었다. P1-B 픽스의 "이메일 확인 링크가 발송되었습니다" 메시지도 사용자에게 보이지 않을 것.

**근본 원인**: 친화적 한국어 UX와 raw Supabase 에러 메시지 사이의 트레이드오프 결정이 **message 필드 자체를 drop하는 방식**으로 이뤄졌음. 디버깅 어려움 + UX 정보 손실.

**예방 규칙**:
- `failure_ui.dart`의 각 `XxxFailure` 분기는 `message`를 반드시 surface하거나, 최소한 `isNotEmpty`일 때는 관통시킨다.
- 데이터소스에서 `Failure.auth(message: e.message)`를 호출하는 모든 경로는 해당 메시지가 UI에 **실제로 도달하는지** 수동 확인한다.
- 보안/리뷰 세션에서 "에러 처리 일관성"은 독립 dimension으로 추가 검토 가치 있음.
