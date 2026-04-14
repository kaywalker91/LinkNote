# 다음 세션 프롬프트

아래 내용을 그대로 붙여넣기해서 다음 세션을 시작하세요.

---

```
Session 31 — Wave 4 P2/P3 수정 + Collection 테스트 갭 보강

## 미션 한 줄

Wave 4 리뷰의 남은 P2/P3 6건을 수정하고 `collection_remote_datasource_test.dart` 부재 갭을 메운다.

## 배경

Session 30에서:
- Wave 4 P0/P1 4건 완전 수정 + PR 머지 완료
- 앱 아이콘 & 스플래시 신규 브랜드 디자인으로 교체 (Galaxy A34 실기기 QA 통과)
- 베이스라인: **385 tests GREEN**, analyze 0 issues

남은 Wave 4 항목 (`docs/review/wave4_collection_review.md`):
- **P2-A**: `collection_mapper.dart` linkCount single 가정 (array 대응)
- **P2-B**: CollectionDetail provider 로컬 폴백 부재
- **P2-C**: Collection 삭제 UX (확인 다이얼로그 / undo)
- **P2-D**: 관련 provider invalidate 누락 (create/delete 시 detail/links)
- **P3-A**: form success snackbar 오발화 관련 정리 (이미 P1-C에서 부분 해결 — 잔존 검증)
- **P3-B**: `items.firstWhere` throw 가드 (updateCollection notFound 케이스)

추가 테스트 갭:
- `test/features/collection/data/datasource/collection_remote_datasource_test.dart` 신규 작성 (Supabase client mock)
- `test/features/collection/presentation/provider/collection_detail_provider_test.dart`

## 가장 먼저 할 일 (순서 엄수)

### 0. 상태 확인
```bash
cd ~/AndroidStudioProjects/LinkNote
git status && git log --oneline -5
flutter analyze --fatal-warnings
flutter test --reporter compact 2>&1 | tail -3   # 385 GREEN 확인
```

### 1. 브랜치
```bash
git checkout -b fix/wave4-p2-p3-and-tests
```

### 2. TDD 순서 (RED → GREEN)
1. P3-B `firstWhere` 가드 → 단위 테스트 선행
2. P2-A linkCount array 대응 → `collection_mapper_test.dart` 케이스 추가
3. P2-B detail 로컬 폴백 → repository 레이어에 폴백 추가 + 테스트
4. P2-D invalidate 누락 → provider 테스트 선행 (ref.invalidate verify)
5. P2-C 삭제 UX → 위젯 테스트 선행 (AlertDialog / undo snackbar)
6. `collection_remote_datasource_test.dart` 신규 — Supabase client를 mocktail 또는 fake supabase로 mock
7. `collection_detail_provider_test.dart` 신규

### 3. 게이트 / 커밋 / PR
- `flutter analyze --fatal-warnings` 0 / `flutter test` 385 + N GREEN
- CHANGELOG + daily_log + next_session + memory 업데이트
- **코드 + docs 한 PR로 묶음** (docs-only 단독 PR 금지)
- git push는 사용자 승인 필수, CI 4 job green 후 머지

## 불변 원칙

- **git push / merge 사용자 명시 승인 필수**
- **Branch Protection 활성화** — PR + CI 4 job green 필수
- **TDD RED → GREEN** 준수
- `.env`, keystore, Firebase service account key 커밋 금지
- provider 에러는 `Error.throwWithStackTrace(failure, StackTrace.current)` 패턴 사용

## 참조 문서

- **Wave 4 리뷰**: `docs/review/wave4_collection_review.md`
- **Session 30 로그**: `docs/daily_task_log/2026-04-16_session30.md`
- **RLS 정책**: `docs/security/rls_policies.md` (Session 30 신설)

## 세션 경계

P2/P3 수정 + 테스트 갭 보강 PR 머지까지. 아키텍처 리팩터나 다른 feature의 Wave 5 리뷰는 Session 32에서.
```
