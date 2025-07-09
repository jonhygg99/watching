import 'package:watching/features/watchlist/enums/watchlist_type.dart';

/// Cache duration for watchlist data (5 minutes)
const _kWatchlistCacheDuration = Duration(minutes: 5);

/// Class for managing watchlist cache
class WatchlistCache {
  final Map<
    WatchlistType,
    (List<Map<String, dynamic>> data, DateTime timestamp)
  > _cache = {};

  /// Get the cache entry for a specific type
  (List<Map<String, dynamic>>, DateTime)? getCacheEntry(WatchlistType type) =>
      _cache[type];

  /// Get cached data if it exists and is not expired
  List<Map<String, dynamic>>? getCached(WatchlistType type) {
    final cached = _cache[type];
    if (cached != null) {
      final (data, timestamp) = cached;
      if (DateTime.now().difference(timestamp) < _kWatchlistCacheDuration) {
        return data;
      }
    }
    return null;
  }

  /// Update cache for a specific type
  void updateCache(WatchlistType type, List<Map<String, dynamic>> data) {
    _cache[type] = (List<Map<String, dynamic>>.from(data), DateTime.now());
  }

  /// Invalidate cache for a specific type
  void invalidateCache(WatchlistType type) {
    _cache.remove(type);
  }
}
