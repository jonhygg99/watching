import 'package:watching/features/watchlist/enums/watchlist_type.dart';

// Re-export all watchlist-related providers
export 'package:watching/features/watchlist/state/watchlist_notifier.dart' show
    watchlistProvider,
    watchlistItemsProvider,
    watchlistLoadingProvider,
    watchlistErrorProvider;

export 'watchlist_type_provider.dart' show watchlistTypeProvider;

/// Cache for watchlist data
class WatchlistCache {
  final Map<WatchlistType, (List<Map<String, dynamic>> items, DateTime timestamp)> _cache = {};

  List<Map<String, dynamic>>? getCached(WatchlistType type) {
    final cacheEntry = _cache[type];
    if (cacheEntry == null) return null;
    return cacheEntry.$1;
  }

  (List<Map<String, dynamic>>, DateTime)? getCacheEntry(WatchlistType type) {
    final cacheEntry = _cache[type];
    if (cacheEntry == null) return null;
    return cacheEntry;
  }

  void updateCache(WatchlistType type, List<Map<String, dynamic>> items) {
    _cache[type] = (items, DateTime.now());
  }

  void invalidateCache(WatchlistType type) {
    _cache.remove(type);
  }
}
