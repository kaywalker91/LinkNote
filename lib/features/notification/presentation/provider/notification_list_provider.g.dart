// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NotificationList)
final notificationListProvider = NotificationListProvider._();

final class NotificationListProvider
    extends
        $AsyncNotifierProvider<
          NotificationList,
          PaginatedState<NotificationEntity>
        > {
  NotificationListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationListHash();

  @$internal
  @override
  NotificationList create() => NotificationList();
}

String _$notificationListHash() => r'489fa7c6b878d2fbe15ca1069b5c1ebb9367e0ee';

abstract class _$NotificationList
    extends $AsyncNotifier<PaginatedState<NotificationEntity>> {
  FutureOr<PaginatedState<NotificationEntity>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<PaginatedState<NotificationEntity>>,
              PaginatedState<NotificationEntity>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PaginatedState<NotificationEntity>>,
                PaginatedState<NotificationEntity>
              >,
              AsyncValue<PaginatedState<NotificationEntity>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
