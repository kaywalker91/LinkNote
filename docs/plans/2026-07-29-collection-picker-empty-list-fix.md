# Collection Picker Empty List Fix — Implementation Plan

> **Execution discipline:** 태스크 단위 RED → GREEN → 회귀 검증을 지키고,
> 완료 보고 전 실제 test/analyze 출력으로 검증한다.

**Goal:** 홈 화면 「컬렉션으로 이동」 바텀시트에서 컬렉션 목록이 간헐적으로 비어 보이는 버그를 근본 원인 수준에서 수정한다.

**Architecture:** 피커가 `collectionListProvider`의 **일회성 스냅샷(`ref.read` + `AsyncValue.value`)** 에 의존하지 않도록, 시트 내부에서 **`ref.watch` + `AsyncValue.when`** 으로 로딩/에러/데이터 상태를 렌더한다. 더보기 시트 → 피커 시트 연속 오픈은 **move 액션을 result로 pop한 뒤 다음 modal을 push**하는 최소 범위 변경으로 정리한다.

**Tech Stack:** Flutter, Riverpod runtime 3.1.0 (`flutter_riverpod`/`riverpod`; `riverpod_annotation` 4.0.0), `@riverpod` AsyncNotifier, `flutter_test` 위젯 테스트, mocktail 불필요(Provider override stub)

**Status:** ✅ Implemented (2026-07-29)

**Priority:** P1 (핵심 UX, 데이터 손실 아님 / 재현 간헐)

**Root-cause session:** 2026-07-29 원인 분석 완료

**Plan verification:** 2026-07-29 현재 홈 테스트 10/10 GREEN, 관련 3파일 analyze 0 issues

---

## 0. 배경 / 근본 원인 (확정)

### 0.1 증상

- 홈 링크 카드 `⋮` → **컬렉션으로 이동** 탭 시
- 바텀시트는 열리지만 컬렉션 항목이 없고 **「없음」만** 보이거나, 목록이 비어 보임
- **간헐적** — 컬렉션 탭을 방금 본 뒤에는 정상, 홈만 쓰거나 이동 직후 재시도 시 실패 확률 ↑

### 0.2 버그 코드

```dart
// lib/features/link/presentation/screens/home_screen.dart — _showCollectionPicker
final collectionsAsync = ref.read(collectionListProvider);
final items = collectionsAsync.value?.items ?? <CollectionEntity>[];
// ↑ Loading / Error / dispose 후 재생성 시 value == null → items = []
// ↑ 이후 fetch 완료해도 시트가 watch하지 않아 rebuild 없음
```

### 0.3 왜 간헐적인가

| 상황 | `collectionListProvider` 상태 | 피커 UI |
|------|-------------------------------|---------|
| 컬렉션 탭 직후 (watch 중 / 캐시 생존) | `AsyncData` | 목록 정상 |
| 홈만 사용, autoDispose 후 첫 오픈 | `AsyncLoading` (value null) | **빈 목록** |
| `moveToCollection` 성공 직후 재오픈 | invalidate → Loading | **빈 목록** |
| 컬렉션 탭 pull-to-refresh 중 | `refresh()` → `const AsyncLoading()` | **빈 목록** |
| fetch 실패 | `AsyncError` (value null) | **빈 목록** (에러 UI 없음) |

관련 사실:

- `collectionListProvider`는 **`isAutoDispose: true`** (`collection_list_provider.g.dart`)
- `HomeScreen`은 이 provider를 **watch하지 않음**
- `moveToCollection` 성공 시 `ref.invalidate(collectionListProvider)` (`link_list_provider.dart`)

### 0.4 부가 요인 (Secondary)

```dart
// 더보기 시트 onTap
Navigator.of(sheetContext).pop();
await _showCollectionPicker(context, ref, linkId);
// 같은 callback에서 pop 직후 다음 modal을 push → Navigator pop 처리와 push가 겹침
```

Primary(데이터 스냅샷)와 별개로 UX 안정성을 위해 함께 수정한다.

`showModalBottomSheet`가 반환하는 Future는 `Route.popped`이며
`TransitionRoute.completed`가 아니다. 따라서 result 패턴은 **pop 요청/결과 수신
뒤 push**를 보장하지만 reverse animation의 완전 종료까지 보장하지는 않는다.
이번 범위의 성공 기준은 같은 callback에서 즉시 두 modal을 조작하지 않는
Navigator 수준 순차화다. 실기기 QA에서 전환 겹침이 계속 재현되면
`TransitionRoute.completed` 대기 방식은 별도 후속으로 분리한다.

