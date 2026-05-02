// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_event_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReadingEventEntity _$ReadingEventEntityFromJson(Map<String, dynamic> json) =>
    _ReadingEventEntity(
      linkId: json['linkId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      durationSeconds: (json['durationSeconds'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ReadingEventEntityToJson(_ReadingEventEntity instance) =>
    <String, dynamic>{
      'linkId': instance.linkId,
      'timestamp': instance.timestamp.toIso8601String(),
      'durationSeconds': instance.durationSeconds,
    };
