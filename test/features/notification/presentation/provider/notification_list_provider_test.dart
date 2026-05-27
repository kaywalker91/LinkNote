import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/notification/domain/entity/notification_entity.dart';
import 'package:linknote/features/notification/domain/usecase/fetch_notifications_usecase.dart';
import 'package:linknote/features/notification/presentation/provider/notification_di_providers.dart';
import 'package:linknote/features/notification/presentation/provider/notification_list_provider.dart';
import 'package:linknote/shared/models/paginated_state.dart';
import 'package:mocktail/mocktail.dart';

class MockFetchNotificationsUsecase extends Mock
    implements FetchNotificationsUsecase {}

void main() {
  late MockFetchNotificationsUsecase mockFetch;

  setUp(() {
    mockFetch = MockFetchNotificationsUsecase();
  });

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        fetchNotificationsUsecaseProvider.overrideWithValue(mockFetch),
      ],
    );
    addTearDown(container.dispose);
    // Keep the auto-dispose provider alive for the duration of the test so the
    // async build settles instead of being torn down mid-loading.
    final sub = container.listen(notificationListProvider, (_, __) {});
    addTearDown(sub.close);
    return container;
  }

  group('NotificationList', () {
    test('should surface the domain Failure (not a generic Exception) '
        'when the fetch usecase fails', () async {
      // Arrange
      const failure = Failure.server(message: 'Fetch failed');
      when(() => mockFetch.call(cursor: any(named: 'cursor'))).thenAnswer(
        (_) async => error(failure),
      );

      final container = createContainer();

      // Act — let build() run and settle into an error state.
      await pumpEventQueue();

      // Assert — the error must be the domain Failure so the presentation
      // layer can map it via failureUiFromError, matching every other list
      // provider. The previous raw `throw Exception(...)` is the regression
      // this guards against.
      final state = container.read(notificationListProvider);
      expect(state.hasError, isTrue);
      expect(state.error, isA<Failure>());
    });

    test(
      'should expose paginated data when the fetch usecase succeeds',
      () async {
        // Arrange
        when(() => mockFetch.call(cursor: any(named: 'cursor'))).thenAnswer(
          (_) async =>
              success(const PaginatedState<NotificationEntity>(items: [])),
        );

        final container = createContainer();

        // Act
        final state = await container.read(notificationListProvider.future);

        // Assert
        expect(state.items, isEmpty);
      },
    );
  });
}
