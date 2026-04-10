# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-04-10

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
