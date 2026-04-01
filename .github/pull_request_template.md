## 변경 요약

<!-- 이 PR이 해결하는 문제 또는 추가하는 기능을 한 문장으로 설명 -->

## 관련 이슈

<!-- Closes #이슈번호 -->

---

## 코드 리뷰 체크리스트

### 아키텍처
- [ ] Clean Architecture 레이어 경계 준수 (presentation → domain → data)
- [ ] domain 레이어가 data 레이어에 의존하지 않음
- [ ] UseCase가 단일 책임 원칙을 지킴

### Riverpod / 상태 관리
- [ ] `@riverpod` annotation 사용 (수동 Provider 선언 금지)
- [ ] `ref.watch` / `ref.read` / `ref.listen` 적절히 구분해서 사용
- [ ] 불필요한 `ref.invalidate` 없음 (rebuild 최소화)
- [ ] 코드 생성 파일 (`*.g.dart`) 함께 커밋됨

### 보안
- [ ] 하드코딩된 API 키 / 시크릿 없음 (envied 사용)
- [ ] 사용자 입력 검증이 경계(boundary)에서만 수행됨
- [ ] Supabase RLS 정책에 영향을 주는 변경 없음 (있다면 명시)

### 테스트
- [ ] 변경된 Domain UseCase에 대한 단위 테스트 작성
- [ ] 변경된 Repository에 대한 Mock 테스트 작성
- [ ] `flutter test` 전체 통과 확인

### 기타
- [ ] `dart format` 적용됨
- [ ] `flutter analyze` 경고 없음
- [ ] 생성 파일(`*.g.dart`, `*.freezed.dart`) 포함 여부 확인

---

## 특별 주의 (해당 항목에 체크 후 상세 설명 필수)

- [ ] **인증/인가 변경** — 보안 관련 흐름 변경 시 상세 설명:
- [ ] **데이터베이스 스키마 변경** — 마이그레이션 계획:
- [ ] **외부 API 연동 변경** — 영향 범위:
- [ ] **성능에 민감한 변경** — 측정/비교 결과:

---

## 스크린샷 (UI 변경 시)

<!-- Before / After 스크린샷 -->
