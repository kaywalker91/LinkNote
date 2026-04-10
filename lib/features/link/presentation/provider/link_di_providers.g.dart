// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'link_di_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(linkRemoteDataSource)
final linkRemoteDataSourceProvider = LinkRemoteDataSourceProvider._();

final class LinkRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          LinkRemoteDataSource,
          LinkRemoteDataSource,
          LinkRemoteDataSource
        >
    with $Provider<LinkRemoteDataSource> {
  LinkRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'linkRemoteDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$linkRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<LinkRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LinkRemoteDataSource create(Ref ref) {
    return linkRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LinkRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LinkRemoteDataSource>(value),
    );
  }
}

String _$linkRemoteDataSourceHash() =>
    r'27227e73c9277a29e63fb367c5b703c9f2fc4b8b';

@ProviderFor(linkLocalDataSource)
final linkLocalDataSourceProvider = LinkLocalDataSourceProvider._();

final class LinkLocalDataSourceProvider
    extends
        $FunctionalProvider<
          LinkLocalDataSource,
          LinkLocalDataSource,
          LinkLocalDataSource
        >
    with $Provider<LinkLocalDataSource> {
  LinkLocalDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'linkLocalDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$linkLocalDataSourceHash();

  @$internal
  @override
  $ProviderElement<LinkLocalDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LinkLocalDataSource create(Ref ref) {
    return linkLocalDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LinkLocalDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LinkLocalDataSource>(value),
    );
  }
}

String _$linkLocalDataSourceHash() =>
    r'4a63b8eefc10359b0c447a355287aea62dda2835';

@ProviderFor(linkRepository)
final linkRepositoryProvider = LinkRepositoryProvider._();

final class LinkRepositoryProvider
    extends
        $FunctionalProvider<ILinkRepository, ILinkRepository, ILinkRepository>
    with $Provider<ILinkRepository> {
  LinkRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'linkRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$linkRepositoryHash();

  @$internal
  @override
  $ProviderElement<ILinkRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ILinkRepository create(Ref ref) {
    return linkRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ILinkRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ILinkRepository>(value),
    );
  }
}

String _$linkRepositoryHash() => r'6976e6880e1adbb3cd0c5e3bbccbad0a6d88d0d2';

@ProviderFor(fetchLinksUsecase)
final fetchLinksUsecaseProvider = FetchLinksUsecaseProvider._();

final class FetchLinksUsecaseProvider
    extends
        $FunctionalProvider<
          FetchLinksUsecase,
          FetchLinksUsecase,
          FetchLinksUsecase
        >
    with $Provider<FetchLinksUsecase> {
  FetchLinksUsecaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fetchLinksUsecaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fetchLinksUsecaseHash();

  @$internal
  @override
  $ProviderElement<FetchLinksUsecase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FetchLinksUsecase create(Ref ref) {
    return fetchLinksUsecase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FetchLinksUsecase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FetchLinksUsecase>(value),
    );
  }
}

String _$fetchLinksUsecaseHash() => r'c46a7b264a9d1eba6a51aa4ea7a3e4e59ab204c4';

@ProviderFor(createLinkUsecase)
final createLinkUsecaseProvider = CreateLinkUsecaseProvider._();

final class CreateLinkUsecaseProvider
    extends
        $FunctionalProvider<
          CreateLinkUsecase,
          CreateLinkUsecase,
          CreateLinkUsecase
        >
    with $Provider<CreateLinkUsecase> {
  CreateLinkUsecaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createLinkUsecaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createLinkUsecaseHash();

  @$internal
  @override
  $ProviderElement<CreateLinkUsecase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CreateLinkUsecase create(Ref ref) {
    return createLinkUsecase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateLinkUsecase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateLinkUsecase>(value),
    );
  }
}

String _$createLinkUsecaseHash() => r'83f5f5daa7d0f2caca7164a2d5e53c4a43a8af1b';

@ProviderFor(updateLinkUsecase)
final updateLinkUsecaseProvider = UpdateLinkUsecaseProvider._();

final class UpdateLinkUsecaseProvider
    extends
        $FunctionalProvider<
          UpdateLinkUsecase,
          UpdateLinkUsecase,
          UpdateLinkUsecase
        >
    with $Provider<UpdateLinkUsecase> {
  UpdateLinkUsecaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateLinkUsecaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateLinkUsecaseHash();

  @$internal
  @override
  $ProviderElement<UpdateLinkUsecase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UpdateLinkUsecase create(Ref ref) {
    return updateLinkUsecase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateLinkUsecase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateLinkUsecase>(value),
    );
  }
}

String _$updateLinkUsecaseHash() => r'2351d14b6454dfc8bccc90fd02bfe0feed5bd3b4';

@ProviderFor(deleteLinkUsecase)
final deleteLinkUsecaseProvider = DeleteLinkUsecaseProvider._();

final class DeleteLinkUsecaseProvider
    extends
        $FunctionalProvider<
          DeleteLinkUsecase,
          DeleteLinkUsecase,
          DeleteLinkUsecase
        >
    with $Provider<DeleteLinkUsecase> {
  DeleteLinkUsecaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteLinkUsecaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteLinkUsecaseHash();

  @$internal
  @override
  $ProviderElement<DeleteLinkUsecase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DeleteLinkUsecase create(Ref ref) {
    return deleteLinkUsecase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeleteLinkUsecase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeleteLinkUsecase>(value),
    );
  }
}

String _$deleteLinkUsecaseHash() => r'71ddea84e4e769f0172258be0071176173e7ce8b';

@ProviderFor(getLinkDetailUsecase)
final getLinkDetailUsecaseProvider = GetLinkDetailUsecaseProvider._();

final class GetLinkDetailUsecaseProvider
    extends
        $FunctionalProvider<
          GetLinkDetailUsecase,
          GetLinkDetailUsecase,
          GetLinkDetailUsecase
        >
    with $Provider<GetLinkDetailUsecase> {
  GetLinkDetailUsecaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getLinkDetailUsecaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getLinkDetailUsecaseHash();

  @$internal
  @override
  $ProviderElement<GetLinkDetailUsecase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetLinkDetailUsecase create(Ref ref) {
    return getLinkDetailUsecase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetLinkDetailUsecase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetLinkDetailUsecase>(value),
    );
  }
}

String _$getLinkDetailUsecaseHash() =>
    r'd977421bc18062acc25056b626525d0688c98ccc';

@ProviderFor(toggleFavoriteUsecase)
final toggleFavoriteUsecaseProvider = ToggleFavoriteUsecaseProvider._();

final class ToggleFavoriteUsecaseProvider
    extends
        $FunctionalProvider<
          ToggleFavoriteUsecase,
          ToggleFavoriteUsecase,
          ToggleFavoriteUsecase
        >
    with $Provider<ToggleFavoriteUsecase> {
  ToggleFavoriteUsecaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'toggleFavoriteUsecaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$toggleFavoriteUsecaseHash();

  @$internal
  @override
  $ProviderElement<ToggleFavoriteUsecase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ToggleFavoriteUsecase create(Ref ref) {
    return toggleFavoriteUsecase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ToggleFavoriteUsecase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ToggleFavoriteUsecase>(value),
    );
  }
}

String _$toggleFavoriteUsecaseHash() =>
    r'a755c7bb1be973a2cb84b54ae47ac23cdbdb4726';
