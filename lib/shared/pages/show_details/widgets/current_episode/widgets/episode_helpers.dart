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
