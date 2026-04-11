# 다음 세션 프롬프트

아래 내용을 그대로 붙여넣기해서 다음 세션을 시작하세요.

---

```
Session 13 — CI 수정 완료, 다음 단계 선택

## 배경
- 보안 감사 10/10건 전체 수정 완료.
- UI/UX 개선 전체 완료 (Phase 1 + Phase 2).
- Search 기능 보강 완료 (필터/히스토리/자동완성).
- 릴리즈 준비 Phase 1 완료 (앱 아이콘, 스플래시, ProGuard, 메타데이터 통일).
- Session 12에서 CI dart format 체크 실패 수정 완료 (34개 테스트 파일).
- 현재 315 테스트 ALL GREEN, flutter analyze 0 errors (31 info).
- Firebase는 아직 미연결 (flutterfire configure 미실행).

## Firebase 상태 (차후 진행)
- pubspec.yaml에 firebase_core/analytics/crashlytics/messaging 선언됨
- firebase_options.dart, google-services.json, GoogleService-Info.plist 미생성
- main.dart에 Crashlytics 연동 코드 주석으로 준비 완료
- Firebase 프로젝트 생성 + flutterfire configure 실행 → 주석 해제로 즉시 활성화 가능

## 남은 TODO
- lib/main.dart:10,21 — Firebase 초기화 (flutterfire configure 후)
- 플레이스홀더 앱 아이콘을 실제 디자인 아이콘으로 교체
- Release signing 설정 (keystore 생성 필요)
- 빌드 플레이버 분리 (dev/staging/production)
- README.md 포트폴리오용 완성 (아키텍처 다이어그램, 시연 GIF)
- GitHub Actions CI 결과 재확인 (Session 12 dart format 수정 push 후)

## 가능한 다음 작업 (사용자 선택)

### Option A: GitHub Actions CI 결과 확인
- Session 12 push 후 CI 워크플로우 재실행 결과 확인
- 실패 시 수정, 성공 시 다음 단계로

### Option B: 빌드 플레이버 + Release Signing
- dev/staging/prod 플레이버 분리
- envied 환경변수 플레이버별 분리
- Release keystore 생성 + signingConfigs 설정

### Option C: 추가 UI/UX 개선
- 플레이스홀더 아이콘을 실제 디자인 아이콘으로 교체
- 빈 상태 일러스트에 Lottie 애니메이션 적용
- 카드/리스트 아이템 스와이프 제스처 (삭제/즐겨찾기)
- 링크 카드에 OG 이미지 썸네일 표시

### Option D: Firebase 연결
- Firebase 프로젝트 생성 후 flutterfire configure 실행
- Crashlytics, Analytics, Messaging 초기화
- GoRouter에 Analytics observer 연결

### Option E: 오프라인 지원 강화
- 링크 생성/수정의 오프라인 큐 (Connectivity + 재시도)
- Hive ↔ Supabase 동기화 충돌 해결 전략

### Option F: README 포트폴리오 완성
- 프로젝트 소개, 기술 스택, 아키텍처 다이어그램
- 주요 기능 설명 + 시연 GIF/스크린샷
- CI/CD 파이프라인 설명 + badge
- 면접 대비 핵심 포인트

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
