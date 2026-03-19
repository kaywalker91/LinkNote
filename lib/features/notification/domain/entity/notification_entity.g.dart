// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotificationEntity _$NotificationEntityFromJson(Map<String, dynamic> json) =>
    _NotificationEntity(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      linkId: json['linkId'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$NotificationEntityToJson(_NotificationEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'body': instance.body,
      'linkId': instance.linkId,
      'isRead': instance.isRead,
      'createdAt': instance.createdAt.toIso8601String(),
    };
