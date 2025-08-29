import 'package:flutter/foundation.dart';

/// Find the last season number from progress data
int findLastSeason(Map<String, dynamic>? progress) {
  try {
    if (progress == null) return 1;

    final seasons = progress['seasons'] as List<dynamic>?;
    if (seasons == null || seasons.isEmpty) return 1;

    // Find the maximum season number
    int maxSeason = 1;
    for (final season in seasons) {
      final seasonNumber = (season['number'] as int?) ?? 0;
      if (seasonNumber > maxSeason) {
        maxSeason = seasonNumber;
      }
    }
    return maxSeason;
  } catch (e) {
    debugPrint('Error finding last season: $e');
    return 1;
  }
}

/// Find the next episode to watch based on the show's progress
/// Returns the next episode or null if all episodes are watched
Map<String, dynamic>? findNextEpisode(Map<String, dynamic>? progress) {
  try {
    if (progress == null) return null;

    // If no next_episode, try to find the first unwatched episode in the earliest possible season
    final seasons =
        (progress['seasons'] as List<dynamic>?)
            ?.where((s) => s['number'] != 0) // Skip specials (season 0)
            .toList()
          ?..sort((a, b) => (a['number'] as int).compareTo(b['number'] as int));

    if (seasons == null) {
      return null;
    }

    for (final season in seasons) {
      final seasonNumber = season['number'] as int;
      final episodes =
          (season['episodes'] as List<dynamic>?)
              ?.where((e) => e != null)
              .toList()
            ?..sort(
              (a, b) => (a['number'] as int).compareTo(b['number'] as int),
            );

      if (episodes == null || episodes.isEmpty) {
        continue;
      }

      // Find the first unwatched episode in this season
      for (final episode in episodes) {
        final episodeNumber = episode['number'] as int;
        final completed = episode['completed'] as bool? ?? false;

        if (!completed) {
          return {
            'season': seasonNumber,
            'number': episodeNumber,
            'title': episode['title'] ?? 'Episode $episodeNumber',
          };
        }
      }
    }

    return null; // All episodes watched
  } catch (e) {
    debugPrint('Error finding next episode: $e');
    return null;
  }
}
