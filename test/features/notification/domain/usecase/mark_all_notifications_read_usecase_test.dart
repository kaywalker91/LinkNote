import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/notification/domain/repository/i_notification_repository.dart';
import 'package:linknote/features/notification/domain/usecase/mark_all_notifications_read_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationRepository extends Mock
    implements INotificationRepository {}

void main() {
  late MarkAllNotificationsReadUsecase sut;
  late MockNotificationRepository mockRepository;

  setUp(() {
    mockRepository = MockNotificationRepository();
    sut = MarkAllNotificationsReadUsecase(mockRepository);
  });

  group('MarkAllNotificationsReadUsecase', () {
    test('should return success when repository marks all as read', () async {
      // Arrange
      when(
        () => mockRepository.markAllAsRead(),
      ).thenAnswer((_) async => success(null));

      // Act
      final result = await sut.call();

      // Assert
      expect(result.isSuccess, isTrue);
      verify(() => mockRepository.markAllAsRead()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return Failure when repository fails', () async {
      // Arrange
      const tFailure = Failure.server(message: 'Batch update failed');
      when(
        () => mockRepository.markAllAsRead(),
      ).thenAnswer((_) async => error(tFailure));

      // Act
      final result = await sut.call();

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, equals(tFailure));
      verify(() => mockRepository.markAllAsRead()).called(1);
    });
  });
}
