# 다음 세션 프롬프트

아래 내용을 그대로 붙여넣기해서 다음 세션을 시작하세요.

---

```
Session 27 — Wave 3 Code Review: Link Feature

## 미션 한 줄

Link feature(`lib/features/link/`) 전체 코드 리뷰를 수행하고 보고서를 작성한다.

## 배경

Session 25-26에서 Wave 2(Core/Cross-cutting) 리뷰 + P0/P1 수정 완료(PR#7 머지).
이제 가장 규모가 큰 feature인 Link를 리뷰한다.

현재 상태:
- **main HEAD**: `42eed5e` (Wave 2 P0/P1 fix PR 머지 후)
- **Branch Protection 활성화** — PR + CI green 경로 필수
- **352 tests GREEN, analyze 0**
- **Wave 2 P2/P3 미수정 13건** — Wave 3~6과 병행 처리 예정

## 리뷰 범위 (23 source files)

```
lib/features/link/
├── data/
│   ├── datasource/  (link_local_datasource, link_remote_datasource)
│   ├── dto/         (link_dto)
│   ├── mapper/      (link_mapper)
│   └── repository/  (link_repository_impl)
├── domain/
│   ├── entity/      (link_entity, tag_entity)
│   ├── repository/  (i_link_repository)
│   └── usecase/     (create, delete, fetch, get_detail, toggle_favorite, update)
└── presentation/
    ├── provider/    (link_detail, link_di, link_filter, link_form, link_list)
    └── screens/     (home, link_add, link_detail, link_edit)
```

## 가장 먼저 할 일 (순서 엄수)

### 0. 현재 상태 확인
```bash
git status && git log --oneline -5
flutter analyze && flutter test
```

### 1. 이전 리뷰 보고서 참조
```bash
cat docs/code_review/2026-04-13_wave2_core.md
```
Wave 2 보고서의 형식과 기준을 따른다. link_local_datasource는 Wave 2에서 IClearableCache 적용 완료.

### 2. 코드 리뷰 수행

**리뷰 관점** (Wave 2와 동일):
- Clean Architecture 준수 (의존성 방향, 레이어 경계)
- 타입 안전성, null safety
- 에러 핸들링 패턴 일관성 (Result, Failure)
- 리소스 관리 (Stream 구독, Dio 등)
- UI/UX 이슈 (상태 관리, 로딩/에러 처리)
- 동시성/비동기 이슈
- 테스트 누락 영역

**특별 주의**:
- `link_repository_impl.dart`: Wave 2에서 P3-A(dead branch), P2-D(pagination cache eviction) 발견됨 — 추가 이슈 탐색
- `link_form_provider.dart`: Wave 2에서 P1-F(TOCTOU) 수정 완료 — 다른 이슈 확인
- `link_local_datasource.dart`: Wave 2에서 IClearableCache 적용 완료 — 기타 이슈 확인

### 3. 보고서 작성
- `docs/code_review/2026-04-13_wave3_link.md` 생성
- P0~P3 분류, 권장 픽스 포함

### 4. PR
1. `chore/wave3-review` 브랜치 생성
2. 보고서 커밋 + push → PR (사용자 승인 후)

## 불변 원칙

- **git push는 사용자 명시 승인 필수**
- **Branch Protection 활성화 상태** — PR + CI green 경로 필수
- **`flutter analyze` 0 / `flutter test` 352 GREEN** 유지
- 리뷰 보고서만 작성, **코드 수정 금지** (수정은 Session 28에서)

## 완료 기준

- [ ] Link feature 23 source files 전수 리뷰
- [ ] `docs/code_review/2026-04-13_wave3_link.md` 보고서 작성
- [ ] P0~P3 분류 + 각 건별 권장 픽스
- [ ] PR 생성 → CI green
- [ ] 메모리 업데이트

## 참조 문서

- **Wave 2 보고서**: `docs/code_review/2026-04-13_wave2_core.md`
- **Session 26 로그**: `docs/daily_task_log/2026-04-13_session26.md`
- **아키텍처**: CLAUDE.md → Architecture 섹션

## 세션 경계

Wave 3 리뷰 + 보고서 PR까지. P0/P1 수정은 별도 세션(Session 28)에서.
```
