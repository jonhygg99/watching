/// Helper function to check if all episodes in a season are watched
bool allEpisodesWatched(
  List<Map<String, dynamic>> episodes,
  Map<String, dynamic>? progress,
  int seasonNumber,
) {
  if (progress == null || !progress.containsKey('seasons')) return false;

  final season = (progress['seasons'] as List).firstWhere(
    (s) => s['number'] == seasonNumber,
    orElse: () => {'episodes': []},
  );

  final watchedEpisodes = (season['episodes'] as List)
      .where((ep) => ep['completed'] == true)
      .length;

  return watchedEpisodes == episodes.length;
}

/// Helper function to get the progress percentage of a season
double getSeasonProgress(Map<String, dynamic>? progress, int seasonNumber) {
  if (progress == null || !progress.containsKey('seasons')) return 0.0;

  final season = (progress['seasons'] as List).firstWhere(
    (s) => s['number'] == seasonNumber,
    orElse: () => {'completed': 0, 'aired': 1},
  );

  final completed = season['completed'] ?? 0;
  final total = season['aired'] ?? 1;

  return total > 0 ? completed / total : 0.0;
}
