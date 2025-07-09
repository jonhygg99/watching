import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:watching/providers/app_providers.dart';

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
                ...episode,  // Keep all original episode data
                'title': episodeInfo['title'] ?? episode['title'],  // Use translated title if available
                'overview': episodeInfo['overview'] ?? episode['overview'],  // Use translated overview if available
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
