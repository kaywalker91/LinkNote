extension StringExtensions on String {
  bool get isValidUrl => Uri.tryParse(this)?.hasAbsolutePath ?? false;

  String truncated(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }
}
