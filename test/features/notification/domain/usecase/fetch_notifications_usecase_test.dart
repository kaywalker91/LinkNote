import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/notification/domain/entity/notification_entity.dart';
import 'package:linknote/features/notification/domain/repository/i_notification_repository.dart';
import 'package:linknote/features/notification/domain/usecase/fetch_notifications_usecase.dart';
import 'package:linknote/shared/models/paginated_state.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationRepository extends Mock
    implements INotificationRepository {}

void main() {
  late FetchNotificationsUsecase sut;
  late MockNotificationRepository mockRepository;

  setUp(() {
    mockRepository = MockNotificationRepository();
    sut = FetchNotificationsUsecase(mockRepository);
  });

  final tNotifications = [
    NotificationEntity(
      id: '1',
      title: 'New link shared',
      body: 'Someone shared a link with you',
      createdAt: DateTime(2026),
    ),
    NotificationEntity(
      id: '2',
      title: 'Collection updated',
      body: 'Your collection was updated',
      createdAt: DateTime(2026),
      isRead: true,
    ),
  ];

  group('FetchNotificationsUsecase', () {
    test('should return paginated notifications when repository succeeds',
        () async {
      // Arrange
      final tState = PaginatedState<NotificationEntity>(
        items: tNotifications,
        hasMore: true,
        nextCursor: '2026-01-01T00:00:00.000Z',
      );
      when(
        () => mockRepository.getNotifications(
          cursor: any(named: 'cursor'),
          pageSize: any(named: 'pageSize'),
        ),
      ).thenAnswer((_) async => success(tState));

      // Act
      final result = await sut.call();

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data!.items, equals(tNotifications));
      expect(result.data!.hasMore, isTrue);
      verify(() => mockRepository.getNotifications()).called(1);
    });

    test('should return empty list when no notifications exist', () async {
      // Arrange
      const tEmptyState = PaginatedState<NotificationEntity>(items: []);
      when(
        () => mockRepository.getNotifications(
          cursor: any(named: 'cursor'),
          pageSize: any(named: 'pageSize'),
        ),
      ).thenAnswer((_) async => success(tEmptyState));

      // Act
      final result = await sut.call();

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data!.items, isEmpty);
      expect(result.data!.hasMore, isFalse);
    });

    test('should return Failure when repository fails', () async {
      // Arrange
      const tFailure = Failure.network(message: 'No connection');
      when(
        () => mockRepository.getNotifications(
          cursor: any(named: 'cursor'),
          pageSize: any(named: 'pageSize'),
        ),
      ).thenAnswer((_) async => error(tFailure));

      // Act
      final result = await sut.call();

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, equals(tFailure));
    });

    test('should pass cursor and pageSize parameters correctly', () async {
      // Arrange
      const tState = PaginatedState<NotificationEntity>(items: []);
      when(
        () => mockRepository.getNotifications(
          cursor: any(named: 'cursor'),
          pageSize: any(named: 'pageSize'),
        ),
      ).thenAnswer((_) async => success(tState));

      // Act
      await sut.call(cursor: 'some-cursor', pageSize: 10);

      // Assert
      verify(
        () => mockRepository.getNotifications(
          cursor: 'some-cursor',
          pageSize: 10,
        ),
      ).called(1);
    });
  });
}
