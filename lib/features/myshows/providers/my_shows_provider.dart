import 'dart:async';
import 'dart:developer';

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
  bool _isLoading = false;
  StreamSubscription? _watchlistSubscription;
  final Map<String, Map<String, dynamic>> _itemsMap = {};

  MyShowsNotifier(this._ref) : super(const MyShowsState()) {
    _init();
  }

  void _init() {
    // Initial load
    _loadShows();
    
    // Subscribe to watchlist changes
    _watchlistSubscription = _ref.read(watchlistProvider.notifier).stream.listen((_) {
      _loadShows();
    });
  }

  @override
  void dispose() {
    _watchlistSubscription?.cancel();
    super.dispose();
  }

  /// Loads shows from watchlist and enriches them with status information
  /// Handles pagination, error states, and updates the UI accordingly
  Future<void> _loadShows() async {
    if (_isLoading) {
      log('Load already in progress, skipping duplicate call');
      return;
    }
    
    try {
      _isLoading = true;
      state = state.copyWith(
        isLoading: true,
        error: null,
        isRefreshing: state.hasData, // Only set to true if we already have data
      );

      final trakt = _ref.read(traktApiProvider);
      final watchlistState = _ref.read(watchlistProvider);
      final items = watchlistState.items;

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

      // Create a local map to track processed items
      final Map<String, Map<String, dynamic>> processedItemsMap = {};
      
      // Process items in chunks for parallel processing
      const chunkSize = 3; // Reduced chunk size for better reliability
      final chunks = <List<Map<String, dynamic>>>[];
      for (var i = 0; i < items.length; i += chunkSize) {
        final end = (i + chunkSize < items.length) ? i + chunkSize : items.length;
        chunks.add(items.sublist(i, end));
      }

      // Process each chunk in sequence
      for (final chunk in chunks) {
        // Process items in parallel within the chunk with error handling
        final results = await Future.wait(
          chunk.map((item) => _processShowItem(item, trakt)),
          eagerError: false, // Don't stop on first error
        );
        
        // Add successfully processed items to our local map
        for (final result in results) {
          if (result != null) {
            final show = result['show'] ?? result;
            final ids = show['ids'] ?? {};
            final traktId = (ids['slug'] ?? ids['trakt'])?.toString();
            if (traktId != null) {
              processedItemsMap[traktId] = result;
            }
          }
        }
        
        // Update the main items map with the new items
        _itemsMap.addAll(processedItemsMap);
        
        // Update state with current items
        if (_itemsMap.isNotEmpty) {
          state = state.copyWith(
            items: _itemsMap.values.toList(),
            hasData: true,
          );
        }
      }

      // Final state update
      state = state.copyWith(
        items: _itemsMap.values.toList(),
        isLoading: false,
        hasData: _itemsMap.isNotEmpty,
        isRefreshing: false,
      );
    } catch (e) {
      log('Error loading shows: $e');
      state = state.copyWith(
        error: 'Failed to load shows: $e',
        isLoading: false,
        isRefreshing: false,
      );
    } finally {
      _isLoading = false;
    }
  }
  
  Future<void> refresh() async {
    _itemsMap.clear();
    await _loadShows();
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

final myShowsWithStatusProvider = StateNotifierProvider<MyShowsNotifier, MyShowsState>((ref) {
  return MyShowsNotifier(ref);
});

// A separate provider to expose the items as a simple list for easier consumption
final myShowsListProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(myShowsWithStatusProvider.select((state) => state.items));
});
