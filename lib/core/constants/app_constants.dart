abstract final class AppConstants {
  static const String appName = 'LinkNote';

  // Network
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Debounce
  static const Duration searchDebounce = Duration(milliseconds: 300);
}
