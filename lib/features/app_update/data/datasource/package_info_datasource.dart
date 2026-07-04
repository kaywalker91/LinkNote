import 'package:package_info_plus/package_info_plus.dart';

class PackageInfoDataSource {
  const PackageInfoDataSource();

  /// The running Android `versionCode` (`pubspec` `+N`). Version *name* strings
  /// are never compared — integer version codes are the only reliable ordering.
  Future<int> currentVersionCode() async {
    final info = await PackageInfo.fromPlatform();
    return int.tryParse(info.buildNumber) ?? 0;
  }
}
