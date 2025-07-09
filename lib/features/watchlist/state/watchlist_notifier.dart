import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:watching/features/watchlist/enums/watchlist_type.dart';
import 'package:watching/features/watchlist/models/watchlist_state.dart';
import 'package:watching/features/watchlist/providers/watchlist_type_provider.dart';
import 'package:watching/features/watchlist/providers/watchlist_cache_provider.dart';
import 'package:watching/features/watchlist/services/watchlist_episode_service.dart';
import 'package:watching/features/watchlist/services/watchlist_processor.dart';
import 'package:watching/providers/app_providers.dart';

// Export types for easy importing
export 'package:watching/features/watchlist/enums/watchlist_type.dart' show WatchlistType;
export 'package:watching/features/watchlist/models/watchlist_state.dart' show WatchlistState;

/// Notifier for watchlist state management
class WatchlistNotifier extends StateNotifier<WatchlistState> {
  final Ref _ref;
  StreamSubscription? _subscription;

  WatchlistNotifier(this._ref) : super(const WatchlistState()) {
    _episodeService = WatchlistEpisodeService(_ref);
    _processor = WatchlistProcessor(_ref);
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
      filteredItems.map((item) => _processItem(item, trakt, ref: _ref)),
      eagerError: true,
    );

    return results.whereType<Map<String, dynamic>>().toList();
  }

  late final WatchlistEpisodeService _episodeService;
  late final WatchlistProcessor _processor;

  /// Process a single watchlist item
  Future<Map<String, dynamic>?> _processItem(
    Map<String, dynamic> item,
    dynamic trakt, {
    required Ref ref,
  }) async {
    try {
      return await _processor.processItem(item, trakt);
    } catch (e) {
      debugPrint('Error in _processItem: $e');
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
      // First, invalidate the cache to force a fresh fetch
      final type = _ref.read(watchlistTypeProvider);
      final cache = _ref.read(watchlistCacheProvider);
      cache.invalidateCache(type);

      // Fetch fresh data from the API
      final trakt = _ref.read(traktApiProvider);
      final progress = await trakt.getShowWatchedProgress(id: traktId);
      final nextEpisode = await _episodeService.getNextEpisode(trakt, traktId, progress);

      if (nextEpisode != null) {
        progress['next_episode'] = nextEpisode;
      }

      // Find the show in the current state and update its progress
      final updatedItems = List<Map<String, dynamic>>.from(state.items);
      final index = updatedItems.indexWhere((item) {
        final ids = item['show']?['ids'] ?? item['ids'];
        return (ids?['trakt']?.toString() == traktId ||
            ids?['slug'] == traktId);
      });

      if (index != -1) {
        final item = updatedItems[index];
        final show = item['show'] ?? item;

        updatedItems[index] = {
          ...item,
          'progress': progress,
          'show': {...show, 'progress': progress},
        };

        // Update the cache with the fresh data
        cache.updateCache(type, updatedItems);

        // Update the state
        state = state.copyWith(items: updatedItems);
      } else {
        // If show not found in current state, do a full refresh
        await refresh();
      }
    } catch (e) {
      debugPrint('Error updating show progress: $e');
      // Fall back to a full refresh if anything goes wrong
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
