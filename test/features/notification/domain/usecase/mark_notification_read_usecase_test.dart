import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/notification/domain/repository/i_notification_repository.dart';
import 'package:linknote/features/notification/domain/usecase/mark_notification_read_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationRepository extends Mock
    implements INotificationRepository {}

void main() {
  late MarkNotificationReadUsecase sut;
  late MockNotificationRepository mockRepository;

  setUp(() {
    mockRepository = MockNotificationRepository();
    sut = MarkNotificationReadUsecase(mockRepository);
  });

  const tId = 'notification-id-1';

  group('MarkNotificationReadUsecase', () {
    test('should return success when repository marks as read successfully',
        () async {
      // Arrange
      when(
        () => mockRepository.markAsRead(any()),
      ).thenAnswer((_) async => success(null));

      // Act
      final result = await sut.call(tId);

      // Assert
      expect(result.isSuccess, isTrue);
      verify(() => mockRepository.markAsRead(tId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return Failure when repository fails', () async {
      // Arrange
      const tFailure = Failure.server(message: 'Update failed');
      when(
        () => mockRepository.markAsRead(any()),
      ).thenAnswer((_) async => error(tFailure));

      // Act
      final result = await sut.call(tId);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, equals(tFailure));
      verify(() => mockRepository.markAsRead(tId)).called(1);
    });
  });
}
