import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:watching/features/watchlist/enums/watchlist_type.dart';
import 'package:watching/features/watchlist/models/watchlist_state.dart';
import 'package:watching/features/watchlist/state/watchlist_notifier/watchlist_cache_handler.dart';
import 'package:watching/features/watchlist/services/watchlist_episode_service.dart';
import 'package:watching/providers/app_providers.dart';

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
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      updateLoadingState(true);
      final trakt = ref.read(traktApiProvider);

      // Get the current progress to find the next episode
      final progress = await trakt.getShowWatchedProgress(id: traktId);

      if (progress.isEmpty) {
        return;
      }

      final nextEpisode = await episodeService.findNextEpisode(progress);

      if (nextEpisode != null) {
        final episodeData =
            nextEpisode['episode'] ?? nextEpisode['Episode'] ?? nextEpisode;
        final seasonNumber = (episodeData['season'] as num?)?.toInt();
        final episodeNumber = (episodeData['number'] as num?)?.toInt();

        if (seasonNumber != null && episodeNumber != null) {
          // Handle both numeric IDs and slugs
          final payload = {
            'ids':
                int.tryParse(traktId) != null
                    ? {'trakt': int.parse(traktId)}
                    : {'slug': traktId},
            'seasons': [
              {
                'number': seasonNumber,
                'episodes': [
                  {'number': episodeNumber},
                ],
              },
            ],
          };

          try {
            // Mark the episode as watched
            await trakt.addToWatchHistory(shows: [payload]);

            // Add a small delay to ensure the server has processed the update
            await Future.delayed(const Duration(seconds: 1));

            // Update the show's progress
            await updateShowProgress(traktId);

            // Refresh the watchlist to ensure consistency
            await refresh();
          } catch (e) {
            debugPrint('markEpisodeAsWatched: Error marking as watched: $e');
            rethrow;
          }
        } else {
          debugPrint('markEpisodeAsWatched: Invalid season or episode number');
        }
      }
    } catch (e) {
      debugPrint('Error marking episode as watched: $e');
      rethrow;
    } finally {
      _isProcessing = false;
      updateLoadingState(false);
    }
  }

  /// Mark the last watched episode as unwatched
  Future<void> markEpisodeAsUnwatched(String traktId) async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      updateLoadingState(true);
      final trakt = ref.read(traktApiProvider);

      // Get the current progress to find the last watched episode
      final progress = await trakt.getShowWatchedProgress(id: traktId);

      if (progress.isEmpty) {
        return;
      }

      final seasons = (progress['seasons'] as List<dynamic>?) ?? [];

      // Find the last watched episode
      Map<String, dynamic>? lastWatchedEpisode;
      for (var season in seasons) {
        final episodes = (season['episodes'] as List<dynamic>?) ?? [];
        for (var episode in episodes) {
          if (episode['completed'] == true || episode['watched'] == true) {
            lastWatchedEpisode = {
              'season': season['number'],
              'number': episode['number'],
            };
          }
        }
      }

      if (lastWatchedEpisode != null) {
        final seasonNumber = lastWatchedEpisode['season'] as int;
        final episodeNumber = lastWatchedEpisode['number'] as int;
        // Handle both numeric IDs and slugs
        final payload = {
          'ids':
              int.tryParse(traktId) != null
                  ? {'trakt': int.parse(traktId)}
                  : {'slug': traktId},
          'seasons': [
            {
              'number': seasonNumber,
              'episodes': [
                {'number': episodeNumber},
              ],
            },
          ],
        };

        try {
          // Remove the episode from watch history
          await trakt.removeFromHistory(shows: [payload]);

          // Add a small delay to ensure the server has processed the update
          await Future.delayed(const Duration(seconds: 1));

          // Update the show's progress
          await updateShowProgress(traktId);

          // Refresh the watchlist to ensure consistency
          await refresh();
        } catch (e) {
          debugPrint('markEpisodeAsUnwatched: Error marking as unwatched: $e');
          rethrow;
        }
      } else {
        debugPrint('markEpisodeAsUnwatched: No watched episodes found');
      }
    } catch (e) {
      debugPrint('Error marking episode as unwatched: $e');
      rethrow;
    } finally {
      _isProcessing = false;
      updateLoadingState(false);
    }
  }

  /// Toggle watched status for an episode
  Future<void> toggleEpisodeWatchedStatus({
    required String showTraktId,
    required int seasonNumber,
    required int episodeNumber,
    required bool watched,
  }) async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      updateLoadingState(true);
      final trakt = ref.read(traktApiProvider);

      if (watched) {
        // Mark episode as watched
        await trakt.addToWatchHistory(
          shows: [
            {
              'ids':
                  int.tryParse(showTraktId) != null
                      ? {'trakt': int.parse(showTraktId)}
                      : {'slug': showTraktId},
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
        // Mark episode as unwatched by removing from history
        await trakt.removeFromHistory(
          shows: [
            {
              'ids': {'trakt': int.tryParse(showTraktId) ?? 0},
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

      // Update the show's progress
      await updateShowProgress(showTraktId);

      // Refresh the watchlist to ensure consistency
      await refresh();
    } catch (e) {
      debugPrint('Error toggling episode watched status: $e');
      rethrow;
    } finally {
      _isProcessing = false;
      updateLoadingState(false);
    }
  }
}

// Flag to prevent multiple simultaneous operations
bool _isProcessing = false;
