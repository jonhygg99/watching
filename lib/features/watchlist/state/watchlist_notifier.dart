import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:watching/features/watchlist/enums/watchlist_type.dart';
import 'package:watching/features/watchlist/models/watchlist_state.dart';
import 'package:watching/features/watchlist/providers/watchlist_type_provider.dart';
import 'package:watching/features/watchlist/providers/watchlist_cache_provider.dart';
import 'package:watching/features/watchlist/services/watchlist_episode_service.dart';
import 'package:watching/features/watchlist/services/watchlist_processor.dart';
import 'package:watching/providers/app_providers.dart';
import 'package:collection/collection.dart';

// Export types for easy importing
export 'package:watching/features/watchlist/enums/watchlist_type.dart'
    show WatchlistType;
export 'package:watching/features/watchlist/models/watchlist_state.dart'
    show WatchlistState;

/// Notifier for watchlist state management
class WatchlistNotifier extends StateNotifier<WatchlistState> {
  final Ref _ref;
  late final WatchlistEpisodeService _episodeService;
  late final WatchlistProcessor _processor;
  StreamSubscription? _subscription;
  bool _isLoading = false;

  WatchlistNotifier(this._ref)
    : _episodeService = WatchlistEpisodeService(_ref),
      super(const WatchlistState()) {
    _processor = WatchlistProcessor(_ref);
    // Initial load with cached data first
    _loadCachedData().then((_) {
      // Then load fresh data in background
      _loadWatchlist();
    });
  }

  /// Find the next episode to watch based on progress data
  Map<String, dynamic>? _findNextEpisode(Map<String, dynamic> progress) {
    try {
      final seasons = (progress['seasons'] as List?) ?? [];

      // Find the first unwatched episode
      for (final season in seasons.cast<Map<String, dynamic>>()) {
        final episodes = (season['episodes'] as List?) ?? [];
        for (final ep in episodes.cast<Map<String, dynamic>>()) {
          if (ep['completed'] != true) {
            return {
              'show': {
                'ids': {'trakt': progress['ids']?['trakt']},
              },
              'episode': {
                'season': season['number'],
                'number': ep['number'],
                'title': ep['title'],
              },
            };
          }
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Load cached data immediately
  Future<void> _loadCachedData() async {
    try {
      final type = _ref.read(watchlistTypeProvider);
      final cache = _ref.read(watchlistCacheProvider);
      final cachedData = cache.getCached(type);

      if (cachedData != null) {
        state = state.copyWith(
          items: cachedData,
          hasData: true,
          isLoading: true, // Still loading fresh data in background
        );
      }
    } catch (e) {
      // Error loading cached data
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
      state = state.copyWith(isLoading: true, error: null);

      final trakt = _ref.read(traktApiProvider);
      final type = _ref.read(watchlistTypeProvider);
      final cache = _ref.read(watchlistCacheProvider);

      if (forceRefresh) {
        cache.invalidateCache(type);
      }

      final typeStr = type == WatchlistType.shows ? 'show' : 'movie';

      // Start with loading state if we don't have cached data or forcing refresh
      if (state.items.isEmpty || forceRefresh) {
        state = state.copyWith(isLoading: true, error: null);
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
          final newItems = _mergeItems(currentItems, validItems);

          state = state.copyWith(
            items: newItems,
            isLoading: false,
            hasData: true,
            error: null,
          );
        }
      }

      // Final update with all items and update cache
      if (allProcessedItems.isNotEmpty) {
        cache.updateCache(type, allProcessedItems);
        state = state.copyWith(
          items: allProcessedItems,
          isLoading: false,
          hasData: true,
        );
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error,
        hasData: state.items.isNotEmpty, // Keep existing data if available
      );
    }
  }

  /// Merge new items with existing ones, avoiding duplicates
  List<Map<String, dynamic>> _mergeItems(
    List<Map<String, dynamic>> currentItems,
    List<Map<String, dynamic>> newItems,
  ) {
    final merged = List<Map<String, dynamic>>.from(currentItems);
    final existingIds = currentItems.map((item) => _getItemId(item)).toSet();

    for (final item in newItems) {
      final itemId = _getItemId(item);
      if (!existingIds.contains(itemId)) {
        merged.add(item);
        existingIds.add(itemId);
      }
    }

    return merged;
  }

  /// Get unique ID for an item
  String _getItemId(Map<String, dynamic> item) {
    final show = item['show'] ?? item;
    final ids = show['ids'] ?? {};
    return '${ids['trakt'] ?? ''}-${ids['slug'] ?? ''}-${ids['imdb'] ?? ''}';
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

  /// Refresh the watchlist data
  ///
  /// This will first check if we have fresh cached data (less than 30 seconds old).
  /// If not, it will perform a full refresh from the API.
  Future<void> refresh() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

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
      await _loadWatchlist(forceRefresh: true);
    } catch (e) {
      final error =
          e is Exception ? e : Exception('Failed to refresh watchlist: $e');
      debugPrint('Error in refresh: $error');
      state = state.copyWith(
        error: error.toString(),
        isLoading: false,
        hasData: state.items.isNotEmpty, // Keep existing data if we have any
      );
      rethrow;
    }
  }

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
        progress = await trakt.getShowWatchedProgress(id: showIdToUse);
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
        nextEpisode ??= _findNextEpisode(progress);
      } catch (e) {
        nextEpisode = _findNextEpisode(progress);
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

        debugPrint('Sending watch history update: $watchData');

        // Add to watch history
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

        // Add a small delay to ensure the server has processed the update
        await Future.delayed(const Duration(seconds: 1));

        // Update the progress
        await updateShowProgress(showIdToUse);

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
                // Found first unwatched episode, previous one is last watched
                if (i > 0) {
                  final lastWatched = episodes[i - 1];
                  if (lastWatched['completed'] == true) {
                    lastWatchedEpisode = {
                      'season': season['number'],
                      'number': lastWatched['number'],
                      'completed': true,
                      'last_watched_at': lastWatched['last_watched_at'],
                    };
                    foundNext = true;
                    debugPrint(
                      'Found last watched episode before unwatched: $lastWatchedEpisode',
                    );
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
        // Remove the episode from watched history
        await trakt.removeFromHistory(
          shows: [
            {
              ...showDataMap,
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
        'ids': isNumericId 
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
        items: state.items.map((show) {
          if (_getItemId(show) == _getItemId(showData)) {
            // Find and update the specific episode in the show's seasons
            final updatedSeasons = (show['seasons'] as List?)?.map((season) {
              if (season['number'] == seasonNumber) {
                final episodes = (season['episodes'] as List?)?.map((episode) {
                  if (episode['number'] == episodeNumber) {
                    return {
                      ...episode,
                      'completed': watched,
                      'watched': watched,
                    };
                  }
                  return episode;
                }).toList();
                return {
                  ...season,
                  'episodes': episodes,
                };
              }
              return season;
            }).toList();

            return {
              ...show,
              'seasons': updatedSeasons,
            };
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
      // First, invalidate the cache to force a fresh fetch
      final type = _ref.read(watchlistTypeProvider);
      final cache = _ref.read(watchlistCacheProvider);
      cache.invalidateCache(type);

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
          cache.updateCache(type, updatedItems);

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
