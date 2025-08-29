import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:watching/providers/app_providers.dart';
import 'package:watching/shared/utils/episode_utils.dart';

class WatchlistEpisodeService {
  final Ref _ref;

  WatchlistEpisodeService(this._ref);

  /// Get next episode to watch
  Future<Map<String, dynamic>?> getNextEpisode(
    dynamic trakt,
    String traktId,
    Map<String, dynamic> progress,
  ) async {
    final countryCode = _ref.read(countryCodeProvider);
    try {
      // Find the next episode using the shared utility
      final nextEpisode = EpisodeUtils.findNextEpisode(progress);
      if (nextEpisode == null) return null;

      // Fetch additional episode info for localization
      try {
        final episodeInfo = await trakt.getEpisodeInfo(
          id: traktId,
          season: nextEpisode['season'],
          episode: nextEpisode['number'],
          language: countryCode.toLowerCase(),
        );

        // Merge with localized data if available
        return {
          ...nextEpisode,
          'title': episodeInfo['title'] ?? nextEpisode['title'],
          'overview': episodeInfo['overview'] ?? nextEpisode['overview'],
          'ids': nextEpisode['ids'] ?? {},
        };
      } catch (e) {
        debugPrint('Error fetching episode info: $e');
        return nextEpisode; // Still return the episode even if info fetch fails
      }
    } catch (e) {
      debugPrint('Error finding next episode: $e');
      return null;
    }
  }
}
