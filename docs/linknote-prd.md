# LinkNote — Product Requirements Document (PRD)

> **버전:** v1.0.0  
> **최종 수정:** 2026.03  
> **작성 목적:** Flutter 포트폴리오 사이드 프로젝트 — 연봉 6,000만원 이상 포지션 타겟

---

## 1. 프로젝트 개요

### 1.1 한 줄 소개

> 사용자가 웹 링크, 유튜브, 아티클, 메모를 저장하고 태그/컬렉션/검색으로 관리하며, 다른 사용자와 공유할 수 있는 모바일 북마크 서비스

### 1.2 왜 이 프로젝트인가

| 비교 항목 | 투두앱 | LinkNote | 커머스 앱 |
|-----------|--------|----------|-----------|
| 흔한 정도 | 매우 흔함 | 차별화 가능 | 덜 흔함 |
| 완성 가능성 | 높음 | **높음** | 낮음 |
| 아키텍처 어필 | 낮음 | **높음** | 높음 |
| Flutter 역량 커버리지 | 낮음 | **매우 높음** | 높음 |

### 1.3 포트폴리오 어필 포인트

이 프로젝트 하나로 다음 역량을 자연스럽게 증명한다.

- Flutter UI 설계 및 반응형 레이아웃
- Clean Architecture + Feature-first 폴더 구조
- Riverpod 기반 비동기 상태관리
- 로컬 캐싱 및 오프라인 fallback 전략
- 딥링크 / 공유 메뉴 네이티브 연동
- 단위 / 위젯 / 통합 테스트 작성
- GitHub Actions 기반 CI/CD 자동화

---

## 2. 타겟 사용자

### 2.1 페르소나

**주 타겟:** 정보 소비가 많은 직장인 / 개발자 / 크리에이터

- 브라우저 북마크가 지저분하게 쌓인 사람
- 유튜브/뉴스 링크를 메신저 나에게 보내기로 임시 저장하는 사람
- 좋은 아티클을 팀과 공유하고 싶은 사람

### 2.2 핵심 Pain Point

1. 저장한 링크를 나중에 찾을 수 없다
2. 플랫폼마다 흩어진 북마크를 한 곳에서 관리하기 어렵다
3. 관심사 기반으로 타인과 큐레이션을 공유할 수단이 없다

---

## 3. 기능 요구사항

### 3.1 MVP 기능 (Phase 1)

#### F01 — 인증

| ID | 기능 | 우선순위 |
|----|------|----------|
| F01-1 | 이메일/비밀번호 회원가입 및 로그인 | Must |
| F01-2 | 구글 소셜 로그인 | Should |
| F01-3 | JWT Access / Refresh Token 관리 | Must |
| F01-4 | 앱 시작 시 토큰 유효성 검사 및 자동 갱신 | Must |
| F01-5 | 로그아웃 / 회원탈퇴 | Must |

#### F02 — 링크 저장

| ID | 기능 | 우선순위 |
|----|------|----------|
| F02-1 | URL 직접 입력으로 저장 | Must |
| F02-2 | 제목 / 설명 / 썸네일 자동 파싱 (OG Tag) | Must |
| F02-3 | 태그 추가 / 수정 / 삭제 | Must |
| F02-4 | 폴더(컬렉션) 분류 | Must |
| F02-5 | 개인 메모 작성 | Should |
| F02-6 | 즐겨찾기 설정 | Should |

#### F03 — 링크 목록 / 조회

| ID | 기능 | 우선순위 |
|----|------|----------|
| F03-1 | 전체 저장 링크 목록 조회 | Must |
| F03-2 | 최신순 / 즐겨찾기 필터 | Must |
| F03-3 | 무한 스크롤 페이지네이션 | Must |
| F03-4 | 링크 상세 화면 | Must |
| F03-5 | 스켈레톤 로딩 UI | Should |

#### F04 — 검색

| ID | 기능 | 우선순위 |
|----|------|----------|
| F04-1 | 제목 키워드 검색 | Must |
| F04-2 | 태그 검색 | Must |
| F04-3 | 메모 내용 검색 | Could |
| F04-4 | 검색 결과 실시간 반영 (debounce 300ms) | Should |
| F04-5 | 최근 검색어 로컬 저장 | Should |

#### F05 — 컬렉션 (폴더 공유)

| ID | 기능 | 우선순위 |
|----|------|----------|
| F05-1 | 컬렉션 생성 / 수정 / 삭제 | Must |
| F05-2 | 컬렉션에 링크 추가 / 제거 | Must |
| F05-3 | 공개 / 비공개 설정 | Must |
| F05-4 | 다른 사용자 컬렉션 조회 | Should |
| F05-5 | 컬렉션 팔로우 | Could |

