# 다음 세션 프롬프트

아래 내용을 그대로 붙여넣기해서 다음 세션을 시작하세요.

---

```
P1/P2 작업 커밋 + 푸시 후 다음 단계 진행

## 배경
- 2026-04-10 세션에서 P0(Domain UseCase 100%), P1(Profile/Notification data layer), P2(OgTagService 캐싱 + 유틸리티/Repository 테스트 8파일) 전체 완료.
- 현재 미커밋 변경 29개 파일 누적 (P1 소스 + P2 테스트 + 생성파일).
- flutter analyze 0 errors, flutter test 162 ALL GREEN 확인 완료.
- 메모리: project_code_review_roadmap.md 참조 (P0~P2 완료 상태).

## Step 1: 커밋 + 푸시
미커밋 변경사항을 의미 단위로 커밋:
1. P1 커밋: Profile/Notification data layer 구현 (소스 + DI + provider 수정 + 생성파일)
2. P2 커밋: OgTagService 캐싱 + Core/Extension/Repository 테스트 8파일
3. daily task log 커밋
4. 전체 `git push origin main`

커밋 전 `flutter analyze` + `flutter test` 재검증.

## Step 2: 다음 작업 논의
커밋 완료 후, 아래 후보 중 우선순위를 정해서 구현:
- Widget 테스트 보강 (커버리지 70% 목표)
- E2E 테스트 (critical user flow)
- 새 기능 개발 (사용자 요구사항 대기)
- CI/CD 파이프라인 정상 동작 확인
```
