import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:watching/providers/app_providers.dart';

class WatchlistEpisodeService {
  final Ref _ref;

  WatchlistEpisodeService(this._ref);

  /// Update show progress and return the progress data
  Future<Map<String, dynamic>> updateShowProgress(
    dynamic trakt,
    String traktId, {
    bool forceRefresh = false,
  }) async {
    try {
      final progress = await trakt.getShowWatchedProgress(id: traktId);
      return progress;
    } catch (e) {
      debugPrint('Error updating show progress: $e');
      rethrow;
    }
  }

  /// Mark an episode as watched
  Future<void> markEpisodeAsWatched({
    required dynamic trakt,
    required String traktId,
    required int seasonNumber,
    required int episodeNumber,
  }) async {
    try {
      await trakt.addToWatchHistory(
        shows: [
          {
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
          },
        ],
      );
    } catch (e) {
      debugPrint('Error marking episode as watched: $e');
      rethrow;
    }
  }

  /// Mark an episode as unwatched
  Future<void> markEpisodeAsUnwatched({
    required dynamic trakt,
    required String traktId,
    required int seasonNumber,
    required int episodeNumber,
  }) async {
    try {
      await trakt.removeFromHistory(
        shows: [
          {
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
          },
        ],
      );
    } catch (e) {
      debugPrint('Error marking episode as unwatched: $e');
      rethrow;
    }
  }

  /// Find the next episode to watch based on progress data
  Map<String, dynamic>? findNextEpisode(Map<String, dynamic> progress) {
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
      debugPrint('Error in findNextEpisode: $e');
      return null;
    }
  }

  /// Get next episode to watch
  Future<Map<String, dynamic>?> getNextEpisode(
    dynamic trakt,
    String traktId,
    Map<String, dynamic> progress,
  ) async {
    final countryCode = _ref.read(countryCodeProvider);
    try {
      if (progress['seasons'] is! List) return null;

      final seasons =
          (progress['seasons'] as List).where((s) => s['number'] != 0).toList();

      for (var season in seasons) {
        if (season['episodes'] is! List) continue;

        for (var episode in season['episodes']) {
          if (episode['completed'] == false) {
            try {
              final episodeInfo = await trakt.getEpisodeInfo(
                id: traktId,
                season: season['number'],
                episode: episode['number'],
                language: countryCode.toLowerCase(),
              );

              // Create a new map with the episode data and merge the translated title
              return {
                ...episode, // Keep all original episode data
                'title':
                    episodeInfo['title'] ??
                    episode['title'], // Use translated title if available
                'overview':
                    episodeInfo['overview'] ??
                    episode['overview'], // Use translated overview if available
                'season': season['number'],
                'number': episode['number'],
                'ids': episode['ids'] ?? {},
              };
            } catch (e) {
              debugPrint('Error fetching episode info: $e');
              return null;
            }
          }
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error finding next episode: $e');
      return null;
    }
  }
}