### 0.5 계획 검증에서 확인된 교정 사항

- 실제 카드 더보기 아이콘은 `Icons.more_horiz_rounded`다
  (`Icons.more_vert` finder 사용 금지).
- Loading UI에는 무한 애니메이션이 있으므로 피커 오픈 뒤
  `pumpAndSettle()`을 사용하지 않는다. `pump()` + 고정 duration을 사용한다.
- AsyncNotifier의 data stub도 최초 read 순간에는 Loading일 수 있다. 기존
  스냅샷 구현에서도 Data 테스트가 통과해야 한다면 provider를 listener로
  명시적으로 선로딩하고 구독을 유지해야 한다.
- Riverpod 3.1의 `AsyncValue.when`은 invalidate/refresh 시
  `skipLoadingOnRefresh: true`가 기본이다. 이 계획은 Loading UI 요구를
  결정적으로 고정하기 위해 `skipLoadingOnRefresh: false`를 명시한다.
- 컬렉션 API는 기본 20개 페이지다. 이번 수정은 기존 피커의 페이지네이션
  범위를 확장하지 않으며, 20개 초과 선택 지원은 별도 후속으로 기록한다.

---

## 1. 목표 / 비목표

### 1.1 목표 (DoD)

1. Loading 중에도 피커가 **스피너(또는 스켈레톤)** 를 보여주고, 완료 후 **목록이 자동 갱신**된다.
2. 데이터 로드 성공 시 **현재 provider page에 로드된** 컬렉션 이름 리스트 +
   「없음」이 항상 표시된다.
3. 에러 시 빈 목록 대신 **에러 메시지 + 동작하는 재시도**가 표시된다.
4. 더보기 시트가 move result로 pop된 뒤 피커를 push한다
   (같은 callback의 pop/push 제거).
5. 위젯 테스트로 Loading / preloaded Data / Error / Retry /
   Loading→Data 경로를 고정한다.
6. 기존 `moveToCollection` provider 테스트·홈 화면 기존 테스트가 깨지지 않는다.

### 1.2 비목표 (YAGNI)

- `collectionListProvider`를 `keepAlive: true`로 변경하지 않는다 (전역 캐시 정책 변경, 범위 과다).
- 피커를 별도 route/화면으로 승격하지 않는다.
- 컬렉션 생성 UI를 피커에 넣지 않는다.
- i18n 전면 정리, 스낵바 한국어화는 이번 범위 밖 (기존 영문 snackbar 유지).
- `link_detail` 등 다른 화면에 동일 메뉴가 생기면 후속 이슈로 분리 (현재 진입점은 홈 only).
- 피커 페이지네이션/검색 추가는 이번 범위 밖. 현재 API 기본 page size가
  20이므로 20개 초과 컬렉션 선택 지원은 후속 이슈로 분리한다.
- `TransitionRoute.completed`까지 기다리는 custom route 전환은 이번 범위 밖.
  result pop 이후에도 실기기에서 전환 겹침이 재현될 때만 후속 적용한다.

---

## 2. 설계

### 2.1 권장 접근 (Primary)

**시트 본문을 `Consumer` / 전용 `ConsumerWidget`으로 분리**하고 내부에서 `ref.watch(collectionListProvider)`.

```text
_showMoreSheet
  └─ result == move  →  _showCollectionPicker
       └─ showModalBottomSheet
            └─ CollectionPickerSheet (ConsumerWidget)  ← NEW (file-private or shared/widgets)
                 └─ ref.watch(collectionListProvider).when(
                      loading: → CircularProgressIndicator
                      error:   → 메시지 + 재시도(refresh)
                      data:    → ListView(없음 + items)
                    )
```

**왜 `await ref.read(...future)` 단독 수정보다 나은가**

