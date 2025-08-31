import 'package:flutter/foundation.dart';

class EpisodeUtils {
  /// Finds the next episode to watch based on the show's progress
  /// 
  /// Returns a map with the episode details or null if all episodes are watched
  static Map<String, dynamic>? findNextEpisode(Map<String, dynamic>? progress) {
    try {
      if (progress == null) return null;

      // Get and sort seasons (excluding specials)
      final seasons = _getSortedSeasons(progress);
      if (seasons == null) return null;

      // Find the first unwatched episode
      for (final season in seasons) {
        final episode = _findFirstUnwatchedInSeason(season);
        if (episode != null) {
          return {
            'season': season['number'],
            'number': episode['number'],
            'title': episode['title'] ?? 'Episode ${episode['number']}',
            ...episode, // Include all original episode data
          };
        }
      }

      return null; // All episodes watched
    } catch (e) {
      debugPrint('Error in findNextEpisode: $e');
      return null;
    }
  }

  /// Finds the first unwatched episode in a season
  static Map<String, dynamic>? _findFirstUnwatchedInSeason(
    Map<String, dynamic> season,
  ) {
    final episodes = _getSortedEpisodes(season);
    if (episodes == null) return null;

    for (final episode in episodes) {
      final completed = episode['completed'] as bool? ?? false;
      if (!completed) return episode;
    }
    return null;
  }

  /// Gets and sorts seasons, excluding specials (season 0)
  static List<Map<String, dynamic>>? _getSortedSeasons(
    Map<String, dynamic> progress,
  ) {
    final seasons = (progress['seasons'] as List<dynamic>?)
        ?.where((s) => s != null && s['number'] != 0)
        .map((s) => s as Map<String, dynamic>)
        .toList()
      ?..sort((a, b) => (a['number'] as int).compareTo(b['number'] as int));
    return seasons;
  }

  /// Gets and sorts episodes for a season
  static List<Map<String, dynamic>>? _getSortedEpisodes(
    Map<String, dynamic> season,
  ) {
    final episodes = (season['episodes'] as List<dynamic>?)
        ?.where((e) => e != null)
        .map((e) => e as Map<String, dynamic>)
        .toList()
      ?..sort((a, b) => (a['number'] as int).compareTo(b['number'] as int));
    return episodes;
  }
}
