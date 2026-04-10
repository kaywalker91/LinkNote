import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/notification/data/dto/notification_dto.dart';
import 'package:linknote/features/notification/data/mapper/notification_mapper.dart';
import 'package:linknote/features/notification/domain/entity/notification_entity.dart';
import 'package:linknote/shared/models/paginated_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationRemoteDataSource {
  const NotificationRemoteDataSource(this._client, {required this.userId});
  final SupabaseClient _client;
  final String userId;

  Future<Result<PaginatedState<NotificationEntity>>> getNotifications({
    String? cursor,
    int pageSize = 20,
  }) async {
    try {
      var query = _client.from('notifications').select().eq('user_id', userId);

      if (cursor != null) {
        query = query.lt('created_at', cursor);
      }

      final response = await query
          .order('created_at', ascending: false)
          .limit(pageSize + 1);

      final hasMore = response.length > pageSize;
      final rawItems = hasMore ? response.sublist(0, pageSize) : response;
      final items = rawItems
          .map(
            (json) =>
                NotificationMapper.toEntity(NotificationDto.fromJson(json)),
          )
          .toList();

      return success(
        PaginatedState<NotificationEntity>(
          items: items,
          hasMore: hasMore,
          nextCursor: items.isNotEmpty
              ? items.last.createdAt.toUtc().toIso8601String()
              : null,
        ),
      );
    } on PostgrestException catch (e) {
      return error(Failure.server(message: e.message));
    } on Exception catch (e) {
      return error(Failure.unknown(message: e.toString()));
    }
  }

  Future<Result<void>> markAsRead(String id) async {
    try {
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', id);
      return success(null);
    } on PostgrestException catch (e) {
      return error(Failure.server(message: e.message));
    } on Exception catch (e) {
      return error(Failure.unknown(message: e.toString()));
    }
  }

  Future<Result<void>> markAllAsRead() async {
    try {
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);
      return success(null);
    } on PostgrestException catch (e) {
      return error(Failure.server(message: e.message));
    } on Exception catch (e) {
      return error(Failure.unknown(message: e.toString()));
    }
  }
}
