# 다음 세션 프롬프트

아래 내용을 그대로 붙여넣기해서 다음 세션을 시작하세요.

---

```
Phase 6 구현 — Search 보강 + Firebase 초기화

## 배경
- Phase 5 완료: Collection-Link 실 연동 (collectionLinksProvider → FetchLinksUsecase). 283 테스트 ALL GREEN.
- `_mapToEntity` 잠재 버그 수정 완료 (Link + Collection 양쪽 모두 `on Object`).
- 현재 남은 TODO 1개:
  1. `lib/main.dart:14` — Firebase 초기화

## 목표
1. Firebase 초기화 연결 (Firebase Core, Messaging, Crashlytics, Analytics)
2. Search 기능 보강 (선택적)

## 구현 범위

### Step 1: 리서치 (Stage 1)
- Firebase 초기화 코드 현재 상태 확인 (`lib/main.dart`)
- Firebase 관련 설정 파일 (google-services.json, GoogleService-Info.plist) 존재 확인
- Search 기능 현재 상태: SearchRemoteDataSource Supabase full-text search vs ilike 확인

### Step 2: 플랜 (Stage 2)
- Firebase 초기화 순서 및 에러 핸들링 설계
- Search 보강 범위 확정

### Step 3: 피드백 (Stage 3)
- 사용자 승인 후 구현

### Step 4: 구현 (Stage 4)
- 플랜대로 기계적 실행

## 수정하지 않는 것
- 인증 플로우 변경
- 새로운 feature 추가

## 완료 기준
- Firebase 초기화 성공 (앱 시작 시 크래시 없음)
- flutter analyze 0 errors
- flutter test ALL GREEN
- 커밋 + 푸시 (사용자 승인 후)
```
