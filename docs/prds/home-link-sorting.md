# 홈 링크 정렬 구현 계획

> 문서 버전: 1.0
> 작성일: 2026-07-28
> 상태: 구현 예정
> 적용 화면: Home (`/home`)

## 1. 한 줄 정의

홈 화면의 정렬 버튼으로 링크 목록을 **최신순** 또는 **오래된순**으로
전환하고, 선택한 정렬을 페이지네이션과 오프라인 캐시에도 동일하게 적용한다.

## 2. 결정 사항

- 지원 정렬은 `최신순`, `오래된순` 두 가지로 제한한다.
- 기본값은 현재 동작과 같은 `최신순`이다.
- 정렬은 현재 화면에 로드된 항목만 재배열하지 않고 원격 조회 단계부터 적용한다.
- `전체`, `★ 즐겨찾기` 필터 모두 같은 정렬 설정을 사용한다.
- 마지막 선택은 암호화된 Hive `settings` box에 저장하고 앱 재실행 후 복원한다.
- 적용 범위는 홈 화면뿐이다.
- Supabase 스키마 변경이나 DB migration은 수행하지 않는다.

## 3. 배경과 현재 상태

홈 상단에는 `Icons.swap_vert_rounded` 정렬 버튼이 있지만 `onPressed`가 빈
콜백이라 사용자 동작이 발생하지 않는다.

현재 링크 목록은 아래와 같이 최신순으로 고정되어 있다.

- `LinkList` Provider는 즐겨찾기/컬렉션 필터만 조회 조건으로 사용한다.
- `LinkRemoteDataSource.getLinks()`는 `created_at DESC`로 고정 조회한다.
- 다음 페이지 cursor는 마지막 링크의 `createdAt`이며 항상
  `created_at < cursor` 조건을 사용한다.
- `LinkLocalDataSource.getCachedLinks()`도 `createdAt DESC`로 고정 정렬한다.

따라서 화면에서 이미 로드된 링크만 뒤집는 방식은 전체 데이터 기준 정렬과
페이지네이션 순서를 깨뜨린다. 정렬 기준을 Presentation에서 DataSource까지
전달해야 한다.

## 4. 목표와 비목표

### 4.1 목표

1. 사용자가 홈 정렬 버튼을 눌러 최신순과 오래된순을 선택할 수 있다.
2. 선택 직후 첫 페이지를 새 정렬 기준으로 다시 조회한다.
3. 추가 페이지도 첫 페이지와 같은 정렬 방향으로 이어진다.
4. 즐겨찾기 필터를 전환해도 선택한 정렬은 유지된다.
5. 앱을 재실행해도 마지막 선택이 유지된다.
6. 원격 조회 실패 시 캐시된 링크도 선택한 방향으로 정렬된다.
7. 빠른 연속 변경 중 이전 요청이 늦게 끝나도 최신 선택 결과를 덮어쓰지 않는다.

### 4.2 비목표

- 제목 가나다순 또는 알파벳순
- 최근 수정순
- 즐겨찾기 우선 정렬
- 사용자가 직접 순서를 지정하는 드래그 정렬
- 검색 결과, 컬렉션 상세, 공개 컬렉션 목록 정렬
- 정렬 설정의 서버 동기화 또는 계정별 저장
- 홈 상단 링크 개수/이번 주 통계 정확도 개선
- 기존 timestamp cursor를 복합 cursor로 재설계하는 작업

## 5. 사용자 경험

### 5.1 정렬 선택

1. 홈 상단의 정렬 버튼을 누른다.
2. `링크 정렬` 제목의 modal bottom sheet가 열린다.
3. 다음 두 항목을 표시한다.
   - `최신순` — 최근 저장한 링크부터 표시
   - `오래된순` — 먼저 저장한 링크부터 표시
4. 현재 정렬에는 check 또는 radio selected 상태를 표시한다.
5. 다른 항목을 선택하면 sheet를 닫고 새 정렬로 첫 페이지를 조회한다.
6. 현재 항목을 다시 선택하면 추가 조회 없이 sheet만 닫는다.

