import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/notification/data/datasource/notification_local_datasource.dart';
import 'package:linknote/features/notification/data/datasource/notification_remote_datasource.dart';
import 'package:linknote/features/notification/data/repository/notification_repository_impl.dart';
import 'package:linknote/features/notification/domain/entity/notification_entity.dart';
import 'package:linknote/shared/models/paginated_state.dart';
import 'package:mocktail/mocktail.dart';

class MockRemoteDataSource extends Mock
    implements NotificationRemoteDataSource {}

class MockLocalDataSource extends Mock
    implements NotificationLocalDataSource {}

void main() {
  late NotificationRepositoryImpl sut;
  late MockRemoteDataSource mockRemote;
  late MockLocalDataSource mockLocal;

  setUp(() {
    mockRemote = MockRemoteDataSource();
    mockLocal = MockLocalDataSource();
    sut = NotificationRepositoryImpl(mockRemote, mockLocal);
  });

  final tNotification = NotificationEntity(
    id: 'notif-1',
    title: 'New link shared',
    body: 'Someone shared a link',
    createdAt: DateTime(2026),
  );

  final tNotifications = [tNotification];

  final tPaginatedState = PaginatedState<NotificationEntity>(
    items: tNotifications,
  );

  // ---------------------------------------------------------------------------
  // getNotifications
  // ---------------------------------------------------------------------------
  group('getNotifications', () {
    test(
      'should cache and return remote data on success (initial fetch)',
      () async {
        // Arrange
        when(
          () => mockRemote.getNotifications(
            cursor: any(named: 'cursor'),
            pageSize: any(named: 'pageSize'),
          ),
        ).thenAnswer((_) async => success(tPaginatedState));
        when(
          () => mockLocal.cacheNotifications(any()),
        ).thenAnswer((_) async {});

        // Act
        final result = await sut.getNotifications();

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data!.items, equals(tNotifications));
        verify(() => mockLocal.cacheNotifications(tNotifications)).called(1);
      },
    );

    test(
      'should fall back to local cache when remote fails (initial fetch)',
      () async {
        // Arrange
        const tFailure = Failure.network(message: 'No connection');
        final tCachedState =
            PaginatedState<NotificationEntity>(items: tNotifications);

        when(
          () => mockRemote.getNotifications(
            cursor: any(named: 'cursor'),
            pageSize: any(named: 'pageSize'),
          ),
        ).thenAnswer((_) async => error(tFailure));
        when(
          () => mockLocal.getCachedNotifications(),
        ).thenReturn(success(tCachedState));

        // Act
        final result = await sut.getNotifications();

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.data!.items, equals(tNotifications));
        verify(() => mockLocal.getCachedNotifications()).called(1);
      },
    );

    test(
      'should NOT fall back to local cache for paginated fetch (cursor != null)',
      () async {
        // Arrange
        const tFailure = Failure.network(message: 'No connection');
        when(
          () => mockRemote.getNotifications(
            cursor: any(named: 'cursor'),
            pageSize: any(named: 'pageSize'),
          ),
        ).thenAnswer((_) async => error(tFailure));

        // Act
        final result = await sut.getNotifications(cursor: 'some-cursor');

        // Assert
        expect(result.isFailure, isTrue);
        verifyNever(() => mockLocal.getCachedNotifications());
      },
    );

    test('should cache subsequent pages as well', () async {
      // Arrange
      when(
        () => mockRemote.getNotifications(
          cursor: any(named: 'cursor'),
          pageSize: any(named: 'pageSize'),
        ),
      ).thenAnswer((_) async => success(tPaginatedState));
      when(
        () => mockLocal.cacheNotifications(any()),
      ).thenAnswer((_) async {});

      // Act
      await sut.getNotifications(cursor: 'some-cursor');

      // Assert
      verify(() => mockLocal.cacheNotifications(tNotifications)).called(1);
    });
  });

  // ---------------------------------------------------------------------------
  // markAsRead
  // ---------------------------------------------------------------------------
  group('markAsRead', () {
    test('should update cache on remote success', () async {
      // Arrange
      when(
        () => mockRemote.markAsRead(any()),
      ).thenAnswer((_) async => success(null));
      when(
        () => mockLocal.updateCachedReadStatus(
          any(),
          isRead: any(named: 'isRead'),
        ),
      ).thenAnswer((_) async {});

      // Act
      final result = await sut.markAsRead('notif-1');

      // Assert
      expect(result.isSuccess, isTrue);
      verify(
        () => mockLocal.updateCachedReadStatus('notif-1', isRead: true),
      ).called(1);
    });

    test('should NOT update cache on remote failure', () async {
      // Arrange
      const tFailure = Failure.server(message: 'Update failed');
      when(
        () => mockRemote.markAsRead(any()),
      ).thenAnswer((_) async => error(tFailure));

      // Act
      final result = await sut.markAsRead('notif-1');

      // Assert
      expect(result.isFailure, isTrue);
      verifyNever(
        () => mockLocal.updateCachedReadStatus(
          any(),
          isRead: any(named: 'isRead'),
        ),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // markAllAsRead
  // ---------------------------------------------------------------------------
  group('markAllAsRead', () {
    test('should update cache on remote success', () async {
      // Arrange
      when(
        () => mockRemote.markAllAsRead(),
      ).thenAnswer((_) async => success(null));
      when(
        () => mockLocal.markAllCachedAsRead(),
      ).thenAnswer((_) async {});

      // Act
      final result = await sut.markAllAsRead();

      // Assert
      expect(result.isSuccess, isTrue);
      verify(() => mockLocal.markAllCachedAsRead()).called(1);
    });

    test('should NOT update cache on remote failure', () async {
      // Arrange
      const tFailure = Failure.server(message: 'Batch update failed');
      when(
        () => mockRemote.markAllAsRead(),
      ).thenAnswer((_) async => error(tFailure));

      // Act
      final result = await sut.markAllAsRead();

      // Assert
      expect(result.isFailure, isTrue);
      verifyNever(() => mockLocal.markAllCachedAsRead());
    });
  });
}
