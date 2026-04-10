// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_di_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(notificationRemoteDataSource)
final notificationRemoteDataSourceProvider =
    NotificationRemoteDataSourceProvider._();

final class NotificationRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          NotificationRemoteDataSource,
          NotificationRemoteDataSource,
          NotificationRemoteDataSource
        >
    with $Provider<NotificationRemoteDataSource> {
  NotificationRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationRemoteDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<NotificationRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationRemoteDataSource create(Ref ref) {
    return notificationRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationRemoteDataSource>(value),
    );
  }
}

String _$notificationRemoteDataSourceHash() =>
    r'ef98d06339b644e70b52c52a4a85785d9f5ee335';

@ProviderFor(notificationLocalDataSource)
final notificationLocalDataSourceProvider =
    NotificationLocalDataSourceProvider._();

final class NotificationLocalDataSourceProvider
    extends
        $FunctionalProvider<
          NotificationLocalDataSource,
          NotificationLocalDataSource,
          NotificationLocalDataSource
        >
    with $Provider<NotificationLocalDataSource> {
  NotificationLocalDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationLocalDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationLocalDataSourceHash();

  @$internal
  @override
  $ProviderElement<NotificationLocalDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationLocalDataSource create(Ref ref) {
    return notificationLocalDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationLocalDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationLocalDataSource>(value),
    );
  }
}

String _$notificationLocalDataSourceHash() =>
    r'98fd2da43684ca1f2d4605df51290922d41dc8e9';

@ProviderFor(notificationRepository)
final notificationRepositoryProvider = NotificationRepositoryProvider._();

final class NotificationRepositoryProvider
    extends
        $FunctionalProvider<
          INotificationRepository,
          INotificationRepository,
          INotificationRepository
        >
    with $Provider<INotificationRepository> {
  NotificationRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationRepositoryHash();

  @$internal
  @override
  $ProviderElement<INotificationRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  INotificationRepository create(Ref ref) {
    return notificationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(INotificationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<INotificationRepository>(value),
    );
  }
}

String _$notificationRepositoryHash() =>
    r'3fd40df4d2521a696d3bce6d1ad9c7989a98f1e4';

@ProviderFor(fetchNotificationsUsecase)
final fetchNotificationsUsecaseProvider = FetchNotificationsUsecaseProvider._();

final class FetchNotificationsUsecaseProvider
    extends
        $FunctionalProvider<
          FetchNotificationsUsecase,
          FetchNotificationsUsecase,
          FetchNotificationsUsecase
        >
    with $Provider<FetchNotificationsUsecase> {
  FetchNotificationsUsecaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fetchNotificationsUsecaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fetchNotificationsUsecaseHash();

  @$internal
  @override
  $ProviderElement<FetchNotificationsUsecase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FetchNotificationsUsecase create(Ref ref) {
    return fetchNotificationsUsecase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FetchNotificationsUsecase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FetchNotificationsUsecase>(value),
    );
  }
}

String _$fetchNotificationsUsecaseHash() =>
    r'd2b400ad1217bfa45f805f0c110d49d6ce3dd302';

@ProviderFor(markNotificationReadUsecase)
final markNotificationReadUsecaseProvider =
    MarkNotificationReadUsecaseProvider._();

final class MarkNotificationReadUsecaseProvider
    extends
        $FunctionalProvider<
          MarkNotificationReadUsecase,
          MarkNotificationReadUsecase,
          MarkNotificationReadUsecase
        >
    with $Provider<MarkNotificationReadUsecase> {
  MarkNotificationReadUsecaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'markNotificationReadUsecaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$markNotificationReadUsecaseHash();

  @$internal
  @override
  $ProviderElement<MarkNotificationReadUsecase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MarkNotificationReadUsecase create(Ref ref) {
    return markNotificationReadUsecase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MarkNotificationReadUsecase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MarkNotificationReadUsecase>(value),
    );
  }
}

String _$markNotificationReadUsecaseHash() =>
    r'9ba03deb2f214274ac5d88eaf8af217dbaa40ca3';

@ProviderFor(markAllNotificationsReadUsecase)
final markAllNotificationsReadUsecaseProvider =
    MarkAllNotificationsReadUsecaseProvider._();

final class MarkAllNotificationsReadUsecaseProvider
    extends
        $FunctionalProvider<
          MarkAllNotificationsReadUsecase,
          MarkAllNotificationsReadUsecase,
          MarkAllNotificationsReadUsecase
        >
    with $Provider<MarkAllNotificationsReadUsecase> {
  MarkAllNotificationsReadUsecaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'markAllNotificationsReadUsecaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$markAllNotificationsReadUsecaseHash();

  @$internal
  @override
  $ProviderElement<MarkAllNotificationsReadUsecase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MarkAllNotificationsReadUsecase create(Ref ref) {
    return markAllNotificationsReadUsecase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MarkAllNotificationsReadUsecase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MarkAllNotificationsReadUsecase>(
        value,
      ),
    );
  }
}

String _$markAllNotificationsReadUsecaseHash() =>
    r'5db49e4191f5185b829657d06a535e301f5f8c2f';