| 방식 | Loading UX | invalidate 후 갱신 | 에러 UX | 테스트 |
|------|------------|-------------------|---------|--------|
| A. `await future` 후 시트 | 시트 열리기 전 블랭크/딜레이 | 시트 열린 뒤 invalidate 미반영 | try/catch 필요 | 중간 |
| **B. 시트 내 watch (채택)** | 시트 즉시 오픈 + 스피너 | 자동 rebuild | when(error) | 쉬움 |
| C. keepAlive only | 증상 완화만 | 불완전 | 없음 | 회귀 위험 |

### 2.2 Secondary — 연속 modal 순차화

**Before (현재)**

```dart
onTap: () async {
  Navigator.of(sheetContext).pop();
  await _showCollectionPicker(context, ref, linkId); // race
},
```

**After**

```dart
// more sheet: pop with signal only
onTap: () => Navigator.of(sheetContext).pop(_MoreAction.moveToCollection),

// after await showModalBottomSheet returns:
final action = await showModalBottomSheet<_MoreAction>(...);
if (action == _MoreAction.moveToCollection && context.mounted) {
  await _showCollectionPicker(context, ref, linkId);
}
```

이번 변경은 **move 액션만 result로 반환**한다. 상세/편집/삭제까지 enum으로
통일하면 변경 범위와 route/dialog 회귀 테스트 범위가 함께 커지므로 이 버그
수정에서는 기존 동작을 보존한다.

### 2.3 파일 변경 범위

| 파일 | 작업 |
|------|------|
| `lib/features/link/presentation/screens/home_screen.dart` | more sheet result 패턴, 피커 시트 watch 기반 렌더 |
| `test/features/link/presentation/screens/home_screen_test.dart` | 피커 Loading/preloaded Data/Error/Retry/transition 위젯 테스트 추가 |
| `CHANGELOG.md` | Unreleased 버그픽스 항목 |
| (선택) `lib/features/link/presentation/widgets/collection_picker_sheet.dart` | 시트가 커지면 추출 — **첫 패스는 home_screen private widget으로 충분** |

Provider/domain/repository **변경 없음**.

### 2.4 UI 스펙 (피커 시트)

```
SafeArea
└─ when
   loading → height 160, Center(CircularProgressIndicator)
   error   → Padding + Text('컬렉션을 불러오지 못했습니다') + TextButton('다시 시도')
             → onPressed: ref.read(collectionListProvider.notifier).refresh()
   data    → ListView(shrinkWrap: true)
             ├─ ListTile 없음 (Icons.folder_off_outlined) → pop(_CollectionPick(null))
             ├─ Divider
             └─ items.map → ListTile(name) → pop(_CollectionPick(id))
```

- 빈 컬렉션(`items.isEmpty`)이어도 「없음」은 표시 (정상 상태).
- `isScrollControlled`와 pagination은 현 수준 유지. API 첫 page(기본 20개)
  초과 선택 지원은 후속.

### 2.5 타입

```dart
enum _MoreAction { moveToCollection }

class _CollectionPick {
  const _CollectionPick({required this.id});
  final String? id;
}
```

`_CollectionPickerBody` 또는 `CollectionPickerSheet` — home_screen 하단 private `ConsumerWidget` 권장 (export 최소화).

---

## 3. 구현 태스크 (TDD)

> 각 Task는 2–15분 단위. RED → GREEN → 필요 시 REFACTOR → commit 권장.

---

### Task 1: 피커 Loading/Data/Error/Retry 테스트 작성 (RED)

**Files:**
- Modify: `test/features/link/presentation/screens/home_screen_test.dart`

**Step 1: Stub 추가**

`collection_list_screen_test.dart`와 동일한 패턴으로 테스트 파일에 추가:

```dart
import 'package:linknote/features/collection/domain/entity/collection_entity.dart';
import 'package:linknote/features/collection/presentation/provider/collection_list_provider.dart';

class _LoadingCollectionList extends CollectionList {
  @override
  Future<PaginatedState<CollectionEntity>> build() {
    return Completer<PaginatedState<CollectionEntity>>().future;
  }
}

class _ErrorCollectionList extends CollectionList {
  @override
  Future<PaginatedState<CollectionEntity>> build() async {
    throw Exception('Network error');
  }

  @override
  Future<void> refresh() async {}
}

class _RetryableCollectionList extends CollectionList {
  _RetryableCollectionList(this._data);

  final PaginatedState<CollectionEntity> _data;
  int refreshCallCount = 0;

  @override
  Future<PaginatedState<CollectionEntity>> build() async {
    throw Exception('Network error');
  }

  @override
  Future<void> refresh() async {
    refreshCallCount++;
    state = const AsyncLoading();
    await Future<void>.delayed(Duration.zero);
    state = AsyncData(_data);
  }
}

class _DataCollectionList extends CollectionList {
  _DataCollectionList(this._data);
  final PaginatedState<CollectionEntity> _data;

  @override
  Future<PaginatedState<CollectionEntity>> build() async => _data;

  @override
  Future<void> refresh() async {}
}
```

