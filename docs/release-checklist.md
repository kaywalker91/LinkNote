# LinkNote 출시 체크리스트 (Release Checklist)

**갱신 기준일:** 2026-06-21 (main `342c94e`, PR #58 머지 직후)

이 문서는 "지금 출시 가능한가?"를 한눈에 판단하는 **단일 게이트 뷰**다.
단계별 상세 절차·배경은 다음 문서를 참조한다(중복 기술하지 않음):

- 플랫폼 단계 전략 + Phase 7/7.5/8/9 상세 체크리스트 → [`linknote-workflow.md`](./linknote-workflow.md)
- Supabase 스키마/RLS 적용 절차 → [`supabase-setup.md`](./supabase-setup.md), [`security/rls-policies.md`](./security/rls-policies.md)

> **플랫폼 순서(workflow 정합):** Android 전 기능 구현 → **Android 배포** → 배포 후 개선 → iOS 포팅 → iOS 배포.
> Android와 iOS는 **병행하지 않는다.** 따라서 아래 iOS 항목은 Android 정식 배포(Phase 7.5) 이후에만 착수한다.

---

## 0. 현재 상태 한 줄

**기능·코드·테스트는 성숙(639 GREEN, analyze 0), 그러나 "출시 인프라"는 초입.**
남은 일의 대부분은 코딩이 아니라 **사용자 액션**(keystore 생성, 결제·등록, 대시보드 작업, 실기기 QA)이다.

| 영역 | 상태 | 담당 |
|---|---|---|
| 기능 / 코드 / 테스트 (639 GREEN) | ✅ 성숙 | 코드 |
| Supabase 백엔드 **라이브 적용** (prod) | ✅ 적용+RLS검증 (2026-06-21) | — |
| Android 릴리스 **서명 인프라** | ✅ keystore+AAB+SHA (2026-06-21) | — |
| Play Store 등록 | ❌ 미착수 | 사용자 |
| 실기기 QA | 🟠 착수 가능 (서명 해소) | 사용자 |
| iOS 전체 | ⏸ 대기(Phase 8) | 사용자 |

범례: ✅ 완료 · 🔴 하드 블로커(없으면 업로드/동작 불가) · 🟠 출시 전 검증 · 🟡 출시 위생 · ⏸ 후순위(Android 배포 후)

---

## 1. 🔴 하드 블로커 — 이게 풀려야 "출시 시작"

### 1.1 Android 릴리스 서명 (사용자 액션)

현재 `android/app/build.gradle.kts:75-79`는 `key.properties`가 **없으면 release 빌드를 debug.keystore로 폴백**한다. 실측 결과:

- `android/key.properties` — **없음**
- 릴리스 keystore(`*.jks`) — **없음**

→ 지금 `--release` 빌드는 **debug 서명** AAB를 만들고, 이는 Play Store 업로드가 거부된다.

- [ ] Upload keystore 생성 (`keytool`) + **백업 정책 문서화** (분실 시 Play 앱 서명 복구 불가 — 치명적)
- [ ] `android/key.properties`(gitignored) 작성 → `signingConfigs.release` 실제 주입 확인
- [ ] `flutter build appbundle --flavor prod --release` + `apksigner verify` 로 **release 서명** 확인
- [ ] 생성된 release SHA-1/SHA-256 → GCP/Firebase에 등록 (현재 debug SHA-1만 등록됨, `project_firebase_security` 참조)

> 코드측 준비는 끝나 있음: `signingConfig` 골격 + `key.properties.example` 템플릿 존재. keystore만 만들면 자동 연결됨.

### 1.2 Supabase 백엔드 라이브 적용 — ✅ prod 적용+검증 (2026-06-21, Session 67)

prod Supabase 프로젝트에 SQL Editor로 적용 + impersonation RLS 검증 완료.

- [x] `collections`/`links` **RLS enabled** 확인 (둘 다 `relrowsecurity=true`)
- [x] migration_59 (`visibility`/`locked_at` 컬럼) — **이미 적용돼 있음**(컬럼 존재 확인). 멱등이라 재실행 불필요
- [x] migration_64 (public 공유 read 경로) 적용 — `collections_select_own_or_public` + `links_select_public_collection` 정책 생성 확인. 기존 `Users can CRUD own *` (FOR ALL) 위에 SELECT만 OR로 추가
- [x] 비소유자 RLS 검증 — 랜덤 UUID impersonation 결과 `private_visible=0`, `public_visible=1`, public 링크만 가시(private 누출 0)
- [~] migration_63 (owner-only SELECT 재선언) — **의도적 스킵**: 기존 FOR ALL 정책이 이미 owner-only를 강제하고 64가 collections SELECT 정책을 대체하므로 net no-op. 파일은 버전관리 기록으로 유지
- [ ] ~~**dev/staging** Supabase URL DNS 실패 이슈 (DNS/네트워크 추정)~~ → **정정(2026-06-21 가상기기 QA)**: 원인은 DNS가 아니라 **`.env.*`의 placeholder URL**(`your-prod-project.supabase.co`)이 빌드에 임베드된 것. `No address associated with hostname`은 placeholder 호스트 조회 실패. 실제 Supabase URL/anon key 입력 + `build_runner` 재생성으로 해소. §2 QA 항목 참조

> ✅ migration_64 라이브 적용 완료로 PR #57 public 공유 백엔드가 동작 가능. 앱 딥링크 실제 왕복은 §2 실기기 QA에서 최종 확인.

### 1.3 iOS 출시 자격 (⏸ Phase 8 — Android 배포 후)

- `ios/Runner/GoogleService-Info.plist` — **없음** (iOS Firebase 미초기화)
- iOS Crashlytics — `main*.dart`에 배선 없음(비활성)
- Apple Developer Program — 미등록($99/yr)

- [ ] Apple Developer 등록 + Team ID 확보 + App ID 3개(dev/staging/prod)
- [ ] `flutterfire configure --platforms=ios` → `GoogleService-Info.plist` 3개 배치 + iOS Crashlytics 배선
- [ ] Xcode 서명(자동/수동) + TestFlight 빌드

---

## 2. 🟠 출시 전 검증 (실기기/가상기기)

### 가상기기 QA 1차 (2026-06-21, Pixel_7 / Android 16 / prod flavor)

구조·라우팅·R8 스모크는 Claude 자율 검증 완료(로그인 불필요 범위). 결과:

- [x] **콜드 실행 크래시 0** — debug + **release(R8 minify)** 양쪽. release 서명 `CN=Kaywalker`, versionName 1.1.6 / versionCode 1. 런타임 R8 에러(ClassNotFound/NoSuchMethod/NoClassDef/VerifyError) 0
- [x] **R8 빌드/런타임** — `assembleProdRelease` 빌드타임 에러 0(`-dontwarn play.core` 유효), minified APK 실행·라우팅·폰트 정상
- [x] **딥링크 라우팅(`linknote:///collections/public/<id>`) + share-intent(#56) 공존** — debug+release 양쪽 미인증 시 로그인 리다이렉트, 크래시 0. Phase 0 VIEW/SEND 공존 회귀 0 (PR #57 device-verified)
- [x] **라이트/다크 시각** — 로그인 화면 양 테마 정상 렌더 + 라이브 전환 동작
- ✅ **[RESOLVED] prod env placeholder 블로커** — release 빌드가 `.env.prod`의 placeholder URL(`your-prod-project.supabase.co`)로 컴파일돼 로그인 시 `Failed host lookup`. 실제 prod URL(`jzcduhgatmbobevxjdhy.supabase.co`)/anon key(신형 `sb_publishable_` 형식) 입력으로 해소. **2차 근본원인**: envied가 `.env` 변경을 build_runner 입력으로 추적 못 해 `--delete-conflicting-outputs`만으로는 캐시 재사용(생성 .g.dart 바이트 배열 동일) → `dart run build_runner clean` 필수. 빌드 전 .g.dart 디코딩 + 에뮬 `ping`(172.64.149.246, 0% loss)으로 검증. §1.2 dev/staging "DNS" 항목의 실제 원인이기도 함

### 가상기기 QA 2차 (2026-06-21, 로그인 후 하이브리드 — 사용자 로그인 + Claude adb 구동)

- [x] **로그인 → 실제 prod 백엔드 통신** — 홈 `내 서랍` 실데이터 4링크 로드, logcat host/auth 에러 0
- [x] **검색** — "news" 쿼리 → 백엔드 1건 결과 정상 렌더 + 태그칩(코하루/news, `fetchUserTags` 실데이터)
- [x] **컬렉션 왕복** — 목록(Missav/News 2개) → News 상세(소유자 뷰: 공개 토글 ON·잠금 OFF·Share/Edit/Delete 노출) 정상
- [x] **공유 전송(share_plus)** — Share → 시트가 `linknote:///collections/public/c228a5a9-a5d0-4316-9c68-478e3fc7d784` 정확 생성 (triple-slash). 공유 타깃에 LinkNote 자체 노출(수신 등록 OK)
- [x] **공개 컬렉션 딥링크 → 읽기전용 뷰** — VIEW intent 라우팅 → PublicCollectionDetailScreen(back만, edit/delete/공개·잠금 토글 전면 부재, 링크 읽기전용 렌더). Phase 0/5/6 + migration_64 소유자 read 동작 확인
- [x] **읽기통계 배지** — 0회라 미렌더(Sprint-3 `compact` 설계대로)

### 잔여 (다른 계정/콘솔 필요 — 사용자)

- [ ] 공개 컬렉션 **비소유자** 실제 왕복 (다른 계정 로그인 — RLS `TO authenticated` OR `visibility='public'` 효과 + private 누출 0 확인)
- [ ] 읽기통계 **증가** 경로 (링크 열기 → totalReads +1 → 배지 노출, reading_stats 실 write)
- [ ] Firebase **DebugView**: `first_open`/`session_start` + **탭 전환 `screen_view`**(#58) 콘솔 집계 (웹 콘솔 — 사용자)
- [ ] 강제 크래시 → Crashlytics 대시보드 수신 (release 빌드, 웹 콘솔 — 사용자)
- [ ] 공유 시트 동작 + "제목+URL" 페이스트 sanitize 재확인 (Session 19 교훈)

---

## 3. 🟡 출시 위생 (코드측 — ✅ 코드측 완료 2026-06-21, 사용자 액션 일부 잔여)

- [x] **버전 체계 확정** — `pubspec.yaml: 1.0.0+1 → 1.1.6+1`. CHANGELOG의 기존 1.0.0~1.1.5는 미배포 초기 개발 마일스톤이라 1.1.6을 **첫 공개 출시**로 확정(사용자 결정). 빌드넘버는 업로드마다 +1 증가 정책
- [x] **`CHANGELOG.md` 릴리스 노트 정리** — `[Unreleased]` → `## [1.1.6] - 2026-06-21` 승격, 상단에 "주요 변경(사용자 관점)" 7항목 요약 추가, 세션별 상세는 작업 기록으로 보존. 기존 버전 헤더 재작성 없음
- [x] **스토어 리스팅 자산 초안** — `docs/store-listing.md` 신규(간단/자세한 설명, 출시 노트 ≤500자, Data safety 양식, 콘텐츠 등급 가이드, 스크린샷 5종 인벤토리). `docs/privacy-policy.md` 신규(실제 수집 항목 기준)
- [x] **FCM(Android) 착수 여부 결정** — `firebase_messaging` 의존성 존재하나 `lib/` 사용 0건(미배선) 확인. **1.1.6 미포함**, 배선 시 차기 버전(1.2.0)으로 분리 + 개인정보 처리방침에 푸시 토큰 항목 추가
- [ ] ⚠️ (사용자) `docs/privacy-policy.md` 공개 URL 게시 + Console 입력 + 문의처 이메일 기입
- [ ] ⚠️ (사용자) 피처 그래픽 1024×500 제작 (Play Console 필수 자산)

---

## 4. Definition of "Ready to Ship" — Android (Phase 7 → 7.5)

아래가 **모두** 충족돼야 Play Store Internal Test 업로드가 가능하다:

1. ✅ 1.1 release 서명 AAB 생성 + `jar verified`(CN=Kaywalker) 통과 + Firebase prod SHA 등록 (2026-06-21)
2. ✅ 1.2 migration_59/64 prod 라이브 적용 + 비소유자 RLS 검증 (2026-06-21)
3. 🟠 2. 실기기 스모크 + Firebase 콘솔 수신 확인 (+ Play App Signing 키 SHA 추가 등록)
4. ✅ 3. 버전(1.1.6+1)/CHANGELOG/리스팅 자산 초안 확정 (2026-06-21) — 단, 개인정보 URL 게시·피처 그래픽은 Console 업로드 단계 사용자 액션

→ 이후 Play Console: Internal → Closed → Open → Production 단계 승격 + 단계 롤아웃 (상세: workflow Phase 7.5).

---

## 부록 — 최근 머지된 출시 관련 작업

- PR #58 (`342c94e`) — 바텀 네비 탭 전환 `screen_view` 로깅 (위 2. DebugView 검증 대상)
- PR #57 (`788912d`) — public 컬렉션 읽기전용 공유 (위 1.2 migration_64 + 2. 딥링크 검증에 의존)
- PR #56 (`5487b26`) — warm/foreground share intent (위 2. 공존 검증 대상)
