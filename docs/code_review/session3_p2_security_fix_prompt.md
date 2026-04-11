# Session 3 보안 감사 P2 수정 + Phase 6 Firebase 초기화

## Context
보안 코드리뷰 Session 1에서 P0 3건(Session 1.5), P1 4건(Session 2) 수정 완료.
전체 리포트: `docs/code_review/session1_security_audit.md`
현재 테스트: 301 tests ALL GREEN
이번 세션: P2 (Medium) 3건 수정 + Firebase Crashlytics 초기화.

## P2 수정 항목 (3건)

### P2-1. 글로벌 에러 핸들러 + Firebase Crashlytics 초기화

`main.dart`에 `runZonedGuarded`, `FlutterError.onError`, `PlatformDispatcher.onError` 모두 없음. Firebase Crashlytics 초기화도 주석 처리됨.

**수정 대상:**
- `lib/main.dart`

**수정 방법:**
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    FirebaseCrashlytics.instance.recordFlutterFatalError(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(const ProviderScope(child: App()));
}
```

**주의:**
- `firebase_core`, `firebase_crashlytics` 패키지 확인 (pubspec.yaml에 이미 있을 수 있음)
- Context7으로 `FirebaseCrashlytics.instance.recordFlutterFatalError` 최신 API 확인
- 기존 `main.dart`의 초기화 순서(Hive, Supabase 등) 유지
- `kDebugMode`에서는 Crashlytics 비활성화 고려

---

### P2-2. CI Semgrep `continue-on-error: true` 제거

`.github/workflows/ci.yml:131`에서 Semgrep 보안 스캔이 실패해도 CI가 green.

**수정 대상:**
- `.github/workflows/ci.yml` (Semgrep step)

**수정 방법:**
1. `continue-on-error: true` 제거
2. 또는 `gitleaks`/`truffleHog`로 대체하여 시크릿 패턴 감지 강화
3. Branch protection에서 security job을 required check로 설정

**주의:**
- CI 파일 변경 전 현재 Semgrep 설정 확인
- 실패 시 영향 범위 확인 (다른 step에 의존성 있는지)

---

### P2-3. envied 정책 문서화

`envied`의 XOR 난독화(`obfuscate: true`)는 jadx/strings로 복원 가능. 현재 `supabaseUrl`과 `supabaseAnonKey`만 저장되어 위험도 낮으나, 향후 service-role key 등 특권 자격증명 추가를 방지해야 함.

**수정 대상:**
- `CLAUDE.md` 또는 프로젝트 루트 문서

**수정 방법:**
1. `.env` 파일에 저장 가능한 키 목록 정의 (whitelist)
2. `SUPABASE_SERVICE_ROLE_KEY`, `STRIPE_SECRET_KEY` 등 서버사이드 전용 키 금지 명시
3. CI에서 `.env` 패턴 체크 추가 (선택)

---

## 추가 작업 (선택)

### Firebase Analytics/Messaging 초기화
P2-1에서 Firebase Core를 초기화하면서 함께 처리 가능:
- `FirebaseAnalytics` 옵저버를 GoRouter에 연결
- `FirebaseMessaging` 토큰 등록 + 알림 핸들링 (notification feature와 연결)

### StorageService 테스트
`lib/core/storage/storage_service.dart`에 대한 테스트가 아직 없음.
Session 1.5에서 Hive 암호화를 추가했으므로 암호화 키 생성/로드 로직 테스트 필요.

---

## 수정 규칙

1. **TDD**: P2-1의 경우 글로벌 에러 핸들링은 통합 테스트 범위이므로, main.dart 변경 후 `flutter analyze` + 기존 테스트 통과로 검증
2. **기존 테스트 301개 ALL GREEN 유지** — `flutter test` 전체 통과 확인
3. **flutter analyze 0 errors 유지**
4. **수정 범위 엄수** — P2 3건 + Firebase 초기화만
5. **Context7 조회** — Firebase Crashlytics, Analytics 최신 Flutter API 확인
