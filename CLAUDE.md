# LinkNote

모바일 북마크 서비스 - 웹 링크/유튜브/아티클/메모를 저장, 태그/컬렉션/검색으로 관리, 공유.

## Tech Stack

- **Framework**: Flutter 3.41.4 / Dart 3.11.1
- **State Management**: Riverpod 3.x + 코드 생성 (riverpod_annotation + riverpod_generator)
- **Routing**: GoRouter
- **Network**: Dio + Retrofit
- **Local DB**: Hive CE
- **Backend**: Supabase
- **Firebase**: Core, Messaging, Crashlytics, Analytics
- **Serialization**: Freezed + json_serializable
- **Environment**: envied (코드 생성 기반, 시크릿 난독화)
- **Linting**: very_good_analysis + custom_lint + riverpod_lint

## Key Commands

```bash
# 의존성 설치
flutter pub get

# 코드 생성 (freezed, riverpod, retrofit, envied, hive)
dart run build_runner build --delete-conflicting-outputs

# 코드 생성 (watch 모드)
dart run build_runner watch --delete-conflicting-outputs

# 정적 분석
flutter analyze

# 테스트
flutter test

# 앱 실행
flutter run -d chrome
flutter run -d emulator-5554
```

## Architecture

Feature-first + Clean Architecture Lite:

```
lib/
├── app/          # App shell (router, theme, DI)
├── core/         # Shared infra (network, error, storage, logger, constants)
├── shared/       # Reusable widgets, extensions, models
└── features/     # Feature modules
    └── <feature>/
        ├── data/          # datasource, dto, mapper, repository impl
        ├── domain/        # entity, repository interface, usecase
        └── presentation/  # provider, screen, widget
```

## Conventions

- **Riverpod**: 항상 코드 생성 사용 (`@riverpod` annotation). 함수 시그니처에 `Ref` 사용 (Riverpod 4.x).
- **에러 처리**: `Failure` sealed class (freezed) + `Result` 타입.
- **TODO 스타일**: `// TODO(linknote): Description.` (Flutter style)
- **pubspec 의존성**: 알파벳 순 정렬
- **생성 파일**: `*.g.dart`, `*.freezed.dart`, `*.gen.dart`는 커밋 대상에 포함
- **환경 변수**: `.env` 파일은 커밋 금지, `envied`로 코드 생성
  - **허용 키** (클라이언트 공개키만): `SUPABASE_URL`, `SUPABASE_ANON_KEY`
  - **금지 키** (서버사이드 특권 자격증명): `SUPABASE_SERVICE_ROLE_KEY`, `STRIPE_SECRET_KEY`, `DATABASE_URL`, `*_SECRET_*`, `*_PRIVATE_*`
  - `envied`의 `obfuscate: true`는 XOR 난독화로 jadx/strings로 복원 가능하므로 특권 키 보호에 부적합
- **Firebase 클라이언트 설정** (FlutterFire 공식 패턴):
  - `lib/firebase_options_{dev,staging,prod}.dart` 및 `android/app/src/{dev,staging,prod}/google-services.json`은 **의도적으로 커밋**됨
  - 여기 포함된 Android `apiKey`는 **공개 클라이언트 식별자**이며 비밀이 아님 (APK에 빌드 타임 임베드되어 누구나 추출 가능)
  - 실질 방어는 Google Cloud Console에서 수행:
    - **Application restrictions**: Android 앱 3개(`app.kaywalker.linknote[.dev|.staging|""]`) + debug/release SHA-1
    - **API restrictions**: 4개 API만 화이트리스트 — Firebase Installations, FCM, FCM Registration, Cloud Logging
    - **프로젝트 레벨**: Maps/Translation/Vision/AI 등 과금성 API는 enable하지 않음 (SERVICE_DISABLED 상태 유지)
  - GitHub secret scanning이 탐지 시 **False positive**로 닫을 것 (참고: https://firebase.google.com/docs/projects/api-keys)
  - **절대 커밋 금지**: `firebase-adminsdk-*.json`, `service_account*.json`, FCM legacy server key — 이건 진짜 비밀
