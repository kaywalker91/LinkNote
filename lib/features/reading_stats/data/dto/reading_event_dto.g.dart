// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_event_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReadingEventDto _$ReadingEventDtoFromJson(Map<String, dynamic> json) =>
    _ReadingEventDto(
      linkId: json['linkId'] as String,
      timestamp: json['timestamp'] as String,
      durationSeconds: (json['durationSeconds'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ReadingEventDtoToJson(_ReadingEventDto instance) =>
    <String, dynamic>{
      'linkId': instance.linkId,
      'timestamp': instance.timestamp,
      'durationSeconds': instance.durationSeconds,
    };
