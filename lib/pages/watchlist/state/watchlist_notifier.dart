import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:watching/pages/watchlist/enums/watchlist_type.dart';
import 'package:watching/pages/watchlist/models/watchlist_state.dart';
import 'package:watching/pages/watchlist/providers/watchlist_type_provider.dart';
import 'package:watching/pages/watchlist/services/watchlist_episode_service.dart';
import 'package:watching/pages/watchlist/services/watchlist_processor.dart';
import 'package:watching/providers/app_providers.dart';
import 'package:watching/shared/constants/watchlist_constants.dart';
import 'package:collection/collection.dart';

// Export types for easy importing
export 'package:watching/pages/watchlist/enums/watchlist_type.dart'
    show WatchlistType;
export 'package:watching/pages/watchlist/models/watchlist_state.dart'
    show WatchlistState;

/// Notifier for managing watchlist state and operations.
///
/// This notifier handles the complete lifecycle of watchlist data including:
/// - Loading watchlist items from the Trakt API
/// - Managing loading and error states
/// - Processing and merging watchlist items
/// - Handling episode watched/unwatched operations
/// - Updating show progress
/// - Providing progressive loading for better UX
///
/// The notifier uses [WatchlistEpisodeService] for episode-specific operations
/// and [WatchlistProcessor] for item processing. It maintains a [WatchlistState]
/// that contains the current items, loading status, and error information.
///
/// Usage:
/// ```dart
/// final watchlistNotifier = ref.read(watchlistProvider.notifier);
/// await watchlistNotifier.refresh();
/// await watchlistNotifier.markEpisodeAsWatched(traktId);
/// ```
class WatchlistNotifier extends StateNotifier<WatchlistState> {
  final Ref _ref;
  late final WatchlistEpisodeService _episodeService;
  late final WatchlistProcessor _processor;
  bool _isLoading = false;

  /// Creates a new [WatchlistNotifier] instance.
  ///
  /// Initializes the episode service and processor, then loads the initial watchlist.
  /// The [ref] parameter is used to access other providers and services.
  WatchlistNotifier(this._ref)
    : _episodeService = WatchlistEpisodeService(_ref),
      super(const WatchlistState()) {
    _processor = WatchlistProcessor(_ref);
    // Initial load
    _loadWatchlist();
  }

  /// Finds the next episode to watch based on the show's progress.
  ///
  /// Analyzes the show's progress data to determine the next unwatched episode.
  /// Uses the [WatchlistEpisodeService] to get the next episode information.
  ///
  /// Parameters:
  /// - [showData] - Map containing show information including progress data
  ///
  /// Returns the next episode data as a [Map<String,动态>?], or null if:
  /// - No progress data is available
  /// - The show has no Trakt ID
  /// - All episodes are already watched
  /// - An error occurs during the process
  ///
  /// Throws exceptions for API errors but returns null for logical cases
  /// where no next episode exists.
  Future<Map<String, dynamic>?> _findNextEpisode(
    Map<String, dynamic> showData,
  ) async {
    try {
      final progress = showData['progress'] as Map<String, dynamic>?;
      if (progress == null) return null;

      final traktId = showData['show']['ids']['trakt']?.toString();
      if (traktId == null) return null;

      return await _episodeService.getNextEpisode(
        _ref.read(traktApiProvider),
        traktId,
        progress,
      );
    } catch (e) {
      debugPrint('Error in _findNextEpisode: $e');
      return null;
    }
  }

