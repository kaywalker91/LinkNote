import 'package:hive_ce/hive_ce.dart';
import 'package:linknote/features/auth/domain/entity/auth_state_entity.dart';
import 'package:linknote/features/auth/presentation/provider/auth_provider.dart';
import 'package:linknote/features/notification/data/datasource/notification_local_datasource.dart';
import 'package:linknote/features/notification/data/datasource/notification_remote_datasource.dart';
import 'package:linknote/features/notification/data/repository/notification_repository_impl.dart';
import 'package:linknote/features/notification/domain/repository/i_notification_repository.dart';
import 'package:linknote/features/notification/domain/usecase/fetch_notifications_usecase.dart';
import 'package:linknote/features/notification/domain/usecase/mark_all_notifications_read_usecase.dart';
import 'package:linknote/features/notification/domain/usecase/mark_notification_read_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'notification_di_providers.g.dart';

@riverpod
NotificationRemoteDataSource notificationRemoteDataSource(Ref ref) {
  final authState = ref.watch(authProvider).requireValue;
  final userId = switch (authState) {
    Authenticated(:final userId) => userId,
    _ => throw StateError('User must be authenticated'),
  };
  return NotificationRemoteDataSource(
    Supabase.instance.client,
    userId: userId,
  );
}

@riverpod
NotificationLocalDataSource notificationLocalDataSource(Ref ref) {
  return NotificationLocalDataSource(
    Hive.box<Map<dynamic, dynamic>>('notifications'),
  );
}

@riverpod
INotificationRepository notificationRepository(Ref ref) {
  return NotificationRepositoryImpl(
    ref.watch(notificationRemoteDataSourceProvider),
    ref.watch(notificationLocalDataSourceProvider),
  );
}

@riverpod
FetchNotificationsUsecase fetchNotificationsUsecase(Ref ref) {
  return FetchNotificationsUsecase(ref.watch(notificationRepositoryProvider));
}

@riverpod
MarkNotificationReadUsecase markNotificationReadUsecase(Ref ref) {
  return MarkNotificationReadUsecase(ref.watch(notificationRepositoryProvider));
}

@riverpod
MarkAllNotificationsReadUsecase markAllNotificationsReadUsecase(Ref ref) {
  return MarkAllNotificationsReadUsecase(
    ref.watch(notificationRepositoryProvider),
  );
}