#### F06 — 알림

| ID | 기능 | 우선순위 |
|----|------|----------|
| F06-1 | 내 컬렉션 팔로우 알림 | Should |
| F06-2 | 내 링크 댓글 알림 | Could |
| F06-3 | 공유 초대 알림 | Could |
| F06-4 | FCM 기반 푸시 알림 | Should |

### 3.2 확장 기능 (Phase 2)

| ID | 기능 | 포트폴리오 임팩트 |
|----|------|-----------------|
| F07-1 | Android / iOS 공유 메뉴 연동 (외부 앱 → LinkNote) | **매우 높음** |
| F07-2 | 오프라인 캐시 및 즐겨찾기 fallback | 높음 |
| F07-3 | 딥링크를 통한 컬렉션/링크 직접 진입 | 높음 |
| F07-4 | 링크 열람 히스토리 | 중간 |
| F07-5 | 앱 아이콘 배지 (미읽 알림 수) | 중간 |
| F07-6 | 웹뷰 내 읽기 모드 | 낮음 |

> **Phase 2 우선 구현 추천:** F07-1 (공유 메뉴 연동) — 네이티브 이해도를 가장 강하게 어필할 수 있음

---

## 4. 기술 스택

### 4.1 Flutter 앱

| 분류 | 라이브러리 | 용도 |
|------|-----------|------|
| 상태관리 | `riverpod`, `flutter_riverpod` | 전역 상태 및 DI |
| 데이터 클래스 | `freezed`, `json_serializable` | 불변 모델, JSON 직렬화 |
| 라우팅 | `go_router` | 선언형 라우팅, 딥링크, 인증 가드 |
| 네트워크 | `dio`, `retrofit` | HTTP 통신, API 레이어 |
| 로컬 저장소 | `isar` (or `hive`) | 오프라인 캐시, 검색 히스토리 |
| 보안 저장소 | `flutter_secure_storage` | 토큰 보관 |
| 알림 | `firebase_messaging` | FCM 푸시 알림 |
| 모니터링 | `firebase_crashlytics`, `firebase_analytics` | 크래시 추적, 사용 분석 |

### 4.2 백엔드

**추천: Supabase**

- 선택 이유: 인증 / DB / 스토리지 / 실시간 이벤트를 단일 플랫폼으로 제공하여 개인 포트폴리오 구축 속도가 빠름
- 대안: Firebase / NestJS + PostgreSQL

### 4.3 테스트 / 품질

| 분류 | 도구 |
|------|------|
| 단위 / 위젯 테스트 | `flutter_test`, `mocktail` |
| 통합 테스트 | `integration_test` |
| 정적 분석 | `very_good_analysis` (or `flutter_lints`) |

### 4.4 CI/CD

| 단계 | 도구 |
|------|------|
| 파이프라인 | GitHub Actions |
| 빌드 배포 | Firebase App Distribution |
| 내부 배포 | `develop` 브랜치 머지 시 자동 트리거 |

---

## 5. 아키텍처

### 5.1 채택 구조

**Feature-first + Clean Architecture Lite**

> 완전한 교과서식 레이어드 아키텍처보다 실무형으로 가볍게 구성하되, 설계 의도가 면접에서 설명 가능한 수준으로 드러나는 구조

### 5.2 전체 폴더 구조

```
lib/
├── app/
│   ├── app.dart
│   ├── router/          # go_router 라우트 정의 및 인증 가드
│   ├── theme/           # 색상, 타이포그래피, 디자인 시스템
│   └── di/              # 의존성 주입 설정
│
├── core/
│   ├── network/         # Dio 클라이언트, 인터셉터
│   ├── error/           # 공통 예외 처리 (Failure, AppException)
│   ├── utils/           # 날짜, 문자열, 디바운스 등 유틸
│   ├── storage/         # Isar / SecureStorage 초기화
│   ├── logger/          # 로깅 래퍼
│   └── constants/       # 앱 전역 상수
│
├── shared/
│   ├── widgets/         # 재사용 공통 위젯
│   ├── extensions/      # Dart extension
│   └── models/          # 공유 데이터 모델
│
└── features/
    ├── auth/
    ├── link/
    ├── collection/
    ├── search/
    ├── notification/
    └── profile/
```

### 5.3 Feature 내부 구조 (link 예시)

