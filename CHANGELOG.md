# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.1] - 2026-04-11

### Fixed

- CI `dart format --set-exit-if-changed` 체크 실패 수정 (34개 테스트 파일 포맷 정리)

## [1.1.0] - 2026-04-11

### Added

- **보안 감사**: P0(3)+P1(4)+P2(3) = 10/10건 전체 수정 완료
  - AuthInterceptor 401 처리, signOut 캐시 정리, 글로벌 에러 핸들러
- **UI/UX 개선 Phase 1**: 에러 메시지 한글화, 세션 만료 UX, 스켈레톤 로더, Pull-to-Refresh
- **UI/UX 개선 Phase 2**: SnackBar 통합 시스템, 빈 상태 일러스트, 테마 전환 애니메이션
- **Search 보강**: 태그/날짜/즐겨찾기 필터, Hive 히스토리 영속화, 자동완성
- **릴리즈 준비 Phase 1**: 앱 아이콘, 스플래시 화면, ProGuard/R8, 메타데이터 통일
- **Testing**: 52개 → 315개 테스트 (Widget 16파일 + CollectionLocalDataSource + Search 등)

### Changed

- Android 패키지명 통일 + iOS 설정 업데이트
- info-level lint 이슈 104개 → 31개로 감소
- `flutter analyze` 0 errors 유지

## [1.0.0] - 2026-04-10

### Added

- **Auth**: Supabase 이메일 회원가입/로그인, 자동 토큰 관리, 세션 검증
- **Link CRUD**: 링크 저장/조회/수정/삭제, OG 태그 자동 파싱, cursor 기반 무한 스크롤
- **Favorites**: 즐겨찾기 토글 (Optimistic update + 실패 시 롤백)
- **Collections**: 컬렉션 CRUD, 링크 수 서브쿼리, 로컬 캐싱
- **Search**: Supabase full-text search (tsvector), debounce 검색, 최근 검색어
- **Offline**: Hive CE 로컬 캐싱, Remote-First/Local-Fallback 패턴
- **Deep Link**: `linknote://` 스킴 (Android intent-filter + iOS CFBundleURLSchemes)
- **UI**: 5탭 네비게이션, Light/Dark 테마 (Material 3), 20+ 공유 위젯
- **Testing**: 60개 테스트 (Unit 16 + Widget 25 + Integration 19)
- **CI/CD**: GitHub Actions 4-job 파이프라인 (analyze, test, build, security)

### Architecture

- Feature-first + Clean Architecture (presentation → domain → data)
- Riverpod 3.x 코드 생성 기반 상태 관리
- `Result<T>` + `Failure` sealed class 타입 안전 에러 처리
- GoRouter 선언적 라우팅 + 인증 가드
