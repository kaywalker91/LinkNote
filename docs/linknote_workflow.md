# LinkNote — 개발 워크플로우 & 구현 가이드

> **버전:** v1.0.0  
> **최종 수정:** 2026.03  
> **목적:** 8주 완성 로드맵 + Git / CI/CD / 코드 컨벤션 기준 정의

---

## 1. 개발 원칙

### 1.1 핵심 기준 3가지

1. **완성 가능성 우선** — 완벽한 코드보다 돌아가는 MVP가 먼저다. 2주마다 데모 가능한 상태를 유지한다.
2. **설명 가능한 구조** — 면접에서 "왜 이렇게 만들었나요?"에 답할 수 있는 의도적 설계를 한다.
3. **점진적 완성** — Phase 1 (MVP) → Phase 2 (확장) 순서를 지키고, 욕심내서 scope를 벌리지 않는다.

### 1.2 해서는 안 되는 것

- MVP 완성 전에 확장 기능 개발 착수
- 아키텍처 과설계 (e.g., 필요 없는 Use Case 레이어 분리)
- 디자인 픽셀 맞추기에 시간 낭비
- GitHub commit 없이 며칠 이상 작업

---

## 2. 8주 구현 로드맵

### 전체 일정 한눈에 보기

```
Week 1-2  [기반]    프로젝트 세팅, 라우팅, 인증
Week 3-4  [핵심]    링크 CRUD, 목록, 검색
Week 5    [확장]    컬렉션, 딥링크
Week 6    [안정화]  로컬 캐시, 성능 최적화
Week 7    [검증]    테스트 작성
Week 8    [마무리]  CI/CD, README, 데모 영상
```

---

### Week 1-2 — 기반 세팅

**목표:** 앱 뼈대 완성 + 인증 플로우 작동

#### 체크리스트

- [ ] Flutter 프로젝트 생성 및 `pubspec.yaml` 기본 의존성 추가
- [ ] 폴더 구조 생성 (`app`, `core`, `shared`, `features`)
- [ ] `go_router` 라우트 정의 (Splash → Login → Home)
- [ ] 인증 가드 설정 (로그인 여부에 따른 redirect)
- [ ] Supabase 프로젝트 생성 및 `.env` 연동
- [ ] 이메일 회원가입 / 로그인 구현
- [ ] JWT 토큰 SecureStorage 저장 / 불러오기
- [ ] 앱 시작 시 토큰 유효성 검사 흐름 구현
- [ ] 디자인 시스템 초안 (Color, Typography, Spacing 상수)
- [ ] 공통 에러 처리 구조 정의 (`Failure` sealed class)

#### 데모 기준

> 앱 실행 → 회원가입 → 로그인 → 홈 화면 진입 → 재실행 시 자동 로그인

---

### Week 3-4 — 핵심 기능

**목표:** 링크 저장 / 조회 / 검색 작동

#### 체크리스트

**링크 저장**

- [ ] LinkRemoteDataSource (Supabase insert/update/delete)
- [ ] LinkRepository 인터페이스 및 구현체
- [ ] CreateLinkUseCase / UpdateLinkUseCase / DeleteLinkUseCase
- [ ] URL OG Tag 파싱 (제목, 설명, 썸네일 자동 추출)
- [ ] 태그 추가 / 삭제 UI
- [ ] 즐겨찾기 토글 (Optimistic update 적용)

**링크 목록**

- [ ] LinkListNotifier (AsyncNotifier) 구현
- [ ] cursor 기반 무한 스크롤 페이지네이션
- [ ] 필터 상태 Provider (전체 / 즐겨찾기)
- [ ] Skeleton loading UI
- [ ] 링크 상세 화면

**검색**

- [ ] SearchNotifier (debounce 300ms)
- [ ] 제목 / 태그 검색 API 연동
- [ ] 최근 검색어 로컬 저장 (Isar)

#### 데모 기준

