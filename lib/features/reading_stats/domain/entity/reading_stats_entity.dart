import 'package:freezed_annotation/freezed_annotation.dart';

part 'reading_stats_entity.freezed.dart';
part 'reading_stats_entity.g.dart';

// AC-2: ReadingStatsEntity is a freezed value class with fields:
//   linkId (String, required), totalReads (int, required, default 0),
//   lastReadAt (DateTime?, optional). fromJson/toJson generated.
@freezed
abstract class ReadingStatsEntity with _$ReadingStatsEntity {
  const factory ReadingStatsEntity({
    required String linkId,
    @Default(0) int totalReads,
    DateTime? lastReadAt,
  }) = _ReadingStatsEntity;

  factory ReadingStatsEntity.fromJson(Map<String, dynamic> json) =>
      _$ReadingStatsEntityFromJson(json);
}
