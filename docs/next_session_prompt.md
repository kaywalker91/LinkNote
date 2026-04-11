# 다음 세션 프롬프트

아래 내용을 그대로 붙여넣기해서 다음 세션을 시작하세요.

---

```
Session 7 — UI/UX 추가 개선 완료 후 다음 단계

## 배경
- 보안 감사 P0(3)+P1(4)+P2(3) = 10/10건 전체 수정 완료.
- UI/UX 개선 완료:
  - Phase 1: 에러 한글화, 세션 만료 UX, 스켈레톤, Pull-to-Refresh (세션 #7)
  - Phase 2: SnackBar 통합(success/error/info), 빈 상태 일러스트, 테마 전환 애니메이션 (세션 #9)
- Search 기능 보강 완료 (필터/히스토리/자동완성).
- Firebase는 아직 미연결 (flutterfire configure 미실행, 차후 진행).
- 현재 315 테스트 ALL GREEN, flutter analyze 0 errors.
- git status clean (미커밋 변경사항: 세션 #9 UI/UX 개선분).

## 세션 #9 변경사항 (미커밋)
- lib/shared/widgets/app_snack_bar.dart (신규) — SnackBar 통합 시스템
- lib/shared/widgets/empty_state_illustration.dart (신규) — 빈 상태 일러스트
- lib/shared/extensions/context_extensions.dart — showSuccess/Error/InfoSnackBar extension
- lib/shared/widgets/empty_state_widget.dart — illustration parameter 추가
- lib/app/app.dart — 테마 전환 애니메이션 (300ms easeInOut)
- lib/features/auth/presentation/screens/login_screen.dart — SnackBar 통합 교체
- lib/features/auth/presentation/screens/signup_screen.dart — SnackBar 통합 교체
- lib/features/link/presentation/screens/link_add_screen.dart — 저장 성공 SnackBar
- lib/features/link/presentation/screens/link_edit_screen.dart — 수정 성공 SnackBar
- lib/features/link/presentation/screens/home_screen.dart — 삭제 성공 SnackBar + 일러스트
- lib/features/collection/presentation/screens/collection_form_screen.dart — 생성/수정 성공 SnackBar
- lib/features/collection/presentation/screens/collection_detail_screen.dart — 삭제 성공 SnackBar + 일러스트
- lib/features/collection/presentation/screens/collection_list_screen.dart — 일러스트
- lib/features/search/presentation/screens/search_screen.dart — 일러스트 (2곳)
- test/shared/widgets/app_snack_bar_test.dart (신규, 6 GREEN)
- test/shared/widgets/empty_state_illustration_test.dart (신규, 7 GREEN)

## Firebase 상태 (차후 진행)
- pubspec.yaml에 firebase_core/analytics/crashlytics/messaging 선언됨
- firebase_options.dart, google-services.json, GoogleService-Info.plist 미생성
- main.dart에 Crashlytics 연동 코드 주석으로 준비 완료
- Firebase 프로젝트 생성 + flutterfire configure 실행 → 주석 해제로 즉시 활성화 가능

## 남은 TODO
- lib/main.dart:10,21 — Firebase 초기화 (flutterfire configure 후)
- 세션 #9 변경사항 커밋

## 가능한 다음 작업 (사용자 선택)

### Option A: 미커밋 변경사항 정리 + 커밋
- 세션 #9 (UI/UX 개선)의 변경사항을 커밋
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

### Option E: Search 추가 보강
- 검색 결과 페이지네이션 (현재 limit 50 하드코딩)
- 검색 결과 정렬 옵션 (최신순/관련순)
- 검색 필터 상태 URL 파라미터 반영 (deep link)

### Option F: 추가 UI/UX 개선
- 빈 상태 일러스트에 Lottie 애니메이션 적용
- 다크/라이트 테마 전환 토글 (설정 화면에 미리보기)
- 카드/리스트 아이템 스와이프 제스처 (삭제/즐겨찾기)
- 링크 카드에 OG 이미지 썸네일 표시

### Option G: 앱 폴리싱 + 릴리즈 준비
- 앱 아이콘 + 스플래시 스크린 설정
- 앱 이름/설명 메타데이터 최종 정리
- ProGuard/R8 난독화 설정 (Android)
- 빌드 플레이버 (dev/staging/production) 분리

## 수정하지 않는 것
- 기존 보안 수정 사항 롤백
- 아키텍처 패턴 변경 (Clean Architecture + Riverpod 유지)
- ErrorStateWidget.fromError() 패턴 변경 (통일된 에러 UI)
- Search 필터/히스토리 기본 패턴 변경
- SnackBar 통합 시스템 패턴 변경 (AppSnackBar + context extension)

## 완료 기준
- flutter analyze 0 errors
- flutter test ALL GREEN (315+)
- 커밋 + 푸시 (사용자 승인 후)
```
