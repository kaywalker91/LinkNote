import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/features/notification/data/dto/notification_dto.dart';
import 'package:linknote/features/notification/data/mapper/notification_mapper.dart';

void main() {
  group('NotificationMapper', () {
    test('should convert NotificationDto to NotificationEntity', () {
      // Arrange
      const dto = NotificationDto(
        id: 'notif-1',
        userId: 'user-1',
        title: 'New link shared',
        body: 'Someone shared a link with you',
        createdAt: '2026-01-15T10:30:00.000Z',
        linkId: 'link-1',
        isRead: false,
      );

      // Act
      final entity = NotificationMapper.toEntity(dto);

      // Assert
      expect(entity.id, equals('notif-1'));
      expect(entity.title, equals('New link shared'));
      expect(entity.body, equals('Someone shared a link with you'));
      expect(entity.createdAt, equals(DateTime.utc(2026, 1, 15, 10, 30)));
      expect(entity.linkId, equals('link-1'));
      expect(entity.isRead, isFalse);
    });

    test('should handle null linkId', () {
      // Arrange
      const dto = NotificationDto(
        id: 'notif-2',
        userId: 'user-1',
        title: 'System notification',
        body: 'Welcome to LinkNote',
        createdAt: '2026-03-01T08:00:00.000Z',
      );

      // Act
      final entity = NotificationMapper.toEntity(dto);

      // Assert
      expect(entity.linkId, isNull);
      expect(entity.isRead, isFalse);
    });

    test('should map isRead true correctly', () {
      // Arrange
      const dto = NotificationDto(
        id: 'notif-3',
        userId: 'user-1',
        title: 'Read notification',
        body: 'Already read',
        createdAt: '2026-02-20T14:00:00.000Z',
        isRead: true,
      );

      // Act
      final entity = NotificationMapper.toEntity(dto);

      // Assert
      expect(entity.isRead, isTrue);
    });
  });
}
