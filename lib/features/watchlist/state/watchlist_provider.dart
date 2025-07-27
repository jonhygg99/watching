import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:watching/features/watchlist/state/watchlist_notifier.dart';

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
  final state = ref.watch(watchlistProvider);
  return state.items;
});

/// Provider for watchlist loading state
final watchlistLoadingProvider = Provider<bool>((ref) {
  return ref.watch(watchlistProvider).isLoading;
});

/// Provider for watchlist error state
final watchlistErrorProvider = Provider<String?>((ref) {
  final error = ref.watch(watchlistProvider).error;
  return error?.toString();
});

/// Provider for watchlist hasData state
final watchlistHasDataProvider = Provider<bool>((ref) {
  return ref.watch(watchlistProvider).hasData;
});
