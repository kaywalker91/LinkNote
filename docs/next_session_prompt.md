# 다음 세션 프롬프트

아래 내용을 그대로 붙여넣기해서 다음 세션을 시작하세요.

---

```
Session 11 — 릴리즈 준비 Phase 1 완료, 다음 단계 선택

## 배경
- 보안 감사 P0(3)+P1(4)+P2(3) = 10/10건 전체 수정 완료.
- UI/UX 개선 전체 완료 (Phase 1 + Phase 2).
- Search 기능 보강 완료 (필터/히스토리/자동완성).
- 릴리즈 준비 Phase 1 완료 (세션 #10):
  - 앱 이름 통일: Android/iOS 모두 "LinkNote"
  - flutter_launcher_icons 설정 + 플레이스홀더 아이콘 생성 (단색 #4A90D9)
  - flutter_native_splash 설정 + 스플래시 화면 생성
  - ProGuard/R8 설정 (isMinifyEnabled + isShrinkResources)
  - assets/images/ 디렉토리 구성
- Firebase는 아직 미연결 (flutterfire configure 미실행, 차후 진행).
- 현재 315 테스트 ALL GREEN, flutter analyze 0 errors.
- 미푸시 커밋 있음 (사용자 승인 필요).

## Firebase 상태 (차후 진행)
- pubspec.yaml에 firebase_core/analytics/crashlytics/messaging 선언됨
- firebase_options.dart, google-services.json, GoogleService-Info.plist 미생성
- main.dart에 Crashlytics 연동 코드 주석으로 준비 완료
- Firebase 프로젝트 생성 + flutterfire configure 실행 → 주석 해제로 즉시 활성화 가능

## 남은 TODO
- lib/main.dart:10,21 — Firebase 초기화 (flutterfire configure 후)
- 미푸시 커밋 push (사용자 승인 필요)
- 플레이스홀더 앱 아이콘을 실제 디자인 아이콘으로 교체
- Release signing 설정 (keystore 생성 필요)
- 빌드 플레이버 분리 (dev/staging/production)

## 가능한 다음 작업 (사용자 선택)

### Option A: git push
- 미푸시 커밋을 origin/main에 push
- CI 통과 확인

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

### Option E: 빌드 플레이버 + Release Signing
- dev/staging/prod 플레이버 분리
- envied 환경변수 플레이버별 분리
- Release keystore 생성 + signingConfigs 설정

### Option F: 추가 UI/UX 개선
- 플레이스홀더 아이콘을 실제 디자인 아이콘으로 교체
- 빈 상태 일러스트에 Lottie 애니메이션 적용
- 카드/리스트 아이템 스와이프 제스처 (삭제/즐겨찾기)
- 링크 카드에 OG 이미지 썸네일 표시

## 수정하지 않는 것
- 기존 보안 수정 사항 롤백
- 아키텍처 패턴 변경 (Clean Architecture + Riverpod 유지)
- ErrorStateWidget.fromError() 패턴 변경 (통일된 에러 UI)
- Search 필터/히스토리 기본 패턴 변경
- SnackBar 통합 시스템 패턴 변경 (AppSnackBar + context extension)
- ProGuard/R8 설정 비활성화

## 완료 기준
- flutter analyze 0 errors
- flutter test ALL GREEN (315+)
- 커밋 + 푸시 (사용자 승인 후)
```