```
features/link/
├── data/
│   ├── datasource/
│   │   ├── link_remote_data_source.dart   # Supabase API 호출
│   │   └── link_local_data_source.dart    # Isar 캐시 R/W
│   ├── dto/                               # API 응답 DTO
│   ├── mapper/                            # DTO → Entity 변환
│   └── repository/
│       └── link_repository_impl.dart
│
├── domain/
│   ├── entity/                            # 순수 비즈니스 객체
│   ├── repository/
│   │   └── link_repository.dart           # 인터페이스 정의
│   └── usecase/
│       ├── fetch_links_use_case.dart
│       ├── create_link_use_case.dart
│       ├── update_link_use_case.dart
│       └── delete_link_use_case.dart
│
└── presentation/
    ├── provider/          # Riverpod AsyncNotifier / Notifier
    ├── screen/            # 전체 화면 위젯
    └── widget/            # 화면 구성 단위 위젯
```

### 5.4 데이터 흐름 (링크 저장 예시)

```
SaveLinkScreen
  └─▶ SaveLinkNotifier.submit()
        └─▶ CreateLinkUseCase.execute()
              └─▶ LinkRepository.createLink()
                    ├─▶ RemoteDataSource.create()  →  Supabase insert
                    └─▶ LocalDataSource.cache()    →  Isar write
                          └─▶ Provider state 갱신  →  UI 반영
```

---

## 6. 상태관리 전략 (Riverpod)

### 6.1 Provider 종류별 용도

| Provider 타입 | 사용 케이스 |
|---------------|------------|
| `AsyncNotifier` | 링크 목록, 검색 결과, 프로필 조회 |
| `Notifier` | 필터 상태, 정렬 상태, 선택 상태 |
| `Provider` | Repository, DataSource, Service (DI) |
| `StateProvider` | 일회성 UI 상태 |
| `FutureProvider` | 단건 가벼운 조회 |

### 6.2 링크 목록 화면 상태 흐름

```
LinkListScreen
  ├── filterStateProvider       (Notifier)   — 필터 조건 (즐겨찾기/전체)
  ├── sortStateProvider         (StateProvider) — 정렬 기준
  └── linkListProvider          (AsyncNotifier) — 링크 목록 fetch
        ├── 성공 → 데이터 렌더링
        ├── 로딩 → Skeleton UI
        └── 실패 → Local fallback → 에러 UI
```

> "UI는 Riverpod provider를 구독만 하고, 비즈니스 상태 변경은 notifier에서 일어나도록 구성했습니다."

---

## 7. 인증 설계

### 7.1 토큰 관리 흐름

```
앱 시작
  └─▶ SecureStorage에서 Access Token 확인
        ├── 유효 → 홈 화면 진입
        ├── 만료 → Refresh Token으로 갱신
        │     ├── 성공 → 홈 화면 진입
        │     └── 실패 → 로그인 화면 이동 (토큰 삭제)
        └── 없음 → 로그인 화면 이동
```

### 7.2 API 인터셉터 전략

- `AuthInterceptor` — 모든 요청에 Authorization 헤더 자동 첨부
- 401 응답 시 토큰 갱신 후 원본 요청 재시도
- 갱신 실패 시 로그인 화면으로 강제 이동

---

## 8. 라우팅 설계 (go_router)

### 8.1 라우트 목록

| 경로 | 화면 | 인증 필요 |
|------|------|----------|
| `/` | Splash | - |
| `/login` | 로그인 | ✗ |
| `/signup` | 회원가입 | ✗ |
| `/home` | 홈 (링크 목록) | ✓ |
| `/link/add` | 링크 추가 | ✓ |
| `/link/:id` | 링크 상세 | ✓ |
| `/search` | 검색 | ✓ |
| `/collection` | 컬렉션 목록 | ✓ |
| `/collection/:id` | 컬렉션 상세 | ✓ |
| `/notification` | 알림 | ✓ |
| `/profile` | 프로필 | ✓ |
| `/settings` | 설정 | ✓ |

### 8.2 인증 가드

```dart
redirect: (context, state) {
  final isLoggedIn = ref.read(authProvider).isAuthenticated;
  final isAuthRoute = ['/login', '/signup'].contains(state.location);
  
  if (!isLoggedIn && !isAuthRoute) return '/login';
  if (isLoggedIn && isAuthRoute) return '/home';
  return null;
}
```

### 8.3 딥링크 처리

- `linknote://collection/:id` — 특정 컬렉션 바로 진입
- `linknote://link/:id` — 특정 링크 상세 바로 진입
- Cold Start 시 딥링크 큐 시스템으로 초기화 완료 후 처리