> 링크 추가 → 썸네일 자동 파싱 → 목록 반영 → 즐겨찾기 → 검색으로 찾기

---

### Week 5 — 컬렉션 & 딥링크

**목표:** 컬렉션 공유 기능 + 딥링크 처리 구현

#### 체크리스트

**컬렉션**

- [ ] 컬렉션 생성 / 수정 / 삭제
- [ ] 컬렉션에 링크 추가 / 제거
- [ ] 공개 / 비공개 설정
- [ ] 다른 사용자 공개 컬렉션 조회

**딥링크**

- [ ] `go_router` deep link 스킴 설정 (`linknote://`)
- [ ] Cold Start 딥링크 처리 큐 구현
  - 앱 초기화 완료 전 딥링크 수신 시 큐에 보관
  - 초기화 완료 후 큐 처리 및 화면 이동
- [ ] 컬렉션 공유 링크 생성 및 수신 처리

#### 데모 기준

> 컬렉션 생성 → 공유 링크 복사 → 외부에서 링크 열기 → 해당 컬렉션 바로 진입

---

### Week 6 — 로컬 캐시 & 성능 최적화

**목표:** 오프라인 지원 + 렌더링 성능 개선

#### 체크리스트

**로컬 캐시**

- [ ] Isar 스키마 정의 (CachedLink, SearchHistory, UserSettings)
- [ ] LinkLocalDataSource 구현 (R/W)
- [ ] Remote 실패 시 Local fallback 흐름 적용
- [ ] 즐겨찾기 Optimistic update → 실패 시 롤백

**성능 최적화**

- [ ] 링크 리스트 아이템 `const` 위젯화
- [ ] `cached_network_image` 썸네일 캐싱 적용
- [ ] Provider watch 범위 최소화 (불필요한 rebuild 제거)
- [ ] 긴 리스트 `ListView.builder` 확인
- [ ] 오프라인 상태 표시 UI (배너 / 토스트)

#### 데모 기준

> 비행기 모드 → 앱 실행 → 최근 링크 + 즐겨찾기 정상 표시

---

### Week 7 — 테스트 작성

**목표:** 핵심 레이어 테스트 커버리지 확보

#### Unit Test 대상

```dart
// UseCase 테스트 예시
test('CreateLinkUseCase — 정상 케이스', () async {
  when(() => mockRepository.createLink(any()))
      .thenAnswer((_) async => Right(tLink));
  
  final result = await useCase.execute(tParams);
  
  expect(result, Right(tLink));
  verify(() => mockRepository.createLink(tParams)).called(1);
});

test('CreateLinkUseCase — 네트워크 실패', () async {
  when(() => mockRepository.createLink(any()))
      .thenAnswer((_) async => Left(NetworkFailure()));
  
  final result = await useCase.execute(tParams);
  
  expect(result, Left(NetworkFailure()));
});
```

#### 체크리스트

**Unit Test**

- [ ] CreateLinkUseCase — 성공 / 실패 케이스
- [ ] FetchLinksUseCase — 성공 / 빈 목록 / 실패
- [ ] LinkRepositoryImpl — Remote 성공 시 Local 캐시 갱신 확인
- [ ] LinkMapper — DTO → Entity 변환 검증

**Widget Test**

- [ ] 로그인 화면 — 빈 폼 submit 시 validation 메시지
- [ ] 링크 추가 폼 — 잘못된 URL 입력 validation
- [ ] 링크 목록 — 로딩 / 데이터 / 에러 상태 렌더링

**Integration Test**

- [ ] 로그인 → 링크 저장 → 목록 반영 플로우
- [ ] 검색 → 결과 표시 → 상세 화면 진입 플로우
- [ ] 컬렉션 생성 → 링크 추가 → 공유 플로우

#### 데모 기준

> `flutter test --coverage` 실행 → 핵심 레이어 80% 이상 커버리지

---

### Week 8 — CI/CD & 마무리

**목표:** 자동화 파이프라인 완성 + 포트폴리오 패키징

