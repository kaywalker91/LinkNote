# 다음 세션 프롬프트

아래 내용을 그대로 붙여넣기해서 다음 세션을 시작하세요.

---

```
Widget 테스트 보강 — 커버리지 70% 목표 구현

## 배경
- 2026-04-11 세션에서 P1/P2 전체 커밋 + 푸시 완료 (178f52e, 0eba95b, 34487c2).
- 현재 테스트: 42파일, 162 테스트 ALL GREEN.
- Widget/Screen 테스트는 3파일만 존재 (login_screen, home_screen, link_add_screen).
- 메모리: project_code_review_roadmap.md 참조 (Widget 테스트 로드맵 포함).

## 목표
Presentation 레이어 Widget 테스트 커버리지 70% 달성.

## 구현 계획

### Wave 1: Shared Widgets (재사용 위젯 — 의존성 없어 독립 테스트 가능)
우선순위 높은 것부터:
1. `test/shared/widgets/primary_button_widget_test.dart` — 탭 콜백, 로딩 상태, 비활성화
2. `test/shared/widgets/confirmation_dialog_widget_test.dart` — 확인/취소 콜백
3. `test/shared/widgets/tag_chip_widget_test.dart` — 탭, 선택 상태 표시
4. `test/shared/widgets/offline_banner_widget_test.dart` — 오프라인 시 배너 표시
5. `test/shared/widgets/async_value_view_test.dart` — loading/error/data 3상태 렌더링
6. `test/shared/widgets/app_search_bar_widget_test.dart` — 입력, 클리어, 서브밋 콜백

### Wave 2: Feature Screens (핵심 사용자 흐름)
1. `test/features/search/presentation/screens/search_screen_test.dart` — 검색 입력 + 결과 표시
2. `test/features/link/presentation/screens/link_detail_screen_test.dart` — 상세 정보 렌더링 + 액션 버튼
3. `test/features/collection/presentation/screens/collection_list_screen_test.dart` — 목록 렌더링 + FAB
4. `test/features/notification/presentation/screens/notification_screen_test.dart` — 알림 목록 + 읽음 처리
5. `test/features/profile/presentation/screens/profile_screen_test.dart` — 프로필 정보 표시

### Wave 3: 나머지 Screens (시간 허용 시)
1. `test/features/auth/presentation/screens/signup_screen_test.dart`
2. `test/features/link/presentation/screens/link_edit_screen_test.dart`
3. `test/features/collection/presentation/screens/collection_detail_screen_test.dart`
4. `test/features/collection/presentation/screens/collection_form_screen_test.dart`
5. `test/features/profile/presentation/screens/settings_screen_test.dart`

## 테스트 작성 규칙
- `ProviderScope.overrides`로 Provider mock 주입
- `mocktail`로 UseCase/Repository mock
- 각 테스트: Arrange(위젯 pump) → Act(tap/입력) → Assert(find/expect)
- 테스트 이름: `should [action] when [condition]`
- Wave 완료마다 `flutter analyze` + `flutter test` 검증

## 완료 기준
- Widget 테스트 파일 최소 11개 이상 추가 (Wave 1: 6 + Wave 2: 5)
- 전체 테스트 ALL GREEN
- flutter analyze 0 errors
- 커밋 + 푸시 (사용자 승인 후)
```
