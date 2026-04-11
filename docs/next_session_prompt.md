# 다음 세션 프롬프트

아래 내용을 그대로 붙여넣기해서 다음 세션을 시작하세요.

---

```
Session 16 — 릴리스 빌드 실행 준비 완료, 다음 단계 선택

## 배경 (현재 상태)
- 보안 감사 10/10건 전체 수정 완료
- UI/UX 개선 전체 완료 (Phase 1 + Phase 2)
- Search 기능 보강 완료 (필터/히스토리/자동완성)
- 릴리즈 준비 Phase 1 완료 (앱 아이콘, 스플래시, ProGuard, 메타데이터 통일)
- 빌드 플레이버 분리 완료 (dev/staging/prod)
- 릴리스 서명 인프라 정비 완료 (Critical Fix 3건 + ExportOptions.plist)
- `flutter analyze --fatal-warnings` CI 3.41.4 환경 **0 issues** (only_throw_errors 5건 해결)
- 315 tests ALL GREEN
- 최근 CI run 전체 job 성공 (Analyze / Security / Test / Build)
- Firebase 미연결 (flutterfire configure 미실행)

## 직전 세션(#15) 결과
- 커밋 `4b57674`: `Error.throwWithStackTrace` 패턴으로 only_throw_errors info 5건 제거
  - 대상: `collection_list_provider.dart`, `link_detail_provider.dart` (2곳), `link_list_provider.dart`, `profile_provider.dart`
  - 런타임 동작 변경 없음, 순수 lint 정리
- CI run `24278530380` 전체 통과
- 문서 업데이트 커밋 예정 (CHANGELOG 1.1.4 + daily_log 세션 #15 + next_session_prompt)

## 사용자 액션 필요 (미완료 — 릴리스 빌드 실행 전 필수)
1. **Android keystore 생성**
   ```bash
   keytool -genkeypair -v -keystore ~/linknote-release.jks \
     -alias linknote -keyalg RSA -keysize 2048 -validity 10000
   ```
   → `android/key.properties` 작성 (storePassword/keyPassword/keyAlias/storeFile)
2. **Apple Developer Program 등록** ($99/year) → App ID 3개 등록 (dev/staging/prod)
3. `ios/Flutter/{Dev,Staging,Prod}-Release.xcconfig` + `ios/ExportOptions.plist`의 `YOUR_TEAM_ID` 플레이스홀더를 실제 Team ID로 교체
4. Xcode에서 Runner > Signing & Capabilities > Team 선택

## 가능한 다음 작업 (사용자 선택)

### Option A: Android 릴리스 APK 빌드 + 실기기 스모크 테스트 (추천)
- 전제: 위 사용자 액션 #1 (Android keystore) 완료
- 빌드:
  ```bash
  flutter build apk --release --flavor prod -t lib/main_prod.dart
  flutter build appbundle --release --flavor prod -t lib/main_prod.dart
  ```
- 실기기 설치 후 `.claude/plans/memoized-inventing-gadget.md`의 릴리스 전용 오류 10항목 검증
- ProGuard/R8 minification으로 인한 런타임 크래시 유무 확인

### Option B: iOS 릴리스 빌드 + TestFlight 업로드
- 전제: 위 사용자 액션 #2, #3, #4 전부 완료
- 빌드:
  ```bash
  flutter build ipa --release --flavor prod -t lib/main_prod.dart \
    --export-options-plist=ios/ExportOptions.plist
  ```
- TestFlight 업로드 후 내부 테스트

### Option C: Firebase 연결
- Firebase 콘솔에서 프로젝트 3개 생성 (dev/staging/prod) 또는 단일 프로젝트 멀티 앱
- `flutterfire configure` 실행 → `firebase_options.dart`, `google-services.json`, `GoogleService-Info.plist` 생성
- main.dart 주석 처리된 Crashlytics/Analytics 초기화 코드 활성화
- GoRouter에 Analytics observer 연결

### Option D: QA 테스트 플랜 실행
- `.claude/plans/memoized-inventing-gadget.md` 시나리오 실행
- 릴리스 빌드 전용 오류 검증 (ProGuard, 퍼미션, 플러그인)
- 기능별 40+ 테스트 케이스 수행

### Option E: 추가 UI/UX 개선
- 플레이스홀더 아이콘 → 실제 디자인 아이콘 교체
- Lottie 애니메이션, 스와이프 제스처
- 링크 카드 OG 이미지 썸네일

### Option F: 오프라인 지원 강화
- 오프라인 큐 (링크 생성/수정 재시도)
- Hive ↔ Supabase 동기화 충돌 해결

### Option G: README 포트폴리오 완성
- 아키텍처 다이어그램, 시연 GIF/스크린샷
- CI/CD 파이프라인 설명 + badge

## 수정하지 않는 것
- 보안 수정 사항 롤백 금지
- 아키텍처 패턴 변경 금지 (Clean Architecture + Riverpod 유지)
- ProGuard/R8 설정 비활성화 금지
- SnackBar 통합 시스템 패턴 변경 금지
- `Error.throwWithStackTrace` 패턴을 다시 `throw`로 되돌리지 말 것
- `Failure sealed class`에서 `implements Exception` 제거 금지

## 완료 기준
- `flutter analyze --fatal-warnings` 0 issues 유지
- `flutter test` ALL GREEN (315+)
- `dart format --set-exit-if-changed lib/ test/` 클린
- CI 전체 job 성공
- 커밋 + 푸시 (사용자 승인 후)
```