#### 체크리스트

**GitHub Actions**

- [ ] `.github/workflows/ci.yml` 작성
- [ ] PR 생성 시 자동 실행: analyze → test → build APK
- [ ] `develop` 머지 시 Firebase App Distribution 자동 배포

**GitHub Actions 파이프라인 예시:**

```yaml
name: CI

on:
  push:
    branches: [develop, main]
  pull_request:
    branches: [develop]

jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'

      - name: Install dependencies
        run: flutter pub get

      - name: Analyze
        run: flutter analyze

      - name: Test
        run: flutter test --coverage

      - name: Build APK
        run: flutter build apk --release

      - name: Upload to Firebase App Distribution
        if: github.ref == 'refs/heads/develop'
        uses: wzieba/Firebase-Distribution-Github-Action@v1
        with:
          appId: ${{ secrets.FIREBASE_APP_ID }}
          token: ${{ secrets.FIREBASE_TOKEN }}
          groups: internal
          file: build/app/outputs/flutter-apk/app-release.apk
```

**문서화**

- [ ] README.md 작성 (프로젝트 소개, 기술 스택, 아키텍처 다이어그램, 실행 방법)
- [ ] 폴더 구조 다이어그램 README에 삽입
- [ ] 데이터 흐름 다이어그램 README에 삽입

**시연 영상**

- [ ] 핵심 유저 플로우 시연 영상 녹화 (GIF 또는 MP4)
  - 링크 저장 → 목록 조회 → 검색 → 컬렉션 → 딥링크
- [ ] GitHub README에 영상 / GIF 삽입

**배포**

- [ ] Google Play 내부 테스트 트랙 배포 (선택)
- [ ] GitHub Releases에 APK 첨부

#### 최종 데모 기준

> GitHub 방문 → README 확인 → Actions에서 CI 통과 이력 확인 → 영상으로 앱 흐름 파악 가능

---

## 3. Git 브랜치 전략

### 3.1 브랜치 구조

```
main          — 최종 릴리즈용 (태그 관리)
develop       — 통합 브랜치 (CI/CD 트리거)
feature/*     — 기능 개발
fix/*         — 버그 수정
chore/*       — 설정 변경, 리팩토링
```

### 3.2 브랜치 네이밍 예시

```
feature/auth-login
feature/link-crud
feature/search-debounce
feature/collection-share
feature/deep-link-cold-start
fix/link-thumbnail-parse-error
chore/add-github-actions-ci
```

### 3.3 PR 규칙

- PR 단위: 기능 하나 단위로 작게 유지
- PR 제목 형식: `[feat] 링크 저장 기능 구현`
- PR 생성 시 CI 자동 실행 확인
- self-review 후 merge

---

## 4. 커밋 컨벤션

### 4.1 형식

```
<type>: <subject>

<body> (선택)
```

### 4.2 Type 목록

| Type | 의미 |
|------|------|
| `feat` | 새 기능 |
| `fix` | 버그 수정 |
| `refactor` | 리팩토링 (기능 변경 없음) |
| `test` | 테스트 코드 추가/수정 |
| `chore` | 빌드, 설정, 의존성 변경 |
| `docs` | 문서 수정 |
| `style` | 코드 포맷, 세미콜론 등 (로직 변경 없음) |

### 4.3 예시

```
feat: URL OG 태그 자동 파싱 구현

- dio를 사용해 URL HEAD 요청 후 og:title, og:description, og:image 추출
- 파싱 실패 시 URL 도메인을 기본 제목으로 fallback 처리
```

```
fix: Cold Start 딥링크 미처리 버그 수정

앱 초기화 완료 전 딥링크 수신 시 화면 이동이 무시되는 문제를
큐 시스템 도입으로 해결
```

---

## 5. 코드 컨벤션

### 5.1 파일 네이밍

```
// 스크린
link_list_screen.dart
link_detail_screen.dart

// 위젯
link_card_widget.dart
tag_chip_widget.dart

// Provider
link_list_provider.dart
save_link_notifier.dart

// UseCase
fetch_links_use_case.dart
create_link_use_case.dart
```