**Step 2: 헬퍼 — 홈 마운트 + 선택적 선로딩 + more → 이동 오픈**

```dart
Future<void> _openMovePicker(
  WidgetTester tester,
  List<Override> extra, {
  bool preloadCollections = false,
}) async {
  final link = LinkEntity(
    id: 'link-1',
    url: 'https://example.com',
    title: 'Example',
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );
  await tester.pumpWidget(
    ProviderScope(
      // Riverpod 3 automatic retry timers must not race deterministic
      // Error/Retry assertions in this helper.
      retry: (_, __) => null,
      overrides: [
        linkListProvider.overrideWith(
          () => _DataLinkList(
            PaginatedState(items: [link]),
          ),
        ),
        _zeroStatsOverride,
        ...extra,
      ],
      child: const MaterialApp(home: HomeScreen()),
    ),
  );
  await tester.pumpAndSettle();

  // "이미 로드된 캐시" 시나리오는 listener로 autoDispose를 막은 상태에서
  // future 완료까지 기다려 명시적으로 만든다.
  if (preloadCollections) {
    final container = ProviderScope.containerOf(
      tester.element(find.byType(HomeScreen)),
      listen: false,
    );
    final subscription = container.listen(
      collectionListProvider,
      (_, __) {},
    );
    addTearDown(subscription.close);
    await container.read(collectionListProvider.future);
    await tester.pump();
  }

  await tester.tap(find.byIcon(Icons.more_horiz_rounded).first);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  await tester.tap(find.text('컬렉션으로 이동'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}
```

> **주의:** 피커 Loading 상태에는 `CircularProgressIndicator`가 계속
> 애니메이션하므로 마지막 단계에 `pumpAndSettle()`을 사용하면 안 된다.
> 300ms는 현재 bottom-sheet transition보다 긴 테스트용 고정 pump다.

**Step 3: Data 테스트 (구현 전에도 통과해야 하는 시나리오 — 캐시 있을 때)**

```dart
testWidgets(
  'move picker shows collection names when list is already loaded',
  (tester) async {
    final collections = PaginatedState<CollectionEntity>(
      items: [
        CollectionEntity(
          id: 'c1',
          name: 'Work',
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        ),
        CollectionEntity(
          id: 'c2',
          name: 'Read Later',
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        ),
      ],
    );

    await _openMovePicker(
      tester,
      [
        collectionListProvider.overrideWith(
          () => _DataCollectionList(collections),
        ),
      ],
      preloadCollections: true,
    );

    expect(find.text('없음'), findsOneWidget);
    expect(find.text('Work'), findsOneWidget);
    expect(find.text('Read Later'), findsOneWidget);
  },
);
```

**Step 4: Loading 테스트 (현재 코드에서 FAIL 예상 — 핵심 회귀 테스트)**

```dart
testWidgets(
  'move picker shows loading indicator when collections are loading',
  (tester) async {
    await _openMovePicker(tester, [
      collectionListProvider.overrideWith(_LoadingCollectionList.new),
    ]);

    // 현재 버그: 없음만 보이고 ProgressIndicator 없음 → FAIL after fix expectation
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('없음'), findsNothing); // loading 중에는 리스트 대신 스피너
  },
);
```

**Step 5: Error 테스트 (현재 FAIL)**

```dart
testWidgets(
  'move picker shows error and retry when collections fail to load',
  (tester) async {
    await _openMovePicker(tester, [
      collectionListProvider.overrideWith(_ErrorCollectionList.new),
    ]);

    expect(find.textContaining('불러오지'), findsOneWidget); // 최종 카피로 맞춤
    expect(find.text('다시 시도'), findsOneWidget);
  },
);
```

**Step 6: Retry 동작 테스트 (현재 FAIL)**

