import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:watching/providers/app_providers.dart';

/// Enum for watchlist type
enum WatchlistType { shows, movies }

/// Provider for selected watchlist type
final watchlistTypeProvider = StateProvider<WatchlistType>(
  (ref) => WatchlistType.shows,
);

/// Cache duration for watchlist data (5 minutes)
const _kWatchlistCacheDuration = Duration(minutes: 5);

/// State notifier for watchlist cache
class WatchlistCache {
  final Map<WatchlistType, (List<Map<String, dynamic>> data, DateTime timestamp)> _cache = {};
  
  /// Get the cache entry for a specific type
  (List<Map<String, dynamic>>, DateTime)? getCacheEntry(WatchlistType type) => _cache[type];

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

/// Provider for watchlist cache
final watchlistCacheProvider = Provider<WatchlistCache>(
  (ref) => WatchlistCache(),
);

/// Provider for watchlist state
class WatchlistState {
  final List<Map<String, dynamic>> items;
  final bool isLoading;
  final Object? error;
  final bool hasData;

  const WatchlistState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.hasData = false,
  });

  WatchlistState copyWith({
    List<Map<String, dynamic>>? items,
    bool? isLoading,
    Object? error,
    bool? hasData,
  }) {
    return WatchlistState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasData: hasData ?? this.hasData,
    );
  }
}

/// Notifier for watchlist state management
class WatchlistNotifier extends StateNotifier<WatchlistState> {
  final Ref _ref;
  StreamSubscription? _subscription;

