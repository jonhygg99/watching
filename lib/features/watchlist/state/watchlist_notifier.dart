import 'dart:async';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:watching/features/watchlist/enums/watchlist_type.dart';
import 'package:watching/features/watchlist/models/watchlist_state.dart';
import 'package:watching/features/watchlist/services/watchlist_episode_service.dart';
import 'package:watching/features/watchlist/services/watchlist_processor.dart';
import 'package:watching/features/watchlist/state/watchlist_notifier/watchlist_state_mixin.dart';
import 'package:watching/features/watchlist/state/watchlist_notifier/watchlist_cache_handler.dart';
import 'package:watching/features/watchlist/services/watchlist_episode_actions.dart';
import 'package:watching/providers/app_providers.dart';
import 'watchlist_actions.dart';
import 'watchlist_loader.dart';

// Export types for easy importing
export 'package:watching/features/watchlist/enums/watchlist_type.dart'
    show WatchlistType;
export 'package:watching/features/watchlist/models/watchlist_state.dart'
    show WatchlistState;

// Export providers from the watchlist_provider.dart file
export 'watchlist_provider.dart' show 
  watchlistProvider,
  watchlistItemsProvider,
  watchlistLoadingProvider,
  watchlistErrorProvider,
  watchlistHasDataProvider;

/// Notifier for watchlist state management
class WatchlistNotifier extends StateNotifier<WatchlistState>
    with WatchlistStateMixin {
  final Ref _ref;
  late final WatchlistEpisodeService _episodeService;
  late final WatchlistProcessor _processor;
  late final WatchlistCacheHandler _cacheHandler;
  late final WatchlistEpisodeActions _episodeActions;
  late final WatchlistActions _watchlistActions;
  late final WatchlistLoader _watchlistLoader;
  StreamSubscription? _subscription;
  bool _isInitialized = false;

  WatchlistNotifier(this._ref) : super(const WatchlistState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    if (_isInitialized) return;
    
    _episodeService = WatchlistEpisodeService(_ref);
    _processor = WatchlistProcessor(_ref);
    _cacheHandler = WatchlistCacheHandler(_ref);
    
    // Initialize loader first as it's needed by actions
    _watchlistLoader = WatchlistLoader(
      ref: _ref,
      cacheHandler: _cacheHandler,
      processItem: _processItem,
      mergeItems: mergeItems,
      updateStateWithItems: updateStateWithItems,
      updateLoadingState: (isLoading, {error}) => updateLoadingState(isLoading, error: error),
    );

    // Then initialize actions
    _watchlistActions = WatchlistActions(
      ref: _ref,
      cacheHandler: _cacheHandler,
      episodeService: _episodeService,
      updateLoadingState: (isLoading, {error}) => updateLoadingState(isLoading, error: error),
      updateStateWithItems: updateStateWithItems,
      loadWatchlist: _watchlistLoader.loadWatchlist,
      getCurrentState: () => state,
      updateState: (newState) => state = newState,
    );

    // Finally initialize episode actions
    _episodeActions = WatchlistEpisodeActions(
      ref: _ref,
      episodeService: _episodeService,
      updateState: (state) => this.state = state,
      updateLoadingState: (isLoading) => state = state.copyWith(isLoading: isLoading),
      updateStateWithItems: updateStateWithItems,
      mergeItems: mergeItems,
      updateShowProgress: updateShowProgress,
      refresh: refresh,
      isShowCompleted: isShowCompleted,
      cacheHandler: _cacheHandler,
      getTypeString: (type) => type == WatchlistType.shows ? 'show' : 'movie',
    );

    _isInitialized = true;

    // Initial load with cached data first
    await _watchlistLoader.loadCachedData();
    // Then load fresh data in background
    unawaited(_watchlistLoader.loadWatchlist());
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



  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

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

  Future<void> updateShowProgress(String traktId) async {
    if (!_isInitialized) await _initialize();
    return _watchlistActions.updateShowProgress(traktId);
  }

  Future<void> refresh() async {
    if (!_isInitialized) await _initialize();
    return _watchlistActions.refreshWatchlist();
  }
}