```dart
testWidgets(
  'move picker retries and shows data after an error',
  (tester) async {
    final retryable = _RetryableCollectionList(
      PaginatedState<CollectionEntity>(
        items: [
          CollectionEntity(
            id: 'c1',
            name: 'Recovered',
            createdAt: DateTime(2026, 1, 1),
            updatedAt: DateTime(2026, 1, 1),
          ),
        ],
      ),
    );

    await _openMovePicker(tester, [
      collectionListProvider.overrideWith(() => retryable),
    ]);

    expect(find.text('다시 시도'), findsOneWidget);
    await tester.tap(find.text('다시 시도'));
    await tester.pump();
    await tester.pump();

    expect(retryable.refreshCallCount, 1);
    expect(find.text('Recovered'), findsOneWidget);
    expect(find.text('없음'), findsOneWidget);
  },
);
```

**Step 7: 실행 (RED 확인)**

```bash
flutter test test/features/link/presentation/screens/home_screen_test.dart
```

Expected:
- preloaded Data 테스트: **PASS** (listener로 AsyncData 캐시 유지)
- Loading / Error / Retry 테스트: **FAIL**
  (ProgressIndicator / 에러 UI / 재시도 버튼 없음)

**Step 8: RED 체크포인트**

RED 테스트는 단독 commit하지 않고 실패 결과를 기록한 뒤 Task 2 GREEN 구현과
함께 commit한다.

---

### Task 2: Collection picker 시트 watch 기반 구현 (GREEN)

**Files:**
- Modify: `lib/features/link/presentation/screens/home_screen.dart`

**Step 1: private ConsumerWidget 추가**

`home_screen.dart` 하단 (또는 동일 파일 내):

```dart
class _CollectionPickerSheet extends ConsumerWidget {
  const _CollectionPickerSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(collectionListProvider);

    return SafeArea(
      child: async.when(
        // Riverpod 3.1 defaults skipLoadingOnRefresh to true. Explicitly
        // render the loading branch for invalidate/refresh as required by DoD.
        skipLoadingOnRefresh: false,
        loading: () => const SizedBox(
          height: 160,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (error, _) => Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('컬렉션을 불러오지 못했습니다'),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () =>
                    ref.read(collectionListProvider.notifier).refresh(),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
        data: (page) => ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              leading: const Icon(Icons.folder_off_outlined),
              title: const Text('없음'),
              onTap: () => Navigator.of(context).pop(
                const _CollectionPick(id: null),
              ),
            ),
            const Divider(height: 1),
            ...page.items.map(
              (c) => ListTile(
                leading: const Icon(Icons.folder_outlined),
                title: Text(c.name),
                onTap: () => Navigator.of(context).pop(
                  _CollectionPick(id: c.id),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Step 2: `_showCollectionPicker` 단순화**

```dart
Future<void> _showCollectionPicker(
  BuildContext context,
  WidgetRef ref,
  String linkId,
) async {
  final selected = await showModalBottomSheet<_CollectionPick>(
    context: context,
    builder: (_) => const _CollectionPickerSheet(),
  );

  if (selected == null || !context.mounted) return;

  try {
    await ref
        .read(linkListProvider.notifier)
        .moveToCollection(linkId: linkId, collectionId: selected.id);
    if (context.mounted) {
      context.showSuccessSnackBar(
        selected.id == null
            ? 'Removed from collection'
            : 'Moved to collection',
      );
    }
  } on Object catch (_) {
    if (context.mounted) {
      context.showErrorSnackBar('Move failed');
    }
  }
}
```

**제거 대상 라인:**

```dart
final collectionsAsync = ref.read(collectionListProvider);
final items = collectionsAsync.value?.items ?? <CollectionEntity>[];
// + builder 내 하드코딩 ListView
```

`CollectionEntity`가 더 이상 `home_screen.dart`에서 직접 참조되지 않으므로 아래
import도 함께 제거한다.

```dart
import 'package:linknote/features/collection/domain/entity/collection_entity.dart';
```

**Step 3: 테스트 GREEN**

```bash
flutter test test/features/link/presentation/screens/home_screen_test.dart
```

Expected: Loading / preloaded Data / Error / Retry 모두 **PASS**

**Step 4: Commit**

```bash
git add lib/features/link/presentation/screens/home_screen.dart \
        test/features/link/presentation/screens/home_screen_test.dart
