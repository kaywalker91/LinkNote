import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/features/notification/domain/entity/notification_entity.dart';
import 'package:linknote/features/notification/presentation/provider/notification_list_provider.dart';
import 'package:linknote/features/notification/presentation/screens/notification_screen.dart';
import 'package:linknote/shared/models/paginated_state.dart';

class _LoadingNotificationList extends NotificationList {
  @override
  Future<PaginatedState<NotificationEntity>> build() {
    return Completer<PaginatedState<NotificationEntity>>().future;
  }
}

class _ErrorNotificationList extends NotificationList {
  @override
  Future<PaginatedState<NotificationEntity>> build() async {
    throw Exception('Failed to fetch');
  }

  @override
  Future<void> refresh() async {}

  @override
  Future<void> markAllRead() async {}
}

class _DataNotificationList extends NotificationList {
  final PaginatedState<NotificationEntity> _data;
  _DataNotificationList(this._data);

  @override
  Future<PaginatedState<NotificationEntity>> build() async => _data;

  @override
  Future<void> refresh() async {}

  @override
  Future<void> loadMore() async {}

  @override
  Future<void> markRead(String id) async {}

  @override
  Future<void> markAllRead() async {}
}

void main() {
  group('NotificationScreen', () {
    testWidgets('should show app bar with title and mark all read button',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationListProvider
                .overrideWith(_LoadingNotificationList.new),
          ],
          child: const MaterialApp(home: NotificationScreen()),
        ),
      );
      await tester.pump();

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Mark all read'), findsOneWidget);
    });

    testWidgets('should show skeletons when loading', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationListProvider
                .overrideWith(_LoadingNotificationList.new),
          ],
          child: const MaterialApp(home: NotificationScreen()),
        ),
      );
      await tester.pump();

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('should show error state with retry', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationListProvider
                .overrideWith(_ErrorNotificationList.new),
          ],
          child: const MaterialApp(home: NotificationScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('should show empty state when no notifications',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationListProvider.overrideWith(
              () => _DataNotificationList(
                const PaginatedState<NotificationEntity>(items: []),
              ),
            ),
          ],
          child: const MaterialApp(home: NotificationScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No notifications'), findsOneWidget);
    });

    testWidgets('should show notification list when data is loaded',
        (tester) async {
      final notifications = [
        NotificationEntity(
          id: '1',
          title: 'New link shared',
          body: 'Someone shared a link with you',
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
        NotificationEntity(
          id: '2',
          title: 'Collection updated',
          body: 'Your collection was updated',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          isRead: true,
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationListProvider.overrideWith(
              () => _DataNotificationList(
                PaginatedState<NotificationEntity>(items: notifications),
              ),
            ),
          ],
          child: const MaterialApp(home: NotificationScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('New link shared'), findsOneWidget);
      expect(find.text('Someone shared a link with you'), findsOneWidget);
      expect(find.text('Collection updated'), findsOneWidget);
    });

    testWidgets('should show unread indicator for unread notifications',
        (tester) async {
      final notifications = [
        NotificationEntity(
          id: '1',
          title: 'Unread notification',
          body: 'This is unread',
          createdAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationListProvider.overrideWith(
              () => _DataNotificationList(
                PaginatedState<NotificationEntity>(items: notifications),
              ),
            ),
          ],
          child: const MaterialApp(home: NotificationScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Unread notification'), findsOneWidget);
      // Unread notifications have bold text (fontWeight: w600)
      final titleWidget = tester.widget<Text>(
        find.text('Unread notification'),
      );
      expect(titleWidget.style?.fontWeight, FontWeight.w600);
    });
  });
}
