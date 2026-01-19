import 'package:shared_preferences/shared_preferences.dart';

/// Handles local persistence of privacy-related histories (search/listen).
class PrivacyService {
  static const _searchHistoryKey = 'privacy.searchHistory';
  static const _listenHistoryKey = 'privacy.listenHistory';

  static Future<void> addSearchQuery(String query, {required bool enabled, int maxItems = 30}) async {
    if (!enabled || query.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getStringList(_searchHistoryKey) ?? <String>[];
    items.remove(query);
    items.insert(0, query);
    if (items.length > maxItems) {
      items.removeRange(maxItems, items.length);
    }
    await prefs.setStringList(_searchHistoryKey, items);
  }

  static Future<void> clearSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_searchHistoryKey);
  }

  static Future<void> addListen(String trackId, {required bool enabled, int maxItems = 100}) async {
    if (!enabled || trackId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getStringList(_listenHistoryKey) ?? <String>[];
    items.remove(trackId);
    items.insert(0, trackId);
    if (items.length > maxItems) {
      items.removeRange(maxItems, items.length);
    }
    await prefs.setStringList(_listenHistoryKey, items);
  }

  static Future<void> clearListenHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_listenHistoryKey);
  }
}
