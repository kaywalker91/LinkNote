import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/app_update/data/datasource/package_info_datasource.dart';
import 'package:linknote/features/app_update/data/datasource/remote_config_update_datasource.dart';
import 'package:linknote/features/app_update/data/repository/app_update_repository_impl.dart';
import 'package:linknote/features/app_update/domain/entity/update_policy.dart';
import 'package:mocktail/mocktail.dart';

class MockRemoteConfig extends Mock implements RemoteConfigUpdateDataSource {}

class MockPackageInfo extends Mock implements PackageInfoDataSource {}

void main() {
  late AppUpdateRepositoryImpl sut;
  late MockRemoteConfig mockRemote;
  late MockPackageInfo mockPackage;

  setUp(() {
    mockRemote = MockRemoteConfig();
    mockPackage = MockPackageInfo();
    sut = AppUpdateRepositoryImpl(mockRemote, mockPackage);
  });

  RemoteUpdateConfig config({
    bool enabled = true,
    int min = 0,
    int latest = 0,
    String? optionalMessage,
    String? requiredMessage,
    String? storeUrl,
  }) => RemoteUpdateConfig(
    enabled: enabled,
    minVersionCode: min,
    latestVersionCode: latest,
    optionalMessage: optionalMessage,
    requiredMessage: requiredMessage,
    storeUrl: storeUrl,
  );

  void stub({required int current, required RemoteUpdateConfig remote}) {
    when(
      () => mockPackage.currentVersionCode(),
    ).thenAnswer((_) async => current);
    when(() => mockRemote.fetch()).thenAnswer((_) async => remote);
  }

  group('getUpdatePolicy', () {
    test('returns upToDate when the master switch is off', () async {
      stub(current: 1, remote: config(enabled: false, min: 99, latest: 99));

      final result = await sut.getUpdatePolicy();

      expect(result.data, const UpdatePolicy.upToDate());
      expect(result.isSuccess, isTrue);
    });

    test('returns forced when current < minVersionCode', () async {
      stub(
        current: 2,
        remote: config(
          min: 3,
          latest: 3,
          requiredMessage: 'must',
          storeUrl: 'u',
        ),
      );

      final result = await sut.getUpdatePolicy();

      expect(
        result.data,
        const UpdatePolicy.forced(
          minVersionCode: 3,
          message: 'must',
          storeUrl: 'u',
        ),
      );
    });

    test('force takes precedence over optional', () async {
      stub(current: 1, remote: config(min: 5, latest: 10));

      final result = await sut.getUpdatePolicy();

      expect(result.data, isA<ForcedUpdate>());
    });

    test('returns optional when min <= current < latest', () async {
      stub(
        current: 2,
        remote: config(min: 2, latest: 4, optionalMessage: 'new'),
      );

      final result = await sut.getUpdatePolicy();

      expect(
        result.data,
        const UpdatePolicy.optional(latestVersionCode: 4, message: 'new'),
      );
    });

    test('returns upToDate when current >= latest and >= min', () async {
      stub(current: 5, remote: config(min: 3, latest: 5));

      final result = await sut.getUpdatePolicy();

      expect(result.data, const UpdatePolicy.upToDate());
    });

    test('surfaces a Failure when a datasource throws', () async {
      when(
        () => mockPackage.currentVersionCode(),
      ).thenThrow(Exception('boom'));

      final result = await sut.getUpdatePolicy();

      expect(result.isFailure, isTrue);
      expect(result.data, isNull);
    });
  });
}
