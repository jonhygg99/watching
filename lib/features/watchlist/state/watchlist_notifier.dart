import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:watching/features/watchlist/enums/watchlist_type.dart';
import 'package:watching/features/watchlist/models/watchlist_state.dart';
import 'package:watching/features/watchlist/providers/watchlist_type_provider.dart';
import 'package:watching/features/watchlist/providers/watchlist_cache_provider.dart';
import 'package:watching/features/watchlist/services/watchlist_episode_service.dart';
import 'package:watching/features/watchlist/services/watchlist_processor.dart';
import 'package:watching/features/watchlist/state/watchlist_notifier/watchlist_state_mixin.dart';
import 'package:watching/features/watchlist/state/watchlist_notifier/watchlist_cache_handler.dart';
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
  StreamSubscription? _subscription;
  bool _isLoading = false;

  WatchlistNotifier(this._ref)
    : _episodeService = WatchlistEpisodeService(_ref),
      super(const WatchlistState()) {
    _processor = WatchlistProcessor(_ref);
    _cacheHandler = WatchlistCacheHandler(_ref);
    
    // Initial load with cached data first
    _loadCachedData().then((_) {
      // Then load fresh data in background
      _loadWatchlist();
    });
  }

  // Moved to WatchlistEpisodeService

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

  // Moved to WatchlistStateMixin

  /// Mark the next episode as watched
  Future<void> markEpisodeAsWatched(String traktId) async {
    if (traktId.isEmpty) {
      return;
    }

    try {
      final trakt = _ref.read(traktApiProvider);

      // Handle both numeric IDs and slugs
      final bool isNumericId = int.tryParse(traktId) != null;
      final String showIdToUse = traktId;

      // Get current progress with error handling
      Map<String, dynamic> progress;
      try {
        progress = await _episodeService.updateShowProgress(trakt, showIdToUse);
      } catch (e) {
        rethrow;
      }

      // Try to get the next episode
      Map<String, dynamic>? nextEpisode;
      try {
        nextEpisode = await _episodeService.getNextEpisode(
          trakt,
          showIdToUse,
          progress,
        );
        nextEpisode ??= _episodeService.findNextEpisode(progress);
      } catch (e) {
        nextEpisode = _episodeService.findNextEpisode(progress);
      }

      if (nextEpisode == null) {
        throw Exception(
          'No next episode found to mark as watched for show: $traktId',
        );
      }

      // Handle different possible response formats
      final episodeData =
          nextEpisode['episode'] ?? nextEpisode['Episode'] ?? nextEpisode;

      // If we don't have episode data, we can't proceed
      if (episodeData == null) {
        throw Exception('Could not find episode information in: $nextEpisode');
      }

      // Safely extract episode information
      final Map<String, dynamic> episodeMap = Map<String, dynamic>.from(
        episodeData,
      );

      final seasonNumber =
          episodeMap['season'] is num
              ? (episodeMap['season'] as num).toInt()
              : null;
      final episodeNumber =
          episodeMap['number'] is num
              ? (episodeMap['number'] as num).toInt()
              : null;

      if (seasonNumber == null || episodeNumber == null) {
        throw Exception(
          'Missing required episode data (season: $seasonNumber, episode: $episodeNumber)',
        );
      }

      try {
        // Prepare the show data with the correct ID format
        final Map<String, dynamic> showData = {
          'ids':
              isNumericId ? {'trakt': int.parse(traktId)} : {'slug': traktId},
        };

        final watchData = {
          'shows': [
            {
              ...showData,
              'seasons': [
                {
                  'number': seasonNumber,
                  'episodes': [
                    {'number': episodeNumber},
                  ],
                },
              ],
            },
          ],
        };

        // Mark the episode as watched using the service
        await _episodeService.markEpisodeAsWatched(
          trakt: trakt,
          traktId: showIdToUse,
          seasonNumber: seasonNumber,
          episodeNumber: episodeNumber,
        );

        // Add a small delay to ensure the server has processed the update
        await Future.delayed(const Duration(seconds: 1));

        // Update the progress
        final updatedProgress = await _episodeService.updateShowProgress(
          trakt,
          showIdToUse,
        );
        final isCompleted = isShowCompleted(updatedProgress);

        // Update the progress in the state
        await updateShowProgress(showIdToUse);

        // If show is now completed, remove it from the local watchlist state
        if (isCompleted) {
          try {
            // Update the local state to remove the show
            final updatedItems = List<Map<String, dynamic>>.from(state.items);
            updatedItems.removeWhere((item) {
              final showData = item['show'] ?? item;
              final ids = showData['ids'] as Map<String, dynamic>? ?? {};
              return (ids['trakt']?.toString() == traktId ||
                  ids['slug'] == traktId);
            });

            updateStateWithItems(updatedItems, isLoading: false);
            state = state.copyWith(hasData: updatedItems.isNotEmpty);

            // Update the cache
            final type = _ref.read(watchlistTypeProvider);
            _cacheHandler.updateCache(type, updatedItems);

            return; // Skip the refresh since we've already updated the state
          } catch (e) {
            debugPrint('Failed to update local watchlist state: $e');
            // Continue with refresh as fallback
          }
        }

        // If we get here, either the show isn't completed or we couldn't remove it
        // Force a full refresh to ensure UI is in sync
        await refresh();
      } catch (e) {
        rethrow;
      }
    } catch (e) {
      // Update state to reflect the error
      state = state.copyWith(
        error: 'Failed to mark episode as watched: ${e.toString()}',
        isLoading: false,
      );
      rethrow;
    }
  }

  /// Mark the last watched episode as unwatched
  Future<void> markEpisodeAsUnwatched(String traktId) async {
    if (traktId.isEmpty) {
      return;
    }

    try {
      final trakt = _ref.read(traktApiProvider);

      // Get current progress with error handling
      Map<String, dynamic> progress;
      try {
        progress = await trakt.getShowWatchedProgress(id: traktId);
      } catch (e) {
        rethrow;
      }

      // Find the last watched episode
      Map<String, dynamic>? lastWatchedEpisode;

      // Check if we have seasons data
      if (progress['seasons'] is List) {
        final seasons = List<Map<String, dynamic>>.from(progress['seasons']);

        // First, try to find the episode before the first unwatched one
        bool foundNext = false;
        outerLoop:
        for (var season in seasons) {
          if (season['episodes'] is List) {
            final episodes = List<Map<String, dynamic>>.from(
              season['episodes'],
            );

            for (int i = 0; i < episodes.length; i++) {
              final episode = episodes[i];
              if (episode['completed'] == false) {
                // If this is the first episode of the season and it's unwatched,
                // check if there's a previous season with a watched episode
                if (i == 0 && season['number'] > 1) {
                  // Look for the last episode of the previous season
                  final prevSeason = seasons.firstWhere(
                    (s) => s['number'] == (season['number'] as int) - 1,
                    orElse: () => <String, dynamic>{},
                  );

                  if (prevSeason.isNotEmpty && prevSeason['episodes'] is List) {
                    final prevEpisodes = List<Map<String, dynamic>>.from(
                      prevSeason['episodes'],
                    );
                    // Get the last episode of the previous season
                    if (prevEpisodes.isNotEmpty) {
                      final lastPrevEpisode = prevEpisodes.last;
                      if (lastPrevEpisode['completed'] == true) {
                        lastWatchedEpisode = {
                          'season': prevSeason['number'],
                          'number': lastPrevEpisode['number'],
                          'completed': true,
                          'last_watched_at': lastPrevEpisode['last_watched_at'],
                        };
                        foundNext = true;
                        break outerLoop;
                      }
                    }
                  }
                } else if (i > 0) {
                  // Original logic for non-first episodes
                  final lastWatched = episodes[i - 1];
                  if (lastWatched['completed'] == true) {
                    lastWatchedEpisode = {
                      'season': season['number'],
                      'number': lastWatched['number'],
                      'completed': true,
                      'last_watched_at': lastWatched['last_watched_at'],
                    };
                    foundNext = true;
                    break outerLoop;
                  }
                }
                break; // No need to check further in this season
              }
            }
          }
        }

        // If we didn't find a next unwatched episode, find the last watched one
        if (!foundNext) {
          debugPrint(
            'No unwatched episode found, looking for last watched episode',
          );
          for (var season in seasons.reversed) {
            if (season['episodes'] is List) {
              final episodes = List<Map<String, dynamic>>.from(
                season['episodes'],
              );

              for (var episode in episodes.reversed) {
                if (episode['completed'] == true) {
                  lastWatchedEpisode = {
                    'season': season['number'],
                    'number': episode['number'],
                    'completed': true,
                    'last_watched_at': episode['last_watched_at'],
                  };
                  foundNext = true;
                  break;
                }
              }

              if (foundNext) break;
            }
          }
        }
      }

      if (lastWatchedEpisode == null) {
        throw Exception(
          'No watched episodes found to unwatch for show: $traktId',
        );
      }

      final seasonNumber = lastWatchedEpisode['season'] as int;
      final episodeNumber = lastWatchedEpisode['number'] as int;

      // Prepare the show data with the correct ID format
      final Map<String, dynamic> showDataMap =
          int.tryParse(traktId) != null
              ? {
                'ids': {'trakt': int.parse(traktId)},
              }
              : {
                'ids': {'slug': traktId},
              };

      try {
        // Mark the episode as unwatched using the service
        await _episodeService.markEpisodeAsUnwatched(
          trakt: trakt,
          traktId: traktId,
          seasonNumber: seasonNumber,
          episodeNumber: episodeNumber,
        );

        // Add a small delay to ensure the server has processed the update
        await Future.delayed(const Duration(seconds: 1));

        // Refresh the progress
        await updateShowProgress(traktId);

        // Force a refresh of the watchlist
        await refresh();
      } catch (e) {
        rethrow;
      }
    } catch (e) {
      // Update state to reflect the error
      state = state.copyWith(
        error: 'Failed to mark episode as unwatched: ${e.toString()}',
        isLoading: false,
      );
      rethrow;
    }
  }

  /// Toggle watched status for a specific episode
  ///
  /// [showTraktId] - The Trakt ID of the show
  /// [seasonNumber] - The season number
  /// [episodeNumber] - The episode number
  /// [watched] - Whether to mark as watched or unwatched
  Future<void> toggleEpisodeWatchedStatus({
    required String showTraktId,
    required int seasonNumber,
    required int episodeNumber,
    required bool watched,
  }) async {
    try {
      state = state.copyWith(isLoading: true);

      final trakt = _ref.read(traktApiProvider);
      final showIdToUse = showTraktId;
      final isNumericId = int.tryParse(showIdToUse) != null;

      // Prepare the show data with the correct ID format
      final Map<String, dynamic> showData = {
        'ids':
            isNumericId
                ? {'trakt': int.parse(showIdToUse)}
                : {'slug': showIdToUse},
      };

      if (watched) {
        // Mark as watched
        await trakt.addToWatchHistory(
          shows: [
            {
              ...showData,
              'seasons': [
                {
                  'number': seasonNumber,
                  'episodes': [
                    {'number': episodeNumber},
                  ],
                },
              ],
            },
          ],
        );
      } else {
        // Mark as unwatched
        await trakt.removeFromHistory(
          shows: [
            {
              ...showData,
              'seasons': [
                {
                  'number': seasonNumber,
                  'episodes': [
                    {'number': episodeNumber},
                  ],
                },
              ],
            },
          ],
        );
      }

      // Update the local state
      state = state.copyWith(
        items:
            state.items.map((show) {
              if (getItemId(show) == getItemId(showData)) {
                // Find and update the specific episode in the show's seasons
                final updatedSeasons =
                    (show['seasons'] as List?)?.map((season) {
                      if (season['number'] == seasonNumber) {
                        final episodes =
                            (season['episodes'] as List?)?.map((episode) {
                              if (episode['number'] == episodeNumber) {
                                return {
                                  ...episode,
                                  'completed': watched,
                                  'watched': watched,
                                };
                              }
                              return episode;
                            }).toList();
                        return {...season, 'episodes': episodes};
                      }
                      return season;
                    }).toList();

                return {...show, 'seasons': updatedSeasons};
              }
              return show;
            }).toList(),
      );

      // Force a refresh of the progress
      await updateShowProgress(showIdToUse);
    } catch (e) {
      state = state.copyWith(
        error: 'Error al actualizar el estado del episodio: ${e.toString()}',
      );
      rethrow;
    } finally {
      state = state.copyWith(isLoading: false);
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