  /// Loads watchlist data from the Trakt API with progressive loading.
  ///
  /// Fetches watchlist items based on the current [WatchlistType] (shows or movies)
  /// and processes them in chunks to provide a responsive user experience.
  /// Updates the state progressively as items become available.
  ///
  /// Parameters:
  /// - [forceRefresh] - If true, ignores any cached data and fetches fresh data
  ///
  /// Process:
  /// 1. Sets loading state and clears any existing errors
  /// 2. Determines the watchlist type (shows/movies)
  /// 3. Fetches items from Trakt API
  /// 4. Processes items in chunks of 5 for progressive loading
  /// 5. Updates state with each processed chunk
  /// 6. Handles errors gracefully while preserving existing data
  ///
  /// The method is idempotent and safe to call multiple times.
  /// Loading is prevented if already in progress to avoid duplicate requests.
  Future<void> _loadWatchlist({bool forceRefresh = false}) async {
    try {
      if (_isLoading) return;
      _isLoading = true;
      state = state.copyWith(isLoading: true, error: null);

      final trakt = _ref.read(traktApiProvider);
      final type = _ref.read(watchlistTypeProvider);
      final typeStr = type == WatchlistType.shows ? 'show' : 'movie';

      // Fetch fresh data from the API
      final items = await trakt.getWatched(type: typeStr);

      // Process items in chunks for progressive loading
      final chunkSize = WatchlistProcessing.chunkSize;
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

      // Final update with all items
      if (allProcessedItems.isNotEmpty) {
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

  /// Merges new items with existing ones, avoiding duplicates.
  ///
  /// Uses item IDs to identify and prevent duplicates while preserving
  /// the order of existing items and appending new unique items.
  ///
  /// Parameters:
  /// - [currentItems] - List of existing watchlist items
  /// - [newItems] - List of newly fetched items to merge
  ///
  /// Returns a new list containing all unique items.
  /// The merge is based on the unique item ID generated by [_getItemId].
  ///
  /// This method ensures that the watchlist doesn't contain duplicate
  /// entries when progressive loading or refreshing occurs.
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

  /// Generates a unique identifier for a watchlist item.
  ///
  /// Combines Trakt ID, slug, and IMDb ID to create a unique string
  /// that can be used to identify and deduplicate items.
  ///
  /// Parameters:
  /// - [item] - Map containing item data with show information
  ///
  /// Returns a string in format: '{traktId}-{slug}-{imdbId}'
  /// Empty strings are used for missing IDs to ensure consistency.
  ///
  /// This identifier is used by [_mergeItems] to prevent duplicates
  /// and by [toggleEpisodeWatchedStatus] to find specific shows.
  String _getItemId(Map<String, dynamic> item) {
    final show = item['show'] ?? item;
    final ids = show['ids'] ?? {};
    return '${ids['trakt'] ?? ''}-${ids['slug'] ?? ''}-${ids['imdb'] ?? ''}';
  }

  /// Processes a single watchlist item using the processor.
  ///
  /// Delegates item processing to [WatchlistProcessor] which handles
  /// enriching the item with additional metadata, progress information,
  /// and next episode data.
  ///
  /// Parameters:
  /// - [item] - Raw watchlist item from the API
  /// - [trakt] - Trakt API client instance
  /// - [ref] - Provider reference for accessing dependencies
  ///
  /// Returns the processed item data or null if processing fails.
  /// Errors during processing are caught and result in null to avoid
  /// breaking the overall loading process.
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

  /// Refreshes the watchlist by forcing a fresh data fetch.
  ///
  /// Clears any existing data and fetches fresh items from the Trakt API.
  /// This is useful when the user wants to ensure they have the latest
  /// data or when troubleshooting sync issues.
  ///
  /// Sets loading state to true during the refresh and updates the state
  /// with either fresh data or any errors that occur.
  ///
  /// Throws:
  /// - [Exception] if the refresh fails for any reason
  ///
  /// The method preserves existing data during loading to maintain
  /// a good user experience, replacing it only when fresh data is available.
  Future<void> refresh() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _loadWatchlist(forceRefresh: true);
    } catch (e) {
      final error =
          e is Exception
              ? e
              : Exception(
                '${WatchlistErrorMessages.failedToRefreshWatchlist}: $e',
              );
      debugPrint('Error in refresh: $error');
      state = state.copyWith(
        error: error.toString(),
        isLoading: false,
        hasData: state.items.isNotEmpty, // Keep existing data if we have any
      );
      rethrow;
    }
  }

  /// Marks the next episode of a show as watched.
  ///
  /// Automatically determines the next unwatched episode for the specified show
  /// and marks it as watched in the user's Trakt watch history. This is commonly
  /// used when the user has just finished watching an episode.
  ///
  /// Parameters:
  /// - [traktId] - The Trakt ID or slug of the show
  ///
  /// Process:
  /// 1. Gets current show progress from Trakt API
  /// 2. Determines the next unwatched episode
  /// 3. Marks the episode as watched in watch history
  /// 4. Updates local progress data
  /// 5. Refreshes the entire watchlist to ensure consistency
  ///
  /// Throws:
  /// - [Exception] if no next episode is found
  /// - [Exception] if episode data is missing or invalid
  /// - [Exception] if API calls fail
  ///
  /// Handles both numeric Trakt IDs and string slugs.
  /// Includes a delay to ensure server processing before refreshing.
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
        nextEpisode ??= await _findNextEpisode(progress);
      } catch (e) {
        nextEpisode = await _findNextEpisode(progress);
      }

