/// Remote Config keys + client defaults for the in-app update gate.
///
/// The gate compares the running Android `versionCode` against remote values.
/// Defaults are intentionally inert (disabled / 0) so a brand-new install can
/// never be forced before the first successful fetch.
abstract final class AppUpdateConstants {
  // Remote Config parameter keys.
  static const String keyEnabled = 'android_updates_enabled';
  static const String keyMinVersionCode = 'android_min_supported_version_code';
  static const String keyLatestVersionCode = 'android_latest_version_code';
  static const String keyRequiredMessage = 'android_update_message_required';
  static const String keyOptionalMessage = 'android_update_message_optional';
  static const String keyStoreUrl = 'android_play_store_url';

  /// Prod Play listing. Android routes the https link to the Play Store app.
  static const String defaultStoreUrl =
      'https://play.google.com/store/apps/details?id=app.kaywalker.linknote';

  /// Hive `settings` box key persisting the last version the user dismissed an
  /// optional prompt for. Re-prompt only when a strictly newer version ships.
  static const String dismissedVersionKey = 'update_dismissed_version_code';
}
