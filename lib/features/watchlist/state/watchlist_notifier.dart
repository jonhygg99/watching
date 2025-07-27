import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:watching/features/watchlist/enums/watchlist_type.dart';
import 'package:watching/features/watchlist/models/watchlist_state.dart';
import 'package:watching/features/watchlist/providers/watchlist_type_provider.dart';
import 'package:watching/features/watchlist/services/watchlist_episode_service.dart';
import 'package:watching/features/watchlist/services/watchlist_processor.dart';
import 'package:watching/features/watchlist/state/watchlist_notifier/watchlist_state_mixin.dart';
import 'package:watching/features/watchlist/state/watchlist_notifier/watchlist_cache_handler.dart';
import 'package:watching/features/watchlist/services/watchlist_episode_actions.dart';
import 'package:watching/providers/app_providers.dart';
import 'package:collection/collection.dart';

// Export types for easy importing
export 'package:watching/features/watchlist/enums/watchlist_type.dart'
    show WatchlistType;
export 'package:watching/features/watchlist/models/watchlist_state.dart'
    show WatchlistState;

/// Notifier for watchlist state management
class WatchlistNotifier extends StateNotifier<WatchlistState>
    with WatchlistStateMixin {
  final Ref _ref;
  late final WatchlistEpisodeService _episodeService;
  late final WatchlistProcessor _processor;
  late final WatchlistCacheHandler _cacheHandler;
  late final WatchlistEpisodeActions _episodeActions;
  StreamSubscription? _subscription;
  bool _isLoading = false;

  WatchlistNotifier(this._ref)
    : _episodeService = WatchlistEpisodeService(_ref),
      super(const WatchlistState()) {
    _processor = WatchlistProcessor(_ref);
    _cacheHandler = WatchlistCacheHandler(_ref);
    _episodeActions = WatchlistEpisodeActions(
      ref: _ref,
      episodeService: _episodeService,
      updateState: (state) => this.state = state,
      updateLoadingState: (isLoading) {
        state = state.copyWith(isLoading: isLoading);
      },
      updateStateWithItems: updateStateWithItems,
      mergeItems: mergeItems,
      updateShowProgress: updateShowProgress,
      refresh: refresh,
      isShowCompleted: isShowCompleted,
      cacheHandler: _cacheHandler,
      getTypeString: (type) => type == WatchlistType.shows ? 'show' : 'movie',
    );

    // Initial load with cached data first
    _loadCachedData().then((_) {
      // Then load fresh data in background
      _loadWatchlist();
    });
  }

  // Delegate episode-related actions to WatchlistEpisodeActions
  Future<void> markEpisodeAsWatched(String traktId) =>
      _episodeActions.markEpisodeAsWatched(traktId);
  Future<void> markEpisodeAsUnwatched(String traktId) =>
      _episodeActions.markEpisodeAsUnwatched(traktId);
  Future<void> toggleEpisodeWatchedStatus({
    required String showTraktId,
    required int seasonNumber,
    required int episodeNumber,
    required bool watched,
  }) => _episodeActions.toggleEpisodeWatchedStatus(
    showTraktId: showTraktId,
    seasonNumber: seasonNumber,
    episodeNumber: episodeNumber,
    watched: watched,
  );

  /// Load cached data immediately
  Future<void> _loadCachedData() async {
    try {
      final type = _ref.read(watchlistTypeProvider);
      final cachedData = await _cacheHandler.loadCachedData(type);

      if (cachedData != null) {
        updateStateWithItems(
          cachedData,
          isLoading: true, // Still loading fresh data in background
        );
      }
    } catch (e) {
      debugPrint('Error loading cached data: $e');
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  /// Load watchlist data with progressive loading
  Future<void> _loadWatchlist({bool forceRefresh = false}) async {
    try {
      if (_isLoading) return;
      _isLoading = true;
      updateLoadingState(true);

      final trakt = _ref.read(traktApiProvider);
      final type = _ref.read(watchlistTypeProvider);

      if (forceRefresh) {
        _cacheHandler.invalidateCache(type);
      }

      final typeStr = type == WatchlistType.shows ? 'show' : 'movie';

      // Start with loading state if we don't have cached data or forcing refresh
      if (state.items.isEmpty || forceRefresh) {
        updateLoadingState(true);
      }

      // Fetch watchlist items from the API
      final items = await trakt.getWatched(type: typeStr);

      // Process items in chunks for progressive loading
      final chunkSize = 5; // Process 5 items at a time
      final chunks = items.slices(chunkSize);

      List<Map<String, dynamic>> allProcessedItems = [];

      for (final chunk in chunks) {
        // Process chunk in parallel
        final processedChunk = await Future.wait(
          chunk.map((item) => _processItem(item, trakt, ref: _ref)),
          eagerError: true,
        );

        final validItems =
            processedChunk.whereType<Map<String, dynamic>>().toList();
        allProcessedItems.addAll(validItems);

        // Update state with new items as they become available
        if (validItems.isNotEmpty) {
          final currentItems = state.items.toList();
          final newItems = mergeItems(currentItems, validItems);

          updateStateWithItems(newItems);
        }
      }

      // Final update with all items and update cache
      if (allProcessedItems.isNotEmpty) {
        _cacheHandler.updateCache(type, allProcessedItems);
        updateStateWithItems(allProcessedItems);
      }
    } catch (error) {
      updateLoadingState(false, error: error);
    }
  }

  // Moved to WatchlistStateMixin

  /// Process a single watchlist item
  Future<Map<String, dynamic>?> _processItem(
    Map<String, dynamic> item,
    dynamic trakt, {
    required Ref ref,
  }) async {
    try {
      return await _processor.processItem(item, trakt);
    } catch (e) {
      return null;
    }
  }

  /// Refresh the watchlist data
  ///
  /// This will first check if we have fresh cached data (less than 30 seconds old).
  /// If not, it will perform a full refresh from the API.
  Future<void> refresh() async {
    try {
      updateLoadingState(true);

      final type = _ref.read(watchlistTypeProvider);

      // If we have fresh cached data, use it
      if (_cacheHandler.isCacheFresh(type)) {
        final cachedData = await _cacheHandler.loadCachedData(type);
        if (cachedData != null) {
          updateStateWithItems(cachedData);
          return;
        }
      }

      // Otherwise, do a full refresh
      await _loadWatchlist(forceRefresh: true);
    } catch (e) {
      final error =
          e is Exception ? e : Exception('Failed to refresh watchlist: $e');
      debugPrint('Error in refresh: $error');
      updateLoadingState(false, error: error.toString());
      rethrow;
    }
  }

  /// Update a single show's progress in the watchlist
  Future<void> updateShowProgress(String traktId) async {
    if (traktId.isEmpty) {
      return;
    }

    try {
      // Invalidate the cache to force a fresh fetch
      final type = _ref.read(watchlistTypeProvider);
      _cacheHandler.invalidateCache(type);

      // Fetch fresh data from the API
      final trakt = _ref.read(traktApiProvider);

      // Get the progress data
      final progress = await trakt.getShowWatchedProgress(id: traktId);

      // Get the next episode if progress data is available
      final nextEpisode =
          progress.isNotEmpty
              ? await _episodeService.getNextEpisode(trakt, traktId, progress)
              : null;

      if (nextEpisode != null) {
        progress['next_episode'] = nextEpisode;
      }

      // Find the show in the current state
      final updatedItems = List<Map<String, dynamic>>.from(state.items);
      final index = updatedItems.indexWhere((item) {
        final showData = item['show'] ?? item;
        final ids = showData['ids'] ?? {};
        final matches =
            (ids['trakt']?.toString() == traktId || ids['slug'] == traktId);
        return matches;
      });

      if (index != -1) {
        final item = updatedItems[index];
        final show = item['show'] ?? item;

        // Create updated item with new progress
        final updatedItem = {
          ...item,
          'progress': progress,
          'show': {...show, 'progress': progress, 'ids': show['ids'] ?? {}},
        };

        updatedItems[index] = updatedItem;

        try {
          // Update the cache with the fresh data
          _cacheHandler.updateCache(type, updatedItems);

          // Update the state
          state = state.copyWith(
            items: updatedItems,
            hasData: true,
            isLoading: false,
          );
        } catch (cacheError) {
          // Try a full refresh if cache update fails
          await refresh();
        }
      } else {
        // If show not found in current state, do a full refresh
        await refresh();
      }
    } catch (e) {
      // Fall back to a full refresh if anything goes wrong
      try {
        await refresh();
      } catch (refreshError) {
        // Update state to reflect the error
        state = state.copyWith(
          error: 'Failed to update show progress: ${e.toString()}',
          isLoading: false,
        );
      }
    }
  }
}

/// Provider for watchlist state
final watchlistProvider =
    StateNotifierProvider<WatchlistNotifier, WatchlistState>((ref) {
      final notifier = WatchlistNotifier(ref);
      // Initial load
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifier.refresh();
      });
      return notifier;
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