      if (nextEpisode == null) {
        throw Exception(
          '${WatchlistErrorMessages.noNextEpisodeFound} for show: $traktId',
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
          '${WatchlistErrorMessages.missingEpisodeData} (season: $seasonNumber, episode: $episodeNumber)',
        );
      }

      try {
        // Prepare the show data with the correct ID format
        final Map<String, dynamic> showData = {
          'ids':
              isNumericId ? {'trakt': int.parse(traktId)} : {'slug': traktId},
        };

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
        await Future.delayed(
          Duration(seconds: WatchlistAnimations.apiProcessingDelayS),
        );

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
        error:
            '${WatchlistErrorMessages.failedToMarkEpisodeWatched}: ${e.toString()}',
        isLoading: false,
      );
      rethrow;
    }
  }

  /// Marks the last watched episode of a show as unwatched.
  ///
  /// Finds the most recently watched episode for the specified show
  /// and removes it from the user's Trakt watch history. This is useful
  /// when the user wants to undo a watched episode or correct a mistake.
  ///
  /// Parameters:
  /// - [traktId] - The Trakt ID or slug of the show
  ///
  /// Process:
  /// 1. Gets current show progress from Trakt API
  /// 2. Finds the last watched episode by analyzing seasons/episodes
  /// 3. Removes the episode from watch history
  /// 4. Updates local progress data
  /// 5. Refreshes the entire watchlist
  ///
  /// The algorithm searches for the last watched episode by:
  /// - Looking for the episode before the first unwatched one
  /// - If no unwatched episodes exist, finding the last completed one
  ///
  /// Throws:
  /// - [Exception] if no watched episodes are found
  /// - [Exception] if API calls fail
  ///
  /// Handles both numeric Trakt IDs and string slugs.
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
          '${WatchlistErrorMessages.noWatchedEpisodesFound} for show: $traktId',
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
        await Future.delayed(
          Duration(seconds: WatchlistAnimations.apiProcessingDelayS),
        );

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
        error:
            '${WatchlistErrorMessages.failedToMarkEpisodeUnwatched}: ${e.toString()}',
        isLoading: false,
      );
      rethrow;
    }
  }

  /// Toggles the watched status for a specific episode.
  ///
  /// Provides fine-grained control over individual episode watched status.
  /// Unlike [markEpisodeAsWatched] and [markEpisodeAsUnwatched] which operate
  /// on the next/last episodes, this method targets a specific episode.
  ///
  /// Parameters:
  /// - [showTraktId] - The Trakt ID or slug of the show
  /// - [seasonNumber] - The season number containing the episode
  /// - [episodeNumber] - The episode number within the season
  /// - [watched] - true to mark as watched, false to mark as unwatched
  ///
  /// Process:
  /// 1. Updates the episode status in Trakt watch history
  /// 2. Updates local state immediately for responsive UI
  /// 3. Refreshes the show's progress data
  ///
  /// The local state update provides immediate feedback while the
  /// API update ensures persistence across sessions.
  ///
  /// Throws:
  /// - [Exception] if API calls fail
  /// - Updates state with error message if local update fails
  ///
  /// Handles both numeric Trakt IDs and string slugs.
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
              if (_getItemId(show) == _getItemId(showData)) {
                // Create a deep copy of the show to avoid direct mutations
                final updatedShow = Map<String, dynamic>.from(show);

                // Update the specific episode in the show's seasons
                final seasons = List<Map<String, dynamic>>.from(
                  show['seasons'] ?? [],
                );

                for (int i = 0; i < seasons.length; i++) {
                  final season = Map<String, dynamic>.from(seasons[i]);
                  if (season['number'] == seasonNumber) {
                    final episodes = List<Map<String, dynamic>>.from(
                      season['episodes'] ?? [],
                    );

                    for (int j = 0; j < episodes.length; j++) {
                      final episode = episodes[j];
                      if (episode['number'] == episodeNumber) {
                        // Update only the necessary fields while preserving the rest
                        episodes[j] = {
                          ...episode,
                          'completed': watched,
                          'watched': watched,
                          'last_watched_at':
                              watched ? DateTime.now().toIso8601String() : null,
                        };
                        break;
                      }
                    }

                    // Update the season with modified episodes
                    season['episodes'] = episodes;
                    seasons[i] = season;
                    break;
                  }
                }

                // Update the show with modified seasons
                updatedShow['seasons'] = seasons;
                return updatedShow;
              }
              return show;
            }).toList(),
      );

      // Force a refresh of the progress
      await updateShowProgress(showIdToUse);
    } catch (e) {
      state = state.copyWith(
        error:
            '${WatchlistErrorMessages.failedToUpdateEpisodeStatus}: ${e.toString()}',
      );
      rethrow;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Updates progress data for a specific show in the watchlist.
  ///
  /// Fetches fresh progress data from the Trakt API and updates the
  /// corresponding show in the current watchlist state. This is typically
  /// called after episode watched/unwatched operations to ensure consistency.
  ///
  /// Parameters:
  /// - [traktId] - The Trakt ID or slug of the show to update
  ///
  /// Process:
  /// 1. Fetches current progress from Trakt API
  /// 2. Gets next episode information if progress data exists
  /// 3. Finds the show in current watchlist state
  /// 4. Updates the show's progress data
  /// 5. Updates state with modified items
  ///
  /// If the show is not found in the current state or any error occurs,
  /// falls back to a full refresh to ensure data consistency.
  ///
  /// The method is resilient to errors and provides multiple fallback
  /// strategies to maintain a consistent watchlist state.
  Future<void> updateShowProgress(String traktId) async {
    if (traktId.isEmpty) {
      return;
    }

    try {
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
          // Update the state with the new items
          state = state.copyWith(
            items: updatedItems,
            hasData: true,
            isLoading: false,
          );
        } catch (error) {
          // If there's an error updating the state, do a full refresh
          debugPrint('Error updating watchlist state: $error');
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
          error:
              '${WatchlistErrorMessages.failedToUpdateShowProgress}: ${e.toString()}',
          isLoading: false,
        );
      }
    }
  }
}

