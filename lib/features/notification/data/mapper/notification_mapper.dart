import 'package:linknote/features/notification/data/dto/notification_dto.dart';
import 'package:linknote/features/notification/domain/entity/notification_entity.dart';

class NotificationMapper {
  const NotificationMapper._();

  static NotificationEntity toEntity(NotificationDto dto) {
    return NotificationEntity(
      id: dto.id,
      title: dto.title,
      body: dto.body,
      createdAt: DateTime.parse(dto.createdAt),
      linkId: dto.linkId,
      isRead: dto.isRead,
    );
  }
}
