# 다음 세션 프롬프트

아래 내용을 그대로 붙여넣기해서 다음 세션을 시작하세요.

---

```
Session 6 — Search 보강 완료 후 다음 단계

## 배경
- 보안 감사 P0(3)+P1(4)+P2(3) = 10/10건 전체 수정 완료.
- UI/UX 개선 완료 (에러 한글화, 스켈레톤, Pull-to-Refresh 등).
- Search 기능 보강 (Option B) 완료:
  - SearchFilterEntity: 태그/즐겨찾기/날짜범위 필터 (Freezed)
  - SearchHistoryLocalDataSource: Hive settings 박스에 최근 검색어 JSON 저장 (최대 10개)
  - 서버 필터: Supabase 쿼리 체이닝 (favorites, dateFrom, dateTo)
  - 클라이언트 태그 필터: PostgREST 제한으로 repository에서 로컬 필터링
  - UserTagsProvider: Supabase tags 테이블 전체 조회
  - SearchSuggestionsProvider: 최근 검색어 + 태그 prefix 매칭 (최대 8개)
  - SearchFilterBar: 수평 스크롤 FilterChip (즐겨찾기/날짜/태그/초기화)
  - SearchSuggestionsListWidget: 자동완성 리스트 (시계/태그 아이콘)
  - SearchScreen UI 한글화 + 필터바/추천 통합
- Firebase는 아직 미연결 (flutterfire configure 미실행, 차후 진행).
- 현재 303 테스트 ALL GREEN, flutter analyze 0 errors.
- 이전 세션(보안감사+UI/UX 개선)의 미커밋 변경사항이 working tree에 남아 있음.

## 미커밋 변경사항 (이전 세션)
- lib/core/*, lib/features/auth/*, lib/features/collection/*, lib/features/link/*,
  lib/features/notification/*, lib/features/profile/*, lib/main.dart,
  lib/shared/widgets/*, android/*, ios/*, CLAUDE.md, .github/workflows/ci.yml 등
- 보안 감사 수정 + UI/UX 개선 + 테스트 보강 내용
- `git status`로 확인 후 커밋 필요

## Firebase 상태 (차후 진행)
- pubspec.yaml에 firebase_core/analytics/crashlytics/messaging 선언됨
- firebase_options.dart, google-services.json, GoogleService-Info.plist 미생성
- main.dart에 Crashlytics 연동 코드 주석으로 준비 완료
- Firebase 프로젝트 생성 + flutterfire configure 실행 → 주석 해제로 즉시 활성화 가능

## 남은 TODO
- lib/main.dart:10,21 — Firebase 초기화 (flutterfire configure 후)
- 이전 세션 미커밋 변경사항 정리 및 커밋

## Search 보강 시 알게 된 사항
- PostgREST는 nested join 테이블 필터링 미지원 → 태그 필터는 클라이언트 사이드
- Hive settings 박스는 Box<String> → JSON encode/decode로 List 저장
- SearchStateEntity에 @Default 필드 추가 시 기존 const 생성자 호환 유지됨
- Riverpod code gen 프로바이더의 mock 테스트 시 named parameter에 registerFallbackValue 필요

## 가능한 다음 작업 (사용자 선택)

### Option A: 미커밋 변경사항 정리 + 커밋
- 이전 세션(보안감사+UI/UX)의 변경사항을 기능별로 분리 커밋
- git status 확인 후 논리적 단위로 정리

### Option B: E2E 통합 테스트
- Supabase 실제 연결 후 주요 플로우 (로그인 → 링크 저장 → 검색 → 로그아웃) 테스트
- Integration test 작성 (flutter_test + integration_test)

### Option C: 오프라인 지원 강화
- 링크 생성/수정의 오프라인 큐 (Connectivity + 재시도)
- Hive ↔ Supabase 동기화 충돌 해결 전략

### Option D: Firebase 연결
- Firebase 프로젝트 생성 후 flutterfire configure 실행
- Crashlytics, Analytics, Messaging 초기화
- GoRouter에 Analytics observer 연결

### Option E: 추가 UI/UX 개선
- SnackBar/Toast 통합 시스템 (성공/실패/정보 3가지 스타일)
- 빈 상태 일러스트/Lottie 애니메이션
- 다크/라이트 테마 전환 애니메이션

### Option F: Search 추가 보강
- 검색 결과 페이지네이션 (현재 limit 50 하드코딩)
- 검색 결과 정렬 옵션 (최신순/관련순)
- 검색 필터 상태 URL 파라미터 반영 (deep link)

## 수정하지 않는 것
- 기존 보안 수정 사항 롤백
- 아키텍처 패턴 변경 (Clean Architecture + Riverpod 유지)
- ErrorStateWidget.fromError() 패턴 변경 (통일된 에러 UI)
- Search 필터/히스토리 기본 패턴 변경

## 완료 기준
- flutter analyze 0 errors
- flutter test ALL GREEN (303+)
- 커밋 + 푸시 (사용자 승인 후)
```
