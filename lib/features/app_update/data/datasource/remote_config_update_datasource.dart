import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:linknote/core/logger/app_logger.dart';
import 'package:linknote/features/app_update/app_update_constants.dart';

/// Snapshot of the remote update parameters (already type-coerced).
class RemoteUpdateConfig {
  const RemoteUpdateConfig({
    required this.enabled,
    required this.minVersionCode,
    required this.latestVersionCode,
    this.requiredMessage,
    this.optionalMessage,
    this.storeUrl,
  });

  final bool enabled;
  final int minVersionCode;
  final int latestVersionCode;
  final String? requiredMessage;
  final String? optionalMessage;
  final String? storeUrl;
}

/// Configure Remote Config defaults + fetch policy. Call once at boot after
/// `Firebase.initializeApp`. Never throws — update checks must not block boot.
Future<void> configureUpdateRemoteConfig({required bool isDev}) async {
  try {
    final rc = FirebaseRemoteConfig.instance;
    await rc.setConfigSettings(
      RemoteConfigSettings(
        // Dev fetches every launch; prod throttles to once per hour.
        minimumFetchInterval: isDev ? Duration.zero : const Duration(hours: 1),
        fetchTimeout: const Duration(seconds: 8),
      ),
    );
    await rc.setDefaults(const <String, Object>{
      AppUpdateConstants.keyEnabled: false,
      AppUpdateConstants.keyMinVersionCode: 0,
      AppUpdateConstants.keyLatestVersionCode: 0,
      AppUpdateConstants.keyRequiredMessage: '',
      AppUpdateConstants.keyOptionalMessage: '',
      AppUpdateConstants.keyStoreUrl: '',
    });
  } on Object catch (error, stack) {
    appLogger.w(
      'RemoteConfig setup failed; update gate falls back to defaults',
      error: error,
      stackTrace: stack,
    );
  }
}

class RemoteConfigUpdateDataSource {
  const RemoteConfigUpdateDataSource(this._remoteConfig);
  final FirebaseRemoteConfig _remoteConfig;

  /// Best-effort refresh, then read. A failed fetch keeps the last activated
  /// (or default) values, so the returned snapshot is always usable offline.
  Future<RemoteUpdateConfig> fetch() async {
    try {
      await _remoteConfig.fetchAndActivate();
    } on Object catch (error, stack) {
      appLogger.w(
        'RemoteConfig fetch failed; using cached/default values',
        error: error,
        stackTrace: stack,
      );
    }
    return RemoteUpdateConfig(
      enabled: _remoteConfig.getBool(AppUpdateConstants.keyEnabled),
      minVersionCode: _remoteConfig.getInt(
        AppUpdateConstants.keyMinVersionCode,
      ),
      latestVersionCode: _remoteConfig.getInt(
        AppUpdateConstants.keyLatestVersionCode,
      ),
      requiredMessage: _nullIfEmpty(
        _remoteConfig.getString(AppUpdateConstants.keyRequiredMessage),
      ),
      optionalMessage: _nullIfEmpty(
        _remoteConfig.getString(AppUpdateConstants.keyOptionalMessage),
      ),
      storeUrl: _nullIfEmpty(
        _remoteConfig.getString(AppUpdateConstants.keyStoreUrl),
      ),
    );
  }

  String? _nullIfEmpty(String value) => value.isEmpty ? null : value;
}
