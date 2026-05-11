// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_stats_di_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(readingStatsLocalDatasource)
final readingStatsLocalDatasourceProvider =
    ReadingStatsLocalDatasourceProvider._();

final class ReadingStatsLocalDatasourceProvider
    extends
        $FunctionalProvider<
          ReadingStatsLocalDatasource,
          ReadingStatsLocalDatasource,
          ReadingStatsLocalDatasource
        >
    with $Provider<ReadingStatsLocalDatasource> {
  ReadingStatsLocalDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readingStatsLocalDatasourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readingStatsLocalDatasourceHash();

  @$internal
  @override
  $ProviderElement<ReadingStatsLocalDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReadingStatsLocalDatasource create(Ref ref) {
    return readingStatsLocalDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReadingStatsLocalDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReadingStatsLocalDatasource>(value),
    );
  }
}

String _$readingStatsLocalDatasourceHash() =>
    r'6655eaf525398583aad2d9caae762f7f1c46abad';

@ProviderFor(readingStatsRepository)
final readingStatsRepositoryProvider = ReadingStatsRepositoryProvider._();

final class ReadingStatsRepositoryProvider
    extends
        $FunctionalProvider<
          IReadingStatsRepository,
          IReadingStatsRepository,
          IReadingStatsRepository
        >
    with $Provider<IReadingStatsRepository> {
  ReadingStatsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readingStatsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readingStatsRepositoryHash();

  @$internal
  @override
  $ProviderElement<IReadingStatsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  IReadingStatsRepository create(Ref ref) {
    return readingStatsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IReadingStatsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IReadingStatsRepository>(value),
    );
  }
}

String _$readingStatsRepositoryHash() =>
    r'565655102a293e791c25d4ae0b64af204d75e285';

@ProviderFor(recordReadEventUsecase)
final recordReadEventUsecaseProvider = RecordReadEventUsecaseProvider._();

final class RecordReadEventUsecaseProvider
    extends
        $FunctionalProvider<
          RecordReadEventUsecase,
          RecordReadEventUsecase,
          RecordReadEventUsecase
        >
    with $Provider<RecordReadEventUsecase> {
  RecordReadEventUsecaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recordReadEventUsecaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recordReadEventUsecaseHash();

  @$internal
  @override
  $ProviderElement<RecordReadEventUsecase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RecordReadEventUsecase create(Ref ref) {
    return recordReadEventUsecase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecordReadEventUsecase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecordReadEventUsecase>(value),
    );
  }
}

String _$recordReadEventUsecaseHash() =>
    r'5f186c149012356608b2762b0de26102dbef58bf';

@ProviderFor(getReadingStatsUsecase)
final getReadingStatsUsecaseProvider = GetReadingStatsUsecaseProvider._();

final class GetReadingStatsUsecaseProvider
    extends
        $FunctionalProvider<
          GetReadingStatsUsecase,
          GetReadingStatsUsecase,
          GetReadingStatsUsecase
        >
    with $Provider<GetReadingStatsUsecase> {
  GetReadingStatsUsecaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getReadingStatsUsecaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getReadingStatsUsecaseHash();

  @$internal
  @override
  $ProviderElement<GetReadingStatsUsecase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetReadingStatsUsecase create(Ref ref) {
    return getReadingStatsUsecase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetReadingStatsUsecase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetReadingStatsUsecase>(value),
    );
  }
}

String _$getReadingStatsUsecaseHash() =>
    r'86fbc7931e4da15c634a9bd050f10bae22c60329';