---

## 9. 로컬 저장소 전략

### 9.1 저장 데이터 분류

| 데이터 | 저장소 | 전략 |
|--------|--------|------|
| Access / Refresh Token | SecureStorage | 암호화 보관 |
| 최근 본 링크 (최대 50개) | Isar | Remote 우선, 실패 시 fallback |
| 즐겨찾기 링크 | Isar | Optimistic update |
| 검색 히스토리 (최대 20개) | Isar | 로컬 전용 |
| 사용자 설정 (테마, 정렬) | Isar | 로컬 전용 |

### 9.2 캐시 전략

```
Remote DataSource 우선 호출
  ├── 성공 → Local DataSource 업데이트 → UI 반영
  └── 실패 → Local DataSource 조회 → UI 반영 (오프라인 표시)
```

---

## 10. DB 스키마 (Supabase)

```sql
-- 사용자
users (id, email, nickname, profile_image_url, created_at)

-- 링크
links (id, user_id, url, title, description, thumbnail_url, memo, is_favorite, created_at, updated_at)

-- 태그
tags (id, name)
link_tags (id, link_id, tag_id)

-- 컬렉션
collections (id, user_id, title, description, visibility, created_at)
collection_links (id, collection_id, link_id)
collection_follows (id, follower_id, collection_id, created_at)

-- 알림
notifications (id, user_id, type, target_id, is_read, created_at)
```

---

## 11. 성능 최적화 전략

| 항목 | 적용 방법 |
|------|----------|
| 긴 리스트 렌더링 | `ListView.builder` |
| 불필요한 rebuild 방지 | `const` 위젯, provider 범위 최소화 |
| 이미지 캐싱 | `cached_network_image` |
| 검색 입력 최적화 | debounce 300ms |
| 페이지네이션 | cursor 기반 무한 스크롤 |
| 로딩 UX | Skeleton loading |

---

## 12. 테스트 전략

### 12.1 테스트 범위

| 레이어 | 테스트 종류 | 대상 |
|--------|-----------|------|
| Domain | Unit Test | UseCase, Repository interface |
| Data | Unit Test | Mapper, DataSource mock |
| Presentation | Widget Test | 로그인 validation, 리스트 렌더링 |
| E2E | Integration Test | 로그인→저장→목록 반영, 검색→상세 |

### 12.2 면접 설명 포인트

> "비즈니스 로직은 UseCase와 Repository 중심으로 단위 테스트를 작성했고, 핵심 사용자 플로우는 integration test로 검증했습니다."

---

## 13. 화면 목록

| 화면 | 설명 |
|------|------|
| Splash | 토큰 확인 및 분기 |
| Login / Signup | 이메일 + 구글 로그인 |
| Home | 링크 전체 목록, 필터, 탭 네비게이션 |
| Link Add / Edit | URL 입력, 메타 자동 파싱, 태그 추가 |
| Link Detail | 저장된 링크 상세 정보 |
| Search | 실시간 검색, 최근 검색어 |
| Collection List | 컬렉션 목록 |
| Collection Detail | 컬렉션 내 링크 목록, 공유 |
| Notification | 팔로우 / 댓글 알림 |
| Profile / Settings | 사용자 정보, 테마, 로그아웃 |

### 탭 네비게이션 구성

```
하단 탭: [ 홈 | 검색 | 컬렉션 | 알림 | 프로필 ]
```

---

## 14. 이력서 기재 예시

**LinkNote | Flutter 기반 링크 저장/공유 서비스 앱 (개인 프로젝트)**

관심 콘텐츠를 저장하고 태그/컬렉션/검색으로 관리하며, 사용자 간 공유가 가능한 모바일 앱 설계 및 구현

**기술 스택:** Flutter, Riverpod, go_router, Dio, Freezed, Supabase, Isar, Firebase Messaging, GitHub Actions

**구현 포인트:**

- Feature-first + Clean Architecture 기반 구조 설계로 기능 확장성 확보
- Riverpod AsyncNotifier를 활용한 비동기 상태관리 및 화면별 상태 분리
- Remote/Local 이중 데이터 레이어로 오프라인 환경에서도 최근 조회 및 즐겨찾기 지원
- GitHub Actions 기반 analyze / test / build APK 자동화 파이프라인 구축
- Android / iOS 공유 메뉴 연동으로 외부 앱에서 직접 링크 저장 기능 구현
- Unit / Widget / Integration Test 작성으로 핵심 사용자 플로우 검증

---

*PRD v1.0 — LinkNote Side Project*