### 5.2 상태별 동작

| 상태 | 기대 동작 |
|---|---|
| 최초 실행 또는 저장값 없음 | `최신순` 사용 |
| 저장값을 읽을 수 없음 | 오류를 사용자에게 노출하지 않고 `최신순` fallback |
| 정렬 변경 | 기존 항목과 cursor를 버리고 첫 페이지 재조회 |
| 정렬 변경 후 load more | 선택한 방향으로 다음 페이지 추가 |
| Pull-to-refresh | 현재 정렬과 필터를 유지한 채 첫 페이지 재조회 |
| 즐겨찾기 필터 전환 | 현재 정렬 유지, 해당 필터의 첫 페이지 재조회 |
| 원격 실패 + 캐시 존재 | 캐시된 범위 안에서 선택한 순서로 표시 |
| 원격 실패 + 캐시 없음 | 기존 오류 화면과 재시도 동작 유지 |

## 6. 기능 요구사항

| ID | 요구사항 | 완료 조건 |
|---|---|---|
| SORT-01 | 정렬 sheet | 정렬 버튼을 누르면 두 선택지가 표시된다. |
| SORT-02 | 기본 정렬 | 저장값이 없으면 최신 링크가 먼저 표시된다. |
| SORT-03 | 오래된순 | 오래된 링크가 먼저 표시되고 다음 페이지는 더 최근 링크로 이어진다. |
| SORT-04 | 최신순 | 최근 링크가 먼저 표시되고 다음 페이지는 더 오래된 링크로 이어진다. |
| SORT-05 | 필터 조합 | 전체/즐겨찾기 모두 선택된 정렬 방향을 따른다. |
| SORT-06 | 설정 유지 | 앱 재실행 후 마지막 선택이 복원된다. |
| SORT-07 | 새로고침 | Pull-to-refresh 후에도 정렬이 유지된다. |
| SORT-08 | 오프라인 | 캐시 fallback 결과도 선택된 방향으로 정렬된다. |
| SORT-09 | 중복 요청 방지 | 같은 정렬 재선택은 목록을 다시 조회하지 않는다. |
| SORT-10 | 요청 경합 방지 | 이전 조건의 늦은 응답이 현재 목록을 덮어쓰지 않는다. |

## 7. 기술 설계

### 7.1 정렬 모델

Domain 계층에 명시적인 enum을 추가한다.

```dart
enum LinkSortOrder {
  newest,
  oldest,
}
```

`bool ascending`을 계층 간 계약으로 사용하지 않는다. enum을 사용해야 호출부의
의도가 드러나고, 지원하지 않는 정렬이 임의로 전달되는 것을 막을 수 있다.

### 7.2 정렬 상태와 로컬 저장

`@Riverpod(keepAlive: true)` 기반 `LinkSortNotifier`를 추가한다.

- 저장 box: `Hive.box<String>('settings')`
- 저장 key: `homeLinkSortOrder`
- 저장값: `newest` 또는 `oldest`
- 알 수 없는 값: `newest` fallback
- 같은 값 설정: state/write/refetch 모두 생략

설정 write 실패가 링크 조회 자체를 막아서는 안 된다. 현재 세션에는 선택을
반영하고, 저장 실패는 로깅한 뒤 다음 실행에서 기본값으로 fallback한다.

### 7.3 데이터 흐름

```text
HomeScreen
  └─ 정렬 선택
      └─ LinkSortNotifier.setSortOrder()
          ├─ state 변경
          └─ Hive settings 저장

LinkList.build()
  ├─ watch(linkFilterProvider)
  ├─ watch(linkSortProvider)
  └─ FetchLinksUsecase
      └─ ILinkRepository
          ├─ LinkRemoteDataSource
          └─ 실패 시 LinkLocalDataSource
```