  WatchlistNotifier(this._ref) : super(const WatchlistState()) {
    // Initial load
    _loadWatchlist();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  /// Load watchlist data with caching
  Future<void> _loadWatchlist() async {
    try {
      final type = _ref.read(watchlistTypeProvider);
      final cache = _ref.read(watchlistCacheProvider);

      // Check cache first
      final cachedData = cache.getCached(type);
      if (cachedData != null) {
        state = state.copyWith(
          items: cachedData,
          hasData: true,
          isLoading: true, // Still loading fresh data in background
        );
      } else {
        state = state.copyWith(isLoading: true);
      }

      // Fetch fresh data
      final trakt = _ref.read(traktApiProvider);
      final typeStr = type == WatchlistType.shows ? 'shows' : 'movies';

      // Fetch watchlist items from the API
      final items = await trakt.getWatched(type: typeStr);

      // Process items
      final processedItems = await _processItems(items);

      // Update cache
      cache.updateCache(type, processedItems);

      // Update state
      state = state.copyWith(
        items: processedItems,
        isLoading: false,
        hasData: true,
        error: null,
      );
    } catch (error, stackTrace) {
      debugPrint('Error loading watchlist: $error\n$stackTrace');
      state = state.copyWith(
        isLoading: false,
        error: error,
        hasData: state.items.isNotEmpty, // Keep existing data if available
      );
    }
  }

  /// Process watchlist items (fetch progress, next episode, etc.)
  Future<List<Map<String, dynamic>>> _processItems(List<dynamic> items) async {
    final trakt = _ref.read(traktApiProvider);
    final filteredItems = items.whereType<Map<String, dynamic>>().toList();

    final results = await Future.wait(
      filteredItems.map((item) => _processItem(item, trakt)),
      eagerError: true,
    );

    return results.whereType<Map<String, dynamic>>().toList();
  }

  /// Process a single watchlist item
  Future<Map<String, dynamic>?> _processItem(
    Map<String, dynamic> item,
    dynamic trakt,
  ) async {
    try {
      final show = item['show'] ?? item;
      final ids = show['ids'];
      final traktId = ids?['slug'] ?? ids?['trakt']?.toString();

      if (traktId == null) return null;

      // Fetch progress and next episode in parallel
      final progress = await trakt.getShowWatchedProgress(id: traktId);
      final nextEpisode = await _getNextEpisode(trakt, traktId, progress);

      if (nextEpisode != null) {
        progress['next_episode'] = nextEpisode;
      }

      return {...item, 'progress': progress};
    } catch (e) {
      debugPrint('Error processing item: $e');
      return {...item, 'progress': {}};
    }
  }

  /// Get next episode to watch
  Future<Map<String, dynamic>?> _getNextEpisode(
    dynamic trakt,
    String traktId,
    Map<String, dynamic> progress,
  ) async {
    try {
      if (progress['seasons'] is! List) return null;

      final seasons =
          (progress['seasons'] as List).where((s) => s['number'] != 0).toList();

      for (var season in seasons) {
        if (season['episodes'] is! List) continue;

        for (var episode in season['episodes']) {
          if (episode['completed'] == false) {
            try {
              final episodeInfo = await trakt.getEpisodeInfo(
                id: traktId,
                season: season['number'],
                episode: episode['number'],
              );
              return episodeInfo;
            } catch (e) {
              debugPrint('Error fetching episode info: $e');
              return null;
            }
          }
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error finding next episode: $e');
      return null;
    }
  }

  /// Refresh watchlist data
  Future<void> refresh() async {
    final type = _ref.read(watchlistTypeProvider);
    final cache = _ref.read(watchlistCacheProvider);
    
    // Get the cached entry
    final cachedData = cache.getCached(type);
    
    // If we have cached data, check if it's fresh enough
    if (cachedData != null) {
      final cacheEntry = cache.getCacheEntry(type);
      if (cacheEntry != null) {
        final (_, timestamp) = cacheEntry;
        final cacheAge = DateTime.now().difference(timestamp);
        if (cacheAge.inSeconds < 30) {
          // If cache is fresh, just update the state with cached data
          state = state.copyWith(
            items: cachedData,
            hasData: true,
            isLoading: false,
            error: null,
          );
          return;
        }
      }
    }
    
    // Otherwise, do a full refresh
    cache.invalidateCache(type);
    await _loadWatchlist();
  }

  /// Update a single show's progress in the watchlist
  Future<void> updateShowProgress(String traktId) async {
    try {
      // Find the show in the current state
      final index = state.items.indexWhere((item) {
        final ids = item['show']?['ids'] ?? item['ids'];
        return (ids?['trakt']?.toString() == traktId || ids?['slug'] == traktId);
      });

      if (index == -1) return;

      final trakt = _ref.read(traktApiProvider);
      
      // Fetch fresh progress data for this show
      final progress = await trakt.getShowWatchedProgress(id: traktId);
      final nextEpisode = await _getNextEpisode(trakt, traktId, progress);
      
      // Update the progress with next episode if available
      if (nextEpisode != null) {
        progress['next_episode'] = nextEpisode;
      }

      // Create updated items list
      final updatedItems = List<Map<String, dynamic>>.from(state.items);
      final item = updatedItems[index];
      final show = item['show'] ?? item;

      updatedItems[index] = {
        ...item,
        'progress': progress,
        'show': {
          ...show,
          'progress': progress,
        },
      };

      // Update cache first
      final type = _ref.read(watchlistTypeProvider);
      _ref.read(watchlistCacheProvider).updateCache(type, updatedItems);

      // Then update the state
      state = state.copyWith(
        items: updatedItems,
      );
    } catch (e) {
      debugPrint('Error updating show progress: $e');
      // If there's an error, do a full refresh to ensure consistency
      await refresh();
    }
  }
}

/// Provider for watchlist state
final watchlistProvider =
    StateNotifierProvider<WatchlistNotifier, WatchlistState>((ref) {
      return WatchlistNotifier(ref);
    });

/// Provider for watchlist items
final watchlistItemsProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(watchlistProvider.select((state) => state.items));
});

/// Provider for watchlist loading state
final watchlistLoadingProvider = Provider<bool>((ref) {
  return ref.watch(watchlistProvider.select((state) => state.isLoading));
});

/// Provider for watchlist error state
final watchlistErrorProvider = Provider<Object?>((ref) {
  return ref.watch(watchlistProvider.select((state) => state.error));
});
