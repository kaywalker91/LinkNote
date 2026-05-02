// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_stats_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReadingStatsEntity _$ReadingStatsEntityFromJson(Map<String, dynamic> json) =>
    _ReadingStatsEntity(
      linkId: json['linkId'] as String,
      totalReads: (json['totalReads'] as num?)?.toInt() ?? 0,
      lastReadAt: json['lastReadAt'] == null
          ? null
          : DateTime.parse(json['lastReadAt'] as String),
    );

Map<String, dynamic> _$ReadingStatsEntityToJson(_ReadingStatsEntity instance) =>
    <String, dynamic>{
      'linkId': instance.linkId,
      'totalReads': instance.totalReads,
      'lastReadAt': instance.lastReadAt?.toIso8601String(),
    };