정렬 변경 시 `LinkList`가 의존성 변경으로 재실행되므로 화면에서
`refresh()`까지 중복 호출하지 않는다.

### 7.4 원격 조회와 cursor

| 정렬 | 첫 페이지 order | 다음 페이지 조건 | 다음 페이지 order |
|---|---|---|---|
| 최신순 | `created_at DESC` | `created_at < cursor` | `created_at DESC` |
| 오래된순 | `created_at ASC` | `created_at > cursor` | `created_at ASC` |

- 기존과 동일하게 `pageSize + 1`개를 요청해 `hasMore`를 계산한다.
- `nextCursor`는 반환한 마지막 링크의 UTC `createdAt`을 사용한다.
- 필터 조건을 먼저 적용한 뒤 cursor와 order를 적용한다.
- 공개 컬렉션 전용 조회는 이번 범위에서 변경하지 않는다.

### 7.5 로컬 캐시

`LinkLocalDataSource.getCachedLinks()`에 `sortOrder`를 전달한다.

- 최신순: `b.createdAt.compareTo(a.createdAt)`
- 오래된순: `a.createdAt.compareTo(b.createdAt)`
- 즐겨찾기/컬렉션 필터와 정렬을 함께 적용한다.
- 캐시는 최대 100개의 부분 집합이므로 오래된순 오프라인 결과가 서버의 전체
  링크 중 절대적으로 가장 오래된 항목임을 보장하지는 않는다.

### 7.6 비동기 요청 경합

정렬 또는 필터가 바뀌는 순간 이미 `loadMore()`가 진행 중일 수 있다.
각 요청 시작 시 `favoritesOnly`, `collectionId`, `sortOrder`로 구성한 query
snapshot을 보관하고, 응답 직후 현재 조건과 비교한다.

조건이 달라졌다면 해당 응답을 폐기하고 state에 반영하지 않는다. 이를 통해
오래된 정렬 요청이 새 정렬 결과 뒤에 append되는 것을 막는다.

## 8. 예상 변경 파일

### 8.1 신규

| 파일 | 내용 |
|---|---|
| `lib/features/link/domain/entity/link_sort_order.dart` | 정렬 enum |
| `lib/features/link/presentation/provider/link_sort_provider.dart` | 정렬 상태와 Hive 저장 |
| `lib/features/link/presentation/provider/link_sort_provider.g.dart` | Riverpod 생성 파일 |
| `test/features/link/presentation/provider/link_sort_provider_test.dart` | 설정 기본값/저장/복원 테스트 |

### 8.2 수정

| 파일 | 변경 내용 |
|---|---|
| `lib/features/link/presentation/screens/home_screen.dart` | 정렬 sheet 연결 |
| `lib/features/link/presentation/provider/link_list_provider.dart` | 정렬 구독, 조회 전달, 요청 경합 방지 |
| `lib/features/link/presentation/provider/link_list_provider.g.dart` | Riverpod 재생성 결과 |
| `lib/features/link/domain/usecase/fetch_links_usecase.dart` | `sortOrder` 전달 |
| `lib/features/link/domain/repository/i_link_repository.dart` | `getLinks()` 계약 확장 |
| `lib/features/link/data/repository/link_repository_impl.dart` | Remote/Local에 정렬 전달 |
| `lib/features/link/data/datasource/link_remote_datasource.dart` | order 및 cursor 방향 분기 |
| `lib/features/link/data/datasource/link_local_datasource.dart` | 캐시 정렬 방향 분기 |
| 관련 `test/features/link/**` 테스트 | 계층별 정렬 전달과 UI 검증 |

## 9. 구현 순서

1. `LinkSortOrder` enum과 정렬 Provider를 추가한다.
2. UseCase와 Repository 인터페이스에 정렬 파라미터를 추가한다.
3. Remote/Local DataSource에 최신순/오래된순 분기를 구현한다.
4. `LinkList`가 정렬을 구독하고 build/refresh/load-more에 전달하게 한다.
5. 요청 조건 snapshot으로 stale response를 차단한다.
6. 홈 정렬 버튼과 modal bottom sheet를 연결한다.
7. Riverpod 코드를 재생성하고 계층별 테스트를 보강한다.
8. 정적 분석, 전체 테스트, 실기기 시나리오를 검증한다.

