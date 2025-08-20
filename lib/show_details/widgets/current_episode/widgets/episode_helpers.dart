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

    // First check if we have a next_episode from the API
    final nextEpisode = progress['next_episode'];
    if (nextEpisode != null) return nextEpisode;

    // If no next_episode, try to find the first unwatched episode
    final seasons = progress['seasons'] as List<dynamic>?;
    if (seasons == null) return null;

    for (final season in seasons) {
      final episodes = season['episodes'] as List<dynamic>?;
      if (episodes == null) continue;

      for (final episode in episodes) {
        final completed = episode['completed'] as bool? ?? false;
        if (!completed) {
          return {
            'season': season['number'],
            'number': episode['number'],
            'title': episode['title'],
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
