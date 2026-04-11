import 'dart:convert';

import 'package:hive_ce/hive_ce.dart';

class SearchHistoryLocalDataSource {
  const SearchHistoryLocalDataSource(this._box);

  final Box<String> _box;

  static const String _key = 'recentSearches';
  static const int _maxEntries = 10;

  List<String> getRecentSearches() {
    final raw = _box.get(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.cast<String>();
    } on FormatException {
      return [];
    }
  }

  Future<void> saveRecentSearches(List<String> searches) async {
    final trimmed = searches.take(_maxEntries).toList();
    await _box.put(_key, jsonEncode(trimmed));
  }

  Future<void> addRecentSearch(String query) async {
    if (query.isEmpty) return;
    final current = getRecentSearches();
    final updated = [
      query,
      ...current.where((q) => q != query),
    ].take(_maxEntries).toList();
    await saveRecentSearches(updated);
  }

  Future<void> removeRecentSearch(String query) async {
    final current = getRecentSearches()..remove(query);
    await saveRecentSearches(current);
  }

  Future<void> clearRecentSearches() async {
    await _box.delete(_key);
  }
}