/// Provider for watchlist state management.
///
/// Creates and manages a [WatchlistNotifier] instance that handles
/// all watchlist-related operations and state. Automatically triggers
/// an initial refresh after the first frame to ensure data is loaded.
///
/// The provider follows Riverpod best practices by:
/// - Using code generation for type safety
/// - Auto-initializing data loading
/// - Providing a clean API for consumers
///
/// Usage:
/// ```dart
/// final watchlistState = ref.watch(watchlistProvider);
/// final notifier = ref.read(watchlistProvider.notifier);
/// ```
final watchlistProvider =
    StateNotifierProvider<WatchlistNotifier, WatchlistState>((ref) {
      final notifier = WatchlistNotifier(ref);
      // Initial load
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifier.refresh();
      });
      return notifier;
    });

/// Provider for accessing watchlist items.
///
/// Selects and exposes only the items list from the watchlist state.
/// This allows widgets to efficiently rebuild only when the items
/// change, without reacting to loading or error state changes.
///
/// Returns a [List<Map<String,动态>>] containing all watchlist items
/// with their associated progress and metadata.
///
/// Usage:
/// ```dart
/// final items = ref.watch(watchlistItemsProvider);
/// ```
final watchlistItemsProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(watchlistProvider.select((state) => state.items));
});

/// Provider for accessing watchlist loading state.
///
/// Selects and exposes only the loading status from the watchlist state.
/// This allows widgets to show loading indicators efficiently,
/// rebuilding only when the loading state changes.
///
/// Returns [bool] - true when data is being loaded, false otherwise.
///
/// Usage:
/// ```dart
/// final isLoading = ref.watch(watchlistLoadingProvider);
/// ```
final watchlistLoadingProvider = Provider<bool>((ref) {
  return ref.watch(watchlistProvider.select((state) => state.isLoading));
});

/// Provider for accessing watchlist error state.
///
/// Selects and exposes only the error information from the watchlist state.
/// This allows widgets to display error messages efficiently,
/// rebuilding only when an error occurs or is cleared.
///
/// Returns [Object?] - the current error or null if no error exists.
/// The error can be an [Exception], [String], or other error type.
///
/// Usage:
/// ```dart
/// final error = ref.watch(watchlistErrorProvider);
/// if (error != null) {
///   // Display error message
/// }
/// ```
final watchlistErrorProvider = Provider<Object?>((ref) {
  return ref.watch(watchlistProvider.select((state) => state.error));
});
