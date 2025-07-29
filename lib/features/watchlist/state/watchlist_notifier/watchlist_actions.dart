import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:watching/features/watchlist/models/watchlist_state.dart';
import 'package:watching/features/watchlist/state/watchlist_notifier/watchlist_cache_handler.dart';
import 'package:watching/features/watchlist/services/watchlist_episode_service.dart';
import 'package:watching/features/watchlist/providers/watchlist_type_provider.dart';
import 'package:watching/providers/app_providers.dart';

/// Handles watchlist actions like refreshing and updating progress
class WatchlistActions {
  final Ref _ref;
  final WatchlistCacheHandler _cacheHandler;
  final WatchlistEpisodeService _episodeService;
  final void Function(bool, {Object? error}) updateLoadingState;
  final void Function(List<Map<String, dynamic>>) updateStateWithItems;
  final Future<void> Function({bool forceRefresh}) loadWatchlist;
  final Function() getCurrentState;
  final Function(WatchlistState) updateState;
  bool _isUpdatingProgress = false;

  WatchlistActions({
    required Ref ref,
    required WatchlistCacheHandler cacheHandler,
    required WatchlistEpisodeService episodeService,
    required this.updateLoadingState,
    required this.updateStateWithItems,
    required this.loadWatchlist,
    required this.getCurrentState,
    required this.updateState,
  }) : _ref = ref,
       _cacheHandler = cacheHandler,
       _episodeService = episodeService;

  /// Refresh the watchlist data
  Future<void> refreshWatchlist() async {
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

      // Otherwise, perform a full refresh
      await loadWatchlist(forceRefresh: true);
    } catch (e) {
      debugPrint('Failed to refresh watchlist: $e');
      rethrow;
    } finally {
      updateLoadingState(false);
    }
  }

  /// Update a show's progress in the watchlist
  Future<void> updateShowProgress(String traktId) async {
    if (_isUpdatingProgress || traktId.isEmpty) return;
    _isUpdatingProgress = true;
    
    try {
      updateLoadingState(true);

      // Invalidate the cache to force a fresh fetch
      final type = _ref.read(watchlistTypeProvider);
      _cacheHandler.invalidateCache(type);

      // Fetch fresh data from the API
      final trakt = _ref.read(traktApiProvider);

      // Get the progress data
      final progress = await trakt.getShowWatchedProgress(id: traktId);

      // Get the next episode if progress data is available
      final nextEpisode = progress.isNotEmpty
          ? await _episodeService.getNextEpisode(trakt, traktId, progress)
          : null;

      if (nextEpisode != null) {
        progress['next_episode'] = nextEpisode;
      }

      // Find the show in the current state
      final currentState = getCurrentState();
      final updatedItems = List<Map<String, dynamic>>.from(currentState.items);
      final index = updatedItems.indexWhere((item) {
        final showData = item['show'] ?? item;
        final ids = showData['ids'] ?? {};
        return (ids['trakt']?.toString() == traktId || ids['slug'] == traktId);
      });

      if (index != -1) {
        final item = updatedItems[index];
        final show = item['show'] ?? item;
        
        // Update the show with new progress data
        updatedItems[index] = {
          ...item,
          'progress': progress,
          'show': {
            ...show,
            'progress': progress,
            'ids': show['ids'] ?? {},
          },
        };

        // Update the state with the modified items
        updateState(currentState.copyWith(
          items: updatedItems,
          hasData: true,
          isLoading: false,
        ));

        // Update the cache with the fresh data
        _cacheHandler.updateCache(type, updatedItems);
      } else {
        // If show not found in current state, do a full refresh
        await refreshWatchlist();
      }
    } catch (e) {
      debugPrint('Failed to update show progress: $e');
      // Update state to reflect the error
      final currentState = getCurrentState();
      updateState(
        currentState.copyWith(
          error: 'Failed to update show progress: ${e.toString()}',
          isLoading: false,
        ),
      );
      rethrow;
    } finally {
      _isUpdatingProgress = false;
      updateLoadingState(false);
    }
  }
}
