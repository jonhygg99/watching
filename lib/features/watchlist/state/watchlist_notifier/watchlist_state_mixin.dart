import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:watching/features/watchlist/models/watchlist_state.dart';

/// Mixin for handling watchlist state management
mixin WatchlistStateMixin on StateNotifier<WatchlistState> {
  /// Update the state with new items while preserving other state
  void updateStateWithItems(
    List<Map<String, dynamic>> items, {
    bool isLoading = false,
    Object? error,
  }) {
    state = state.copyWith(
      items: items,
      isLoading: isLoading,
      hasData: items.isNotEmpty,
      error: error,
    );
  }

  /// Update the loading state
  void updateLoadingState(bool isLoading, {Object? error}) {
    state = state.copyWith(
      isLoading: isLoading,
      error: error,
      hasData: state.items.isNotEmpty, // Preserve existing data
    );
  }

  /// Merge new items with existing ones, avoiding duplicates
  List<Map<String, dynamic>> mergeItems(
    List<Map<String, dynamic>> currentItems,
    List<Map<String, dynamic>> newItems,
  ) {
    final merged = List<Map<String, dynamic>>.from(currentItems);
    final existingIds = currentItems.map((item) => getItemId(item)).toSet();

    for (final item in newItems) {
      final itemId = getItemId(item);
      if (!existingIds.contains(itemId)) {
        merged.add(item);
        existingIds.add(itemId);
      }
    }

    return merged;
  }

  /// Get unique ID for an item
  String getItemId(Map<String, dynamic> item) {
    final show = item['show'] ?? item;
    final ids = show['ids'] ?? {};
    return '${ids['trakt'] ?? ''}-${ids['slug'] ?? ''}-${ids['imdb'] ?? ''}';
  }

  /// Check if a show is completely watched based on its progress
  bool isShowCompleted(Map<String, dynamic> progress) {
    final int? aired =
        progress['aired'] is int ? progress['aired'] as int : null;
    final int? completed =
        progress['completed'] is int ? progress['completed'] as int : null;

    return aired != null &&
        completed != null &&
        aired > 0 &&
        completed >= aired;
  }
}
