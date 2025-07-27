import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:watching/features/watchlist/providers/watchlist_type_provider.dart';
import 'package:watching/features/watchlist/enums/watchlist_type.dart';
import 'package:watching/features/watchlist/state/watchlist_notifier/watchlist_cache_handler.dart';
import 'package:watching/providers/app_providers.dart';

/// Handles loading of watchlist data from cache and API
class WatchlistLoader {
  final Ref _ref;
  final WatchlistCacheHandler _cacheHandler;
  final Future<Map<String, dynamic>?> Function(Map<String, dynamic>, dynamic, {required Ref ref}) processItem;
  final List<Map<String, dynamic>> Function(List<Map<String, dynamic>>, List<Map<String, dynamic>>) mergeItems;
  final void Function(List<Map<String, dynamic>>) updateStateWithItems;
  final void Function(bool, {Object? error}) updateLoadingState;
  
  bool _isLoading = false;

  WatchlistLoader({
    required Ref ref,
    required WatchlistCacheHandler cacheHandler,
    required this.processItem,
    required this.mergeItems,
    required this.updateStateWithItems,
    required this.updateLoadingState,
  })  : _ref = ref,
        _cacheHandler = cacheHandler;

  /// Load cached data immediately
  Future<void> loadCachedData() async {
    try {
      final type = _ref.read(watchlistTypeProvider);
      final cachedData = await _cacheHandler.loadCachedData(type);

      if (cachedData != null) {
        updateStateWithItems(
          cachedData,
          // Still loading fresh data in background
        );
      }
    } catch (e) {
      debugPrint('Error loading cached data: $e');
    }
  }

  /// Load watchlist data with progressive loading
  Future<void> loadWatchlist({bool forceRefresh = false}) async {
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
      updateLoadingState(true);

      // Fetch watchlist items from the API
      final items = await trakt.getWatched(type: typeStr);

      // Process items in chunks for progressive loading
      const chunkSize = 5; // Process 5 items at a time
      final chunks = _chunkList(items, chunkSize);

      List<Map<String, dynamic>> allProcessedItems = [];

      for (final chunk in chunks) {
        // Process chunk in parallel
        final processedChunk = await Future.wait(
          chunk.map((item) => processItem(item, trakt, ref: _ref)),
          eagerError: true,
        );

        final validItems = processedChunk.whereType<Map<String, dynamic>>().toList();
        allProcessedItems.addAll(validItems);

        // Update state with new items as they become available
        if (validItems.isNotEmpty) {
          updateStateWithItems(allProcessedItems);
        }
      }

      // Final update with all items and update cache
      if (allProcessedItems.isNotEmpty) {
        _cacheHandler.updateCache(type, allProcessedItems);
        updateStateWithItems(allProcessedItems);
      }
    } catch (error) {
      updateLoadingState(false, error: error);
      rethrow;
    } finally {
      _isLoading = false;
    }
  }

  /// Split a list into chunks of the given size
  static List<List<T>> _chunkList<T>(List<T> list, int chunkSize) {
    List<List<T>> chunks = [];
    for (var i = 0; i < list.length; i += chunkSize) {
      chunks.add(list.sublist(i, i + chunkSize > list.length ? list.length : i + chunkSize));
    }
    return chunks;
  }
}
