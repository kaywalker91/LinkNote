# LinkNote — AI Agent Guidelines (canonical)

모델별 진입점(`AGENTS.md`, `CLAUDE.md`, `GEMINI.md`)은 이 문서를 짧은 포인터로 참조한다.
세션 상태·PR 번호·일시적 이력은 여기 두지 않는다.

## Build / Verify

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
```

완료 선언 전: `flutter analyze` exit 0 + 관련 테스트 통과. timeout/환경 오류는 PASS로 간주하지 않는다.

## Architecture boundaries

- Feature-first Clean Architecture Lite: `lib/features/<feature>/{data,domain,presentation}/`
- Riverpod 코드 생성 (`@riverpod`), `Ref` 시그니처 (Riverpod 4.x)
- 에러: `Failure` sealed (freezed) + `Result`
- 생성 파일(`*.g.dart`, `*.freezed.dart`, `*.gen.dart`) 커밋 포함

## Do not change / secrets

- `.env` 커밋 금지. 클라이언트 공개키만: `SUPABASE_URL`, `SUPABASE_ANON_KEY`
- 금지: `SUPABASE_SERVICE_ROLE_KEY`, `STRIPE_SECRET_KEY`, `DATABASE_URL`, `*_SECRET_*`, `*_PRIVATE_*`
- 절대 커밋 금지: `firebase-adminsdk-*.json`, `service_account*.json`, FCM legacy server key
- `firebase_options_*.dart` / flavor `google-services.json` 은 공개 클라이언트 식별자 (의도적 커밋)

## Git / release

- `git push` 는 사용자 명시 승인 후에만
- 완료 전 예상 밖 파일 변경 없는지 확인

## Feedback

- 반복 실수: `tasks/lessons.md` 에 원인·예방 규칙 기록
- 세션 시작 시 lessons 최근 항목 검토 (SessionStart 훅이 힌트 주입)