git commit -m "$(cat <<'EOF'
fix: watch collectionListProvider inside move-to-collection picker

Snapshot read left the sheet empty when the autoDispose provider was
still loading after invalidate or cold open. Render AsyncValue.when
inside the sheet so loading/error/data update correctly.

EOF
)"
```

---

### Task 3: move 액션만 result pop으로 순차화

**Files:**
- Modify: `lib/features/link/presentation/screens/home_screen.dart`
- Modify: `test/features/link/presentation/screens/home_screen_test.dart` (필수: 액션 후 피커 표시 스모크)

**Step 1: move 전용 enum + more sheet 최소 리팩터**

```dart
enum _MoreAction { moveToCollection }

Future<void> _showMoreSheet(
  BuildContext context,
  WidgetRef ref,
  String linkId,
) async {
  final action = await showModalBottomSheet<_MoreAction>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('상세 보기'),
            onTap: () async {
              Navigator.of(sheetContext).pop();
              await context.push(Routes.linkDetailPath(linkId));
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('편집'),
            onTap: () async {
              Navigator.of(sheetContext).pop();
              await context.push(Routes.linkEditPath(linkId));
            },
          ),
          ListTile(
            leading: const Icon(Icons.folder_outlined),
            title: const Text('컬렉션으로 이동'),
            onTap: () =>
                Navigator.of(sheetContext).pop(_MoreAction.moveToCollection),
          ),
          ListTile(
            leading: Icon(Icons.delete_outline, color: context.palette.rose),
            title: Text('삭제', style: TextStyle(color: context.palette.rose)),
            onTap: () async {
              Navigator.of(sheetContext).pop();
              final confirmed = await ConfirmationDialogWidget.show(
                context,
                title: '링크 삭제',
                message: '이 링크는 영구적으로 삭제됩니다.',
                confirmLabel: '삭제',
                isDestructive: true,
              );
              if (confirmed ?? false) {
                await ref.read(linkListProvider.notifier).deleteLink(linkId);
                if (context.mounted) {
                  context.showSuccessSnackBar('Link deleted');
                }
              }
            },
          ),
        ],
      ),
    ),
  );

  // This awaits Route.popped (result delivery), not the full reverse animation.
  // It still prevents pop + picker push from running in the same onTap callback.
  if (action == _MoreAction.moveToCollection && context.mounted) {
    await _showCollectionPicker(context, ref, linkId);
  }
}
```

상세/편집/삭제 callback은 source diff를 최소화하기 위해 그대로 둔다. 이 Task가
보장하는 것은 move callback이 `pop()`과 `_showCollectionPicker()`를 동시에
실행하지 않는다는 점이다. `showModalBottomSheet` Future는 reverse animation
완료 보장이 아니라 pop 결과 수신 보장이라는 점을 코드 주석에도 남긴다.

**Step 2: modal 교체 스모크 assertion**

Data 또는 Loading→Data 테스트에서 피커 전환 뒤 아래를 필수 확인한다.

```dart
expect(find.text('상세 보기'), findsNothing);
expect(find.text('편집'), findsNothing);
expect(find.byType(BottomSheet), findsOneWidget);
```

**Step 3: 기존 홈 테스트 + 피커 테스트 재실행**

```bash
flutter test test/features/link/presentation/screens/home_screen_test.dart
flutter test test/features/link/presentation/provider/link_list_provider_test.dart
```

Expected: all PASS

**Step 4: Commit**

```bash
git add lib/features/link/presentation/screens/home_screen.dart \
        test/features/link/presentation/screens/home_screen_test.dart
git commit -m "$(cat <<'EOF'
fix: sequence collection picker after more-sheet pop result

Pop more-sheet with an action result, then open the next modal after
the pop result Future completes so both operations do not run in the
same onTap callback.

EOF
)"
```

---

### Task 4: Loading → Data 전환 위젯 테스트 (invalidate/cold-open 시뮬)

**Files:**
- Modify: `test/features/link/presentation/screens/home_screen_test.dart`

**목적:** 「로딩 중 연 뒤 완료되면 목록이 나타난다」— 간헐 버그의 직접 회귀 방지.

**Step 1: Completer 기반 stub**

```dart
class _DeferredCollectionList extends CollectionList {
  final Completer<PaginatedState<CollectionEntity>> completer =
      Completer<PaginatedState<CollectionEntity>>();

