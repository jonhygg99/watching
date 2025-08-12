import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:watching/api/trakt/trakt_api.dart';
import 'package:watching/features/watchlist/providers/watchlist_providers.dart';
import 'package:watching/features/watchlist/state/watchlist_notifier.dart';
import 'package:watching/providers/app_providers.dart';

class MyShowsState {
  final List<Map<String, dynamic>> items;
  final bool isLoading;
  final String? error;
  final bool hasData;
  final bool isRefreshing;

  const MyShowsState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.hasData = false,
    this.isRefreshing = false,
  });

  MyShowsState copyWith({
    List<Map<String, dynamic>>? items,
    bool? isLoading,
    String? error,
    bool? hasData,
    bool? isRefreshing,
  }) {
    return MyShowsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasData: hasData ?? this.hasData,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

class MyShowsNotifier extends StateNotifier<MyShowsState> {
  final Ref _ref;
  StreamSubscription? _watchlistSubscription;
  final Map<String, Map<String, dynamic>> _itemsMap = {};

  MyShowsNotifier(this._ref) : super(const MyShowsState()) {
    _init();
  }

  void _init() {
    // Initial load
    _loadShows();

    // Subscribe to watchlist changes
    _watchlistSubscription = _ref
        .read(watchlistProvider.notifier)
        .stream
        .listen((_) {
          _loadShows();
        });
  }

  @override
  void dispose() {
    _watchlistSubscription?.cancel();
    super.dispose();
  }

  /// Tracks the current load operation to prevent duplicates
  Future<void>? _currentLoadOperation;
  
  /// Loads shows from watchlist and enriches them with status information
  /// Processes shows in chunks to prevent UI freezing and provide better feedback
  Future<void> _loadShows() async {
    // If a load operation is already in progress, return that instead of starting a new one
    if (_currentLoadOperation != null) {
      debugPrint('Load operation already in progress, returning existing future');
      return _currentLoadOperation;
    }

    // Create a new future for this load operation
    final completer = Completer<void>();
    _currentLoadOperation = completer.future;

    try {
      debugPrint('Starting load operation with ${_itemsMap.length} cached items');
      
      // Only show loading state if we don't have any data yet
      if (!state.hasData || state.isRefreshing) {
        state = state.copyWith(
          isLoading: true,
          error: null,
          isRefreshing: state.hasData,
        );
      }

      final trakt = _ref.read(traktApiProvider);
      final watchlistState = _ref.read(watchlistProvider);
      final items = watchlistState.items;

      debugPrint('Processing ${items.length} shows from watchlist');

      // If we have no items, update state immediately
      if (items.isEmpty) {
        _itemsMap.clear();
        state = state.copyWith(
          items: [],
          isLoading: false,
          hasData: false,
          isRefreshing: false,
        );
        return;
      }

      // Process shows in chunks of 3
      const chunkSize = 3;
      int processedCount = 0;
      bool hasNewItems = false;
      
      // Only process new items that we haven't seen before
      final itemsToProcess = items.where((item) {
        final show = item['show'] ?? item;
        final ids = show['ids'] ?? {};
        final traktId = (ids['slug'] ?? ids['trakt'])?.toString();
        return traktId != null && !_itemsMap.containsKey(traktId);
      }).toList();

      debugPrint('Found ${itemsToProcess.length} new shows to process');

      // If we already have all items, just update the list order
      if (itemsToProcess.isEmpty) {
        debugPrint('No new shows to process, updating list order');
        final orderedItems = _orderItems(items);
        state = state.copyWith(
          items: orderedItems,
          isLoading: false,
          hasData: orderedItems.isNotEmpty,
          isRefreshing: false,
        );
        return;
      }

      for (var i = 0; i < itemsToProcess.length; i += chunkSize) {
        // Check if we've been cancelled
        if (completer.isCompleted) {
          debugPrint('Load operation was cancelled');
          return;
        }
        
        final chunk = itemsToProcess.sublist(
          i,
          i + chunkSize > itemsToProcess.length ? itemsToProcess.length : i + chunkSize,
        );

        debugPrint('Processing chunk ${i ~/ chunkSize + 1}/'
            '${(itemsToProcess.length / chunkSize).ceil()} (${chunk.length} items)');

        try {
          // Process current chunk in parallel
          final processedChunk = await Future.wait(
            chunk.map(
              (item) => _processShowItem(item, trakt).catchError((e) {
                debugPrint('Error processing show: $e');
                return null; // Return null for failed items
              }),
            ),
          );

          // Add valid items to the map
          int addedInChunk = 0;
          for (final item in processedChunk) {
            if (item != null) {
              final show = item['show'] ?? item;
              final ids = show['ids'] ?? {};
              final traktId = (ids['slug'] ?? ids['trakt'])?.toString();
              if (traktId != null) {
                _itemsMap[traktId] = item;
                addedInChunk++;
                hasNewItems = true;
              }
            }
          }
          
          processedCount += addedInChunk;
          debugPrint('Processed $addedInChunk new items in this chunk');

          // Only update state periodically to reduce rebuilds
          if (i % (chunkSize * 2) == 0 && hasNewItems) {
            final orderedItems = _orderItems(items);
            state = state.copyWith(
              items: orderedItems,
              hasData: orderedItems.isNotEmpty,
            );
            hasNewItems = false;
          }
        } catch (e) {
          debugPrint('Error processing chunk: $e');
          // Continue with next chunk even if one fails
        }
      }

      debugPrint('Successfully processed $processedCount/${itemsToProcess.length} new shows');
      
      // Final state update with all items in the correct order
      final orderedItems = _orderItems(items);
      state = state.copyWith(
        items: orderedItems,
        isLoading: false,
        hasData: orderedItems.isNotEmpty,
        isRefreshing: false,
      );
      
    } catch (e) {
      debugPrint('Error in _loadShows: $e');
      state = state.copyWith(
        error: 'Failed to load shows: $e',
        isLoading: false,
        isRefreshing: false,
      );
    } finally {
      _currentLoadOperation = null;
      if (!completer.isCompleted) {
        completer.complete();
      }
    }
  }

  Future<void> refresh() async {
    _itemsMap.clear();
    await _loadShows();
  }
  
  /// Orders items according to the original list order
  List<Map<String, dynamic>> _orderItems(List<dynamic> items) {
    final orderedItems = <Map<String, dynamic>>[];
    final itemMap = Map<String, Map<String, dynamic>>.from(_itemsMap);
    
    for (final item in items) {
      final show = item['show'] ?? item;
      final ids = show['ids'] ?? {};
      final traktId = (ids['slug'] ?? ids['trakt'])?.toString();
      if (traktId != null && itemMap.containsKey(traktId)) {
        orderedItems.add(itemMap[traktId]!);
      }
    }
    
    return orderedItems;
  }

  /// Helper method to process a single show item and fetch its status
  /// Returns null if the item is invalid or could not be processed
  Future<Map<String, dynamic>?> _processShowItem(
    Map<String, dynamic> item,
    TraktApi trakt,
  ) async {
    try {
      // Get the show ID
      final show = item['show'] ?? item;
      final ids = show['ids'] ?? {};
      final traktId = (ids['slug'] ?? ids['trakt'])?.toString();

      if (traktId == null || traktId.isEmpty) return null;

      // Try to get the existing item first to avoid unnecessary API calls
      if (!state.isRefreshing) {
        final existingItem = _itemsMap[traktId];
        if (existingItem != null) {
          return existingItem;
        }
      }

      // Get show details with status
      final showDetails = await trakt.getShowById(id: traktId).catchError((e) {
        log('Error fetching show details for $traktId: $e');
        return {'status': 'unknown'};
      });

      // Create a new map to avoid modifying the original
      final newItem = Map<String, dynamic>.from(item);
      newItem['status'] = showDetails['status'] ?? 'unknown';

      if (newItem['show'] != null) {
        newItem['show'] = Map<String, dynamic>.from(newItem['show']);
        newItem['show']['status'] = showDetails['status'] ?? 'unknown';
      }

      return newItem;
    } catch (e) {
      log('Error processing show: $e');
      // Return the original item with a default status
      final newItem = Map<String, dynamic>.from(item);
      newItem['status'] = 'unknown';
      return newItem;
    }
  }
}

final myShowsWithStatusProvider =
    StateNotifierProvider<MyShowsNotifier, MyShowsState>((ref) {
      return MyShowsNotifier(ref);
    });

// A separate provider to expose the items as a simple list for easier consumption
final myShowsListProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(myShowsWithStatusProvider.select((state) => state.items));
});
