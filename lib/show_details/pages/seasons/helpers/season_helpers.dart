/// Funciones helper para lógica de progreso y estado de episodios de temporada.

/// Calcula el progreso de la temporada.
double getSeasonProgress(Map<String, dynamic>? progress, int seasonNumber) {
  if (progress == null) return 0.0;
  final List<dynamic>? seasons = progress["seasons"] as List<dynamic>?;
  final Map<String, dynamic>? season = seasons
      ?.cast<Map<String, dynamic>>()
      .firstWhere((s) => s["number"] == seasonNumber, orElse: () => {});
  if (season == null || season.isEmpty) return 0.0;
  final int completed = season["completed"] ?? 0;
  final int aired = season["aired"] ?? 1;
  return (completed / aired).clamp(0.0, 1.0);
}

/// Devuelve true si todos los episodios están vistos.
bool allEpisodesWatched(
  List<Map<String, dynamic>> episodes,
  Map<String, dynamic>? progress,
  int seasonNumber,
) {
  if (progress == null || episodes.isEmpty) return false;
  final List<dynamic>? seasons = progress["seasons"] as List<dynamic>?;
  final Map<String, dynamic>? season = seasons
      ?.cast<Map<String, dynamic>>()
      .firstWhere((s) => s["number"] == seasonNumber, orElse: () => {});
  if (season == null || season.isEmpty || season["episodes"] is! List) {
    return false;
  }
  final Set<int> watchedNumbers =
      (season["episodes"] as List)
          .where((e) {
            final completed = e["completed"];
            if (completed is int) return completed > 0;
            if (completed is bool) return completed;
            return false;
          })
          .map((e) => e["number"] as int)
          .toSet();
  return watchedNumbers.length == episodes.length;
}
