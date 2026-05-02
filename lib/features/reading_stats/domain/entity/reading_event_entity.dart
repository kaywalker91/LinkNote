import 'package:freezed_annotation/freezed_annotation.dart';

part 'reading_event_entity.freezed.dart';
part 'reading_event_entity.g.dart';

// AC-1: ReadingEventEntity is a freezed value class with fields:
//   linkId (String, required), timestamp (DateTime, required),
//   durationSeconds (int?, optional). fromJson/toJson generated.
@freezed
abstract class ReadingEventEntity with _$ReadingEventEntity {
  const factory ReadingEventEntity({
    required String linkId,
    required DateTime timestamp,
    int? durationSeconds,
  }) = _ReadingEventEntity;

  factory ReadingEventEntity.fromJson(Map<String, dynamic> json) =>
      _$ReadingEventEntityFromJson(json);
}