### 5.2 Provider 선언 위치

- Provider는 해당 feature의 `presentation/provider/` 디렉토리에 위치
- 전역 DI provider는 `app/di/` 디렉토리에 위치

### 5.3 린트 설정

`analysis_options.yaml`:

```yaml
include: package:very_good_analysis/analysis_options.yaml

linter:
  rules:
    prefer_const_constructors: true
    prefer_const_widgets: true
    avoid_print: true
```

---

## 6. 면접 대비 Q&A

### Q. 왜 이 폴더 구조를 선택했나요?

> "기능이 늘어날 것을 고려해 Feature-first 구조를 선택했습니다. 기능 단위로 응집도를 높이고, 각 기능 내부는 data / domain / presentation으로 분리해 책임을 명확히 했습니다. 순수 레이어드 아키텍처보다 실무에서 유지보수하기 쉬운 형태라고 판단했습니다."

### Q. 왜 Riverpod을 썼나요?

> "의존성 주입과 테스트가 편하고, AsyncNotifier로 비동기 상태를 로딩/성공/실패로 명확하게 표현할 수 있어서 서비스 앱 구조에 적합하다고 판단했습니다. UI는 provider를 구독만 하고, 상태 변경은 notifier에서만 일어나도록 단방향 흐름을 유지했습니다."

### Q. 오프라인은 어떻게 처리했나요?

> "최근 조회 링크와 즐겨찾기를 Isar에 로컬 캐싱했습니다. 네트워크 실패 시 Local DataSource를 fallback으로 사용하고, 오프라인 상태임을 UI에 표시했습니다. 즐겨찾기 토글은 Optimistic update를 적용해 반응성을 높이고, 실패 시 롤백 처리했습니다."

### Q. 테스트는 어디까지 했나요?

> "UseCase와 Repository 레이어는 mocktail로 의존성을 mock해 단위 테스트를 작성했습니다. 로그인 validation, 리스트 렌더링은 위젯 테스트로, 핵심 사용자 플로우 3개는 integration test로 검증했습니다."

### Q. 이 프로젝트에서 가장 어려웠던 점은?

> "두 가지가 있었습니다. 첫째는 링크 저장 흐름에서 Remote/Local 상태를 일관되게 유지하는 부분이었습니다. Optimistic update 적용 후 실패 시 롤백 로직을 안정적으로 처리하는 데 공을 들였습니다. 둘째는 Cold Start 딥링크 처리였습니다. 앱 초기화 완료 전 딥링크가 수신될 때 화면 이동이 무시되는 문제를 큐 시스템으로 해결했습니다."

### Q. CI/CD는 어떻게 구성했나요?

> "GitHub Actions로 PR마다 flutter analyze, flutter test, build APK를 자동 실행하고, develop 브랜치 머지 시 Firebase App Distribution으로 내부 배포가 되도록 구성했습니다. 덕분에 매 PR에서 코드 품질을 자동으로 검증할 수 있었습니다."

---

## 7. README 구성 가이드

완성된 README에 포함해야 할 항목:

```
# LinkNote

[앱 시연 GIF]

## 소개
한 줄 설명

## 기술 스택
Flutter | Riverpod | go_router | Supabase | Isar | GitHub Actions

## 아키텍처
Feature-first + Clean Architecture 설명 + 폴더 구조 트리

## 주요 기능
- 링크 저장 (OG 자동 파싱)
- 태그/컬렉션 관리
- 오프라인 지원
- 딥링크 연동
- ...

## 데이터 흐름 다이어그램
[Mermaid 또는 이미지]

## CI/CD
GitHub Actions 파이프라인 설명 + badge

## 실행 방법
flutter pub get
flutter run

## 구현 포인트
(이력서 기재 내용과 동일하게)
```

---

*Workflow v1.0 — LinkNote Side Project*
