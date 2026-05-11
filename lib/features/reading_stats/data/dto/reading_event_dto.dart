import 'package:freezed_annotation/freezed_annotation.dart';

part 'reading_event_dto.freezed.dart';
part 'reading_event_dto.g.dart';

// DTO for a single reading event stored inside the Hive box entry.
// The box stores Map<dynamic,dynamic>; fromJson accepts Map<String,dynamic>
// obtained by casting the stored map.
@freezed
abstract class ReadingEventDto with _$ReadingEventDto {
  const factory ReadingEventDto({
    required String linkId,
    required String timestamp,
    int? durationSeconds,
  }) = _ReadingEventDto;

  factory ReadingEventDto.fromJson(Map<String, dynamic> json) =>
      _$ReadingEventDtoFromJson(json);
}
