import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_dto.freezed.dart';
part 'notification_dto.g.dart';

@freezed
abstract class NotificationDto with _$NotificationDto {
  const factory NotificationDto({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String title,
    required String body,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'link_id') String? linkId,
    @JsonKey(name: 'is_read') @Default(false) bool isRead,
  }) = _NotificationDto;

  factory NotificationDto.fromJson(Map<String, dynamic> json) =>
      _$NotificationDtoFromJson(json);
}
