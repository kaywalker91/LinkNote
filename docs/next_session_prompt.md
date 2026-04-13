# 다음 세션 프롬프트

아래 내용을 그대로 붙여넣기해서 다음 세션을 시작하세요.

---

```
Session 26 — Wave 2 P0/P1 수정 구현

## 미션 한 줄

Wave 2 코드 리뷰 보고서(docs/code_review/2026-04-13_wave2_core.md)의 P0 4건 + P1 8건을 수정 구현한다.

## 배경

Session 25(2026-04-13)에서 Wave 2 코드 리뷰 완료. 25건 발견 (P0:4, P1:8, P2:7, P3:6). 보고서 PR 머지 완료 상태.

현재 상태:
- **main HEAD**: Wave 2 보고서 PR 머지 후 커밋
- **Branch Protection 활성화** — PR + CI green 경로 필수
- **353+ tests GREEN, analyze 0**

## 가장 먼저 할 일 (순서 엄수)

### 0. 현재 상태 확인
```bash
git status && git log --oneline -5
flutter analyze && flutter test
```

### 1. 보고서 읽기
```bash
cat docs/code_review/2026-04-13_wave2_core.md
```

### 2. P0 수정 (4건 — 최우선)

**P0-A: Clean Arch — SignOutUsecase → IClearableCache 인터페이스**
- Domain에 `IClearableCache` 인터페이스 정의
- 3개 LocalDataSource가 implements
- SignOutUsecase는 `List<IClearableCache>` 주입

**P0-B: Clean Arch — dio_client.dart core→features 역참조 해소**
- dioProvider가 미사용(P1-C)이므로 삭제가 가장 깨끗. 또는 역참조 제거.

**P0-C: collection_detail_provider — 실제 UseCase 연동**
- GetCollectionDetailUsecase 호출로 교체
- Error.throwWithStackTrace 패턴 사용

**P0-D: Result.when() — 타입 안전성 강화**
- `data as T` → `data!` 또는 콜백 시그니처 `T?`로 변경

### 3. P1 수정 (8건)

P1-A ~ P1-H 순서대로. 각 건별 상세는 보고서 참조.

### 4. 테스트 + 분석

```bash
flutter analyze
flutter test
```

### 5. PR

1. `fix/wave2-p0-p1` 브랜치 생성
2. 커밋 + push → PR → CI green → merge (사용자 승인 후)

## 불변 원칙

- **git push는 사용자 명시 승인 필수**
- **Branch Protection 활성화 상태** — PR + CI green 경로 필수
- **`flutter analyze` 0 / `flutter test` 353+ GREEN** 유지
- **ai-coding-pipeline**: P0/P1 수정은 Stage 2(Plan) → 3(Feedback) → 4(Implement) 축약 가능 (보고서가 Stage 1 역할)

## 완료 기준

- [ ] P0 4건 전부 수정 + 테스트 추가
- [ ] P1 8건 전부 수정
- [ ] `flutter analyze` 0 / `flutter test` GREEN 유지
- [ ] PR — CI green + main 머지
- [ ] 메모리 업데이트: `project_code_review_roadmap.md`에 Wave 2 Fix 완료 기록

## 참조 문서

- **Wave 2 보고서**: `docs/code_review/2026-04-13_wave2_core.md`
- **계획서**: `~/.claude/plans/resilient-imagining-starfish.md`
- **코드 리뷰 로드맵**: 메모리 `project_code_review_roadmap.md`
- **아키텍처 결정사항**: 메모리 `project_architecture.md`
- **Result 타입 주의사항**: 메모리 `feedback_result_type.md`

## 세션 경계

P0/P1 수정 + PR까지. Wave 3 리뷰는 별도 세션(Session 27)에서.
```