## 10. 테스트 계획

### 10.1 단위 테스트

- `LinkSortNotifier`
  - 저장값이 없을 때 최신순
  - `oldest` 저장값 복원
  - 알 수 없는 저장값은 최신순 fallback
  - 같은 값 재선택 시 Hive write 생략
- `FetchLinksUsecase` / `LinkRepositoryImpl`
  - 정렬 파라미터를 하위 계층에 그대로 전달
- `LinkRemoteDataSource`
  - 최신순은 DESC와 `< cursor`
  - 오래된순은 ASC와 `> cursor`
  - 필터와 정렬을 동시에 적용
- `LinkLocalDataSource`
  - 캐시 최신순/오래된순
  - 즐겨찾기 필터와 오래된순 조합
- `LinkList`
  - 정렬 변경 시 cursor 없이 첫 페이지 재조회
  - load-more가 현재 정렬을 사용
  - 이전 정렬의 늦은 응답 폐기
  - 새로고침 후 정렬 유지

### 10.2 위젯 테스트

- 정렬 아이콘 탭 시 sheet 표시
- 두 옵션과 설명 표시
- 현재 정렬 선택 상태 표시
- 오래된순 선택 시 Provider 변경 및 sheet 닫힘
- 같은 옵션 재선택 시 재조회하지 않음
- 기존 loading/error/empty/list 상태 회귀 없음

### 10.3 수동 검증

1. 최신순에서 최근 링크가 첫 항목인지 확인한다.
2. 오래된순 전환 후 가장 오래된 링크가 첫 항목인지 확인한다.
3. 20개가 넘는 데이터에서 load-more 순서가 연속적인지 확인한다.
4. 전체/즐겨찾기 전환 후 정렬이 유지되는지 확인한다.
5. Pull-to-refresh 후 정렬이 유지되는지 확인한다.
6. 앱을 완전히 종료하고 다시 실행해 선택이 복원되는지 확인한다.
7. 오프라인 상태에서 캐시 결과가 선택한 방향으로 표시되는지 확인한다.
8. 정렬을 빠르게 연속 변경해 최종 선택과 목록이 일치하는지 확인한다.

### 10.4 자동 검증 명령

```bash
dart run build_runner build --delete-conflicting-outputs
dart format --set-exit-if-changed lib/ test/
bash tool/check_anti_patterns.sh
flutter analyze --fatal-warnings
flutter test --reporter=failures-only
```

## 11. 완료 기준

- SORT-01부터 SORT-10까지 자동 또는 수동 테스트로 확인된다.
- 최신순 기본 동작이 기존 홈 목록과 동일하다.
- 오래된순에서 첫 페이지와 추가 페이지의 방향이 일관된다.
- 전체/즐겨찾기 필터, 새로고침, 오프라인 fallback과 함께 동작한다.
- 앱 재실행 후 마지막 정렬이 복원된다.
- 정렬 변경 중 중복 append 또는 이전 결과 덮어쓰기가 발생하지 않는다.
- `flutter analyze --fatal-warnings`가 0 issue로 끝난다.
- 전체 `flutter test`가 통과한다.

## 12. 알려진 인접 이슈

홈 상단의 `저장한 링크 N · 이번 주 +N`은 전체 서버 통계가 아니라 현재까지
로드된 `items`만 기준으로 계산한다. 오래된순 첫 페이지에서는 최근 링크가
있어도 이번 주 수치가 0처럼 보일 수 있다.

이는 정렬 기능 자체와 별개의 기존 정확도 문제이므로 이번 구현에서는 수정하지
않는다. 정확한 전체 개수와 최근 7일 통계를 제공하려면 별도의 summary 조회
설계와 Provider가 필요하다.