  @override
  Future<PaginatedState<CollectionEntity>> build() => completer.future;
}
```

**Step 2: 테스트**

```dart
testWidgets(
  'move picker updates from loading to data when fetch completes',
  (tester) async {
    final deferred = _DeferredCollectionList();
    await _openMovePicker(tester, [
      collectionListProvider.overrideWith(() => deferred),
    ]);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    deferred.completer.complete(
      PaginatedState(
        items: [
          CollectionEntity(
            id: 'c1',
            name: 'Inbox',
            createdAt: DateTime(2026, 1, 1),
            updatedAt: DateTime(2026, 1, 1),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('없음'), findsOneWidget);
    expect(find.text('Inbox'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('상세 보기'), findsNothing);
    expect(find.byType(BottomSheet), findsOneWidget);
  },
);
```

`overrideWith(() => deferred)`는 이 테스트의 provider 생명주기 동안 같은
인스턴스를 반환한다. 피커가 watch 중이라 autoDispose되지 않으므로 외부에서
`deferred.completer`를 완료해 전환을 검증할 수 있다.

**Step 3: Run + Commit**

```bash
flutter test test/features/link/presentation/screens/home_screen_test.dart
git add test/features/link/presentation/screens/home_screen_test.dart
git commit -m "$(cat <<'EOF'
test: cover collection picker loading-to-data transition

EOF
)"
```

---

### Task 5: 정적 분석 · 전체 관련 테스트 · CHANGELOG

**Step 1:**

```bash
dart format --output=none --set-exit-if-changed \
  lib/features/link/presentation/screens/home_screen.dart \
  test/features/link/presentation/screens/home_screen_test.dart
flutter analyze \
  lib/features/link/presentation/screens/home_screen.dart \
  lib/features/collection/presentation/provider/collection_list_provider.dart \
  lib/features/link/presentation/provider/link_list_provider.dart
flutter test test/features/link/
```

Expected: no issues / all green

검증 전 기준선은 홈 화면 테스트 10/10 GREEN, 위 3파일 analyze 0 issues다.
구현 후 실패는 기존 실패로 간주하지 않고 이번 변경의 회귀로 조사한다.

**Step 2: CHANGELOG**

`CHANGELOG.md` `[Unreleased]` 에 추가:

```markdown
### Fixed
- **홈 컬렉션 이동 피커 간헐 빈 목록** (`home_screen.dart`):
  `collectionListProvider`를 시트 오픈 시점 스냅샷(`ref.read` + `value ?? []`)으로
  고정해 autoDispose/invalidate/cold-open 시 Loading이면 목록이 비던 문제 수정.
  시트 내부 `ref.watch` + `AsyncValue.when`(loading/error/data)으로 전환.
  더보기 시트에서 move 액션을 result로 pop한 뒤 피커를 push해 같은 callback의
  연속 bottom sheet 조작도 제거.
```

**Step 3: Commit**

```bash
git add CHANGELOG.md \
        docs/plans/2026-07-29-collection-picker-empty-list-fix.md
git commit -m "$(cat <<'EOF'
docs: note collection move picker empty-list fix in changelog

EOF
)"
```

---

### Task 6: 수동 QA 체크리스트 (실기기/에뮬)

| # | 시나리오 | 기대 |
|---|----------|------|
| 1 | 앱 cold start → 홈만 → 첫 링크 ⋮ → 컬렉션으로 이동 | 스피너 후 목록 (또는 빠른 네트워크면 목록) |
| 2 | 컬렉션 탭 방문 후 홈 → 이동 | 목록 즉시/정상 |
| 3 | 이동 성공 → 다시 같은/다른 링크 이동 | 목록 정상 (invalidate 직후 스피너 가능) |
| 4 | 비행기 모드 등으로 컬렉션 fetch 실패 유도 후 피커 | 에러 + 다시 시도 |
| 5 | 다시 시도 후 네트워크 복구 | 목록 표시 |
| 6 | 「없음」 선택 | Removed snackbar, collection 해제 |
| 7 | 특정 컬렉션 선택 | Moved snackbar, linkCount 갱신(기존 cascade) |
| 8 | 상세/편집/삭제 메뉴 | 기존과 동일 동작 (move 외 callback 무변경 확인) |

---

## 4. 리스크 / 엣지케이스

| 리스크 | 완화 |
|--------|------|
| Riverpod 3.1 `when`이 invalidate/refresh에서 이전 data를 유지 | `skipLoadingOnRefresh: false`를 명시해 DoD의 loading branch를 결정적으로 렌더 |
| 실제 더보기 아이콘과 finder 불일치 | `Icons.more_horiz_rounded` 사용. 향후 아이콘 변경이 잦으면 `Key('link-more-$id')` 추가를 후속 검토 |
| `refresh()` 가 `const AsyncLoading()` 으로 value 클리어 | 에러 재시도 시 스피너로 전환 — 의도된 UX |
| `context` after async gap | 기존과 같이 `context.mounted` 가드 유지 |
| Loading spinner 때문에 widget test settle 타임아웃 | 피커 오픈까지 `pump()` + 300ms 고정 pump 사용. data 전환 완료 뒤에만 `pumpAndSettle()` 허용 |
| result Future가 reverse animation 완료 전에 resolve | 이번 DoD는 pop 결과 수신 뒤 push까지. 실기기에서 재현 시 custom route의 `TransitionRoute.completed` 대기를 후속 |
| 컬렉션 20개 초과 시 첫 page만 선택 가능 | 기존 제한으로 명시하고 pagination/search는 별도 후속 |

---

## 5. 명시적으로 하지 않을 것

1. `collectionListProvider` keepAlive 전환
2. move 성공 시 `collectionListProvider` invalidate 제거 (linkCount 배지 갱신 목적 유지)
3. domain/usecase/repository 변경
4. 새 의존성 추가
5. 피커 pagination/search 추가
6. custom `ModalBottomSheetRoute` 도입

---

## 6. 성공 기준 (Definition of Done)

- [x] Loading/preloaded Data/Error/Retry/Loading→Data 위젯 테스트 통과
- [x] move result 전환 후 more sheet가 제거되고 picker `BottomSheet` 1개만 표시
- [x] `flutter test test/features/link/presentation/screens/home_screen_test.dart` 15/15 + `link_list_provider_test` 20/20
- [x] `flutter analyze` 해당 파일 이슈 0
- [x] 변경 파일 `dart format --set-exit-if-changed` 통과
- [ ] 수동 QA 체크리스트 1–8 확인 (실기기 — 구현 후 사용자 확인)
- [x] CHANGELOG Unreleased 기록
- [x] 원인 문서(본 plan)와 구현이 일치
- [x] `docs/plans/` 내 본 plan 파일을 commit에 포함

---

## 7. 실행 핸드오프

**Plan 저장 위치:** `docs/plans/2026-07-29-collection-picker-empty-list-fix.md`

구현 시 권장 순서:

1. **Task 1** RED 테스트
2. **Task 2** watch 피커 GREEN
3. **Task 3** move result pop 순차화
4. **Task 4** loading→data 회귀 테스트
5. **Task 5–6** analyze + CHANGELOG + 수동 QA

**실행 규율:**

- Task 1에서 RED를 확인하되 실패 테스트만 별도 commit하지 않는다.
- Task 2에서 GREEN 후 코드+테스트를 함께 commit한다.
- 완료 전 format/analyze/관련 전체 테스트의 실제 출력을 남긴다.

**예상 공수:** 1–2시간 (테스트 포함)

---

## 8. 참고 코드 위치

| 역할 | Path |
|------|------|
| 버그 지점 | `lib/features/link/presentation/screens/home_screen.dart` (`_showCollectionPicker`, `_showMoreSheet`) |
| invalidate 유발 | `lib/features/link/presentation/provider/link_list_provider.dart` (`moveToCollection`) |
| autoDispose provider | `lib/features/collection/presentation/provider/collection_list_provider.dart` + `.g.dart` |
| refresh clears value | `collection_list_provider.dart` `refresh()` → `state = const AsyncLoading()` |
| 유사 테스트 stub | `test/features/collection/presentation/screens/collection_list_screen_test.dart` |
| 홈 테스트 | `test/features/link/presentation/screens/home_screen_test.dart` |
| move provider 테스트 (회귀) | `test/features/link/presentation/provider/link_list_provider_test.dart` |
