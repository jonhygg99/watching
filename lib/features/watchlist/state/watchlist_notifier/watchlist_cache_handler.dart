import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:watching/features/watchlist/enums/watchlist_type.dart';
import 'package:watching/features/watchlist/providers/watchlist_cache_provider.dart';

/// Handles all cache-related operations for the watchlist
class WatchlistCacheHandler {
  final Ref _ref;
  
  WatchlistCacheHandler(this._ref);

  /// Loads cached data if available
  Future<List<Map<String, dynamic>>?> loadCachedData(WatchlistType type) async {
    try {
      final cache = _ref.read(watchlistCacheProvider);
      return cache.getCached(type);
    } catch (e) {
      debugPrint('Error loading cached data: $e');
      return null;
    }
  }

  /// Updates the cache with new data
  void updateCache(WatchlistType type, List<Map<String, dynamic>> items) {
    try {
      final cache = _ref.read(watchlistCacheProvider);
      cache.updateCache(type, items);
    } catch (e) {
      debugPrint('Error updating cache: $e');
    }
  }

  /// Invalidates the cache for a specific watchlist type
  void invalidateCache(WatchlistType type) {
    try {
      final cache = _ref.read(watchlistCacheProvider);
      cache.invalidateCache(type);
    } catch (e) {
      debugPrint('Error invalidating cache: $e');
    }
  }

  /// Checks if the cache is fresh (less than [maxAge] seconds old)
  bool isCacheFresh(WatchlistType type, {int maxAge = 30}) {
    try {
      final cache = _ref.read(watchlistCacheProvider);
      final cacheEntry = cache.getCacheEntry(type);
      
      if (cacheEntry == null) return false;
      
      final (_, timestamp) = cacheEntry;
      final cacheAge = DateTime.now().difference(timestamp);
      return cacheAge.inSeconds < maxAge;
    } catch (e) {
      debugPrint('Error checking cache freshness: $e');
      return false;
    }
  }

  /// Gets the cache entry for a specific watchlist type
  (List<Map<String, dynamic>>, DateTime)? getCacheEntry(WatchlistType type) {
    try {
      final cache = _ref.read(watchlistCacheProvider);
      return cache.getCacheEntry(type);
    } catch (e) {
      debugPrint('Error getting cache entry: $e');
      return null;
    }
  }
}
