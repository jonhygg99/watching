import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:watching/api/trakt/trakt_api.dart';
import 'package:watching/watchlist/progress_bar.dart';

/// Displays the current episode information including season, episode number,
/// translated name, and watch progress.
class CurrentEpisode extends HookWidget {
  final String traktId;
  final String? title;

  const CurrentEpisode({super.key, required this.traktId, this.title});

  /// Find the next episode to watch based on the show's progress
  /// Returns the next episode or null if all episodes are watched
  Map<String, dynamic>? _findNextEpisode(Map<String, dynamic>? progress) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final progress = useState<Map<String, dynamic>?>(null);
    final isLoading = useState(true);
    final error = useState<String?>(null);

    useEffect(() {
      bool isMounted = true;

      final trakt = TraktApi();
      trakt
          .getShowWatchedProgress(id: traktId)
          .then((value) {
            if (isMounted) {
              progress.value = value;
              isLoading.value = false;
            }
          })
          .catchError((e) {
            if (isMounted) {
              error.value = e.toString();
              isLoading.value = false;
            }
          });

      return () {
        isMounted = false;
      };
    }, [traktId]);

    if (isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error.value != null) {
      return const SizedBox.shrink(); // Hide on error
    }

    final nextEpisode = _findNextEpisode(progress.value);
    final watched = progress.value?['completed'] ?? 0;
    final total = progress.value?['aired'] ?? 0;

    if (nextEpisode != null) {
      return _buildEpisodeInfo(
        context: context,
        seasonNumber: nextEpisode['season'],
        episodeNumber: nextEpisode['number'],
        episodeName:
            nextEpisode['title'] ?? 'Episodio ${nextEpisode['number']}',
        watchedEpisodes: watched,
        totalEpisodes: total,
        progressPercent: total > 0 ? (watched / total).clamp(0.0, 1.0) : 0.0,
      );
    } else if (total > 0) {
      // Show progress for completed shows
      return _buildEpisodeInfo(
        context: context,
        seasonNumber: null,
        episodeNumber: null,
        episodeName: 'Serie completada',
        watchedEpisodes: watched,
        totalEpisodes: total,
        progressPercent: 1.0,
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildEpisodeInfo({
    required BuildContext context,
    required int? seasonNumber,
    required int? episodeNumber,
    required String? episodeName,
    required int watchedEpisodes,
    required int totalEpisodes,
    required double progressPercent,
  }) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Episode info row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Season and episode info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (seasonNumber != null && episodeNumber != null)
                    Text(
                      'Temporada $seasonNumber • Episodio $episodeNumber',
                      style: textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  if (episodeName != null && episodeName.isNotEmpty)
                    Text(
                      episodeName,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),

            // Watched/total episodes
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$watchedEpisodes/$totalEpisodes',
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Progress bar
        ProgressBar(
          percent: progressPercent,
          watched: watchedEpisodes,
          total: totalEpisodes,
        ),
      ],
    );
  }
}
