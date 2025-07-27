import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:watching/features/watchlist/enums/watchlist_type.dart';
import 'package:watching/features/watchlist/models/watchlist_state.dart';
import 'package:watching/features/watchlist/state/watchlist_notifier/watchlist_cache_handler.dart';
import 'package:watching/features/watchlist/providers/watchlist_providers.dart';
import 'package:watching/providers/app_providers.dart';
import 'package:watching/features/watchlist/services/watchlist_episode_service.dart';

/// Handles all episode-related actions for the watchlist
class WatchlistEpisodeActions {
  final Ref ref;
  final WatchlistEpisodeService episodeService;
  final Function(WatchlistState) updateState;
  final Function(bool) updateLoadingState;
  final Function(List<Map<String, dynamic>>, {bool isLoading})
  updateStateWithItems;
  final Function(List<Map<String, dynamic>>, List<Map<String, dynamic>>)
  mergeItems;
  final Future<void> Function(String) updateShowProgress;
  final Future<void> Function() refresh;
  final bool Function(Map<String, dynamic> progress) isShowCompleted;
  final WatchlistCacheHandler cacheHandler;
  final String Function(WatchlistType) getTypeString;

  WatchlistEpisodeActions({
    required this.ref,
    required this.episodeService,
    required this.updateState,
    required this.updateLoadingState,
    required this.updateStateWithItems,
    required this.mergeItems,
    required this.updateShowProgress,
    required this.refresh,
    required this.isShowCompleted,
    required this.cacheHandler,
    required this.getTypeString,
  });

  /// Mark the next episode as watched
  Future<void> markEpisodeAsWatched(String traktId) async {
    try {
      updateLoadingState(true);
      final trakt = ref.read(traktApiProvider);

      // Get the current progress to find the next episode
      final progress = await trakt.getShowWatchedProgress(id: traktId);

      // Find the next episode to mark as watched
      final nextEpisode = await episodeService.findNextEpisode(progress);

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

      // Mark the episode as watched using the service
      await episodeService.markEpisodeAsWatched(
        trakt: trakt,
        traktId: traktId,
        seasonNumber: seasonNumber,
        episodeNumber: episodeNumber,
      );

      // Add a small delay to ensure the server has processed the update
      await Future.delayed(const Duration(seconds: 1));

      // Update the progress
      final updatedProgress = await episodeService.updateShowProgress(
        trakt,
        traktId,
      );
      final completed = isShowCompleted(updatedProgress);

      // If show is now completed, remove it from the local watchlist state
      if (completed) {
        try {
          // Get the current state
          final currentState = ref.read(watchlistProvider);
          final updatedItems = List<Map<String, dynamic>>.from(
            currentState.items,
          );

          // Remove the show from the local state
          updatedItems.removeWhere((item) {
            final showData = item['show'] ?? item;
            final ids = showData['ids'] as Map<String, dynamic>? ?? {};
            return (ids['trakt']?.toString() == traktId ||
                ids['slug'] == traktId);
          });

          updateStateWithItems(updatedItems, isLoading: false);
          updateState(
            WatchlistState(
              items: updatedItems,
              hasData: updatedItems.isNotEmpty,
              isLoading: false,
            ),
          );

          // Update the cache
          final type = ref.read(watchlistTypeProvider);
          cacheHandler.updateCache(type, updatedItems);
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
      // Update state to reflect the error
      updateState(
        WatchlistState(
          error: 'Failed to mark episode as watched: ${e.toString()}',
          isLoading: false,
        ),
      );
      rethrow;
    } finally {
      updateLoadingState(false);
    }
  }

  /// Mark the last watched episode as unwatched
  Future<void> markEpisodeAsUnwatched(String traktId) async {
    try {
      updateLoadingState(true);
      final trakt = ref.read(traktApiProvider);

      // Get the current progress
      final progress = await trakt.getShowWatchedProgress(id: traktId);

      // Find the last watched episode
      Map<String, dynamic>? lastWatchedEpisode;
      final seasons = progress['seasons'] as List<dynamic>? ?? [];

      for (var season in seasons) {
        final episodes = season['episodes'] as List<dynamic>? ?? [];
        for (var episode in episodes) {
          if (episode['completed'] == true || episode['watched'] == true) {
            lastWatchedEpisode = {
              'season': season['number'],
              'number': episode['number'],
            };
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

      // Mark the episode as unwatched using the service
      await episodeService.markEpisodeAsUnwatched(
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
      // Update state to reflect the error
      updateState(
        WatchlistState(
          error: 'Failed to mark episode as unwatched: ${e.toString()}',
          isLoading: false,
        ),
      );
      rethrow;
    } finally {
      updateLoadingState(false);
    }
  }

  /// Toggle watched status for a specific episode
  Future<void> toggleEpisodeWatchedStatus({
    required String showTraktId,
    required int seasonNumber,
    required int episodeNumber,
    required bool watched,
  }) async {
    try {
      updateLoadingState(true);
      final trakt = ref.read(traktApiProvider);
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
        // Mark as unwatched by removing from history
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

      // Add a small delay to ensure the server has processed the update
      await Future.delayed(const Duration(seconds: 1));

      // Update the show's progress
      await updateShowProgress(showTraktId);

      // Force a refresh of the watchlist
      await refresh();
    } catch (e) {
      // Update state to reflect the error
      updateState(
        WatchlistState(
          error: 'Failed to toggle episode watched status: ${e.toString()}',
          isLoading: false,
        ),
      );
      rethrow;
    } finally {
      updateLoadingState(false);
    }
  }
}

/// Extension to easily access WatchlistEpisodeActions from a Ref
extension WatchlistEpisodeActionsRef on Ref {
  /// Get the WatchlistEpisodeActions instance with all dependencies
  WatchlistEpisodeActions get watchlistEpisodeActions {
    final notifier = read(watchlistProvider.notifier) as dynamic; // Cast to access notifier methods
    final currentState = read(watchlistProvider);

    return WatchlistEpisodeActions(
      ref: this,
      episodeService: WatchlistEpisodeService(this),
      updateState: (newState) => notifier.state = newState,
      updateLoadingState: (isLoading) {
        notifier.state = currentState.copyWith(isLoading: isLoading);
      },
      updateStateWithItems: (items, {isLoading = false}) {
        notifier.updateStateWithItems(items, isLoading: isLoading);
      },
      mergeItems: (existingItems, newItems) {
        return notifier.mergeItems(existingItems, newItems);
      },
      updateShowProgress: (traktId) => notifier.updateShowProgress(traktId),
      refresh: () => notifier.refresh(),
      isShowCompleted: (progress) => notifier.isShowCompleted(progress),
      cacheHandler: WatchlistCacheHandler(this),
      getTypeString: (type) => type == WatchlistType.shows ? 'show' : 'movie',
    );
  }
}
