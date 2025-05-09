import 'package:flutter/material.dart';
import 'package:watching/watchlist/progress_bar.dart';
import 'package:watching/watchlist/episode_info_button.dart';
import 'package:watching/services/trakt/trakt_api.dart';

/// Displays the user's progress for a show, including next episode info and progress bar.
/// Accepts progress data directly or fetches it if not provided.
/// Follows Windsurf Development Guidelines for Riverpod/Flutter best practices.

/// Widget to display the user's progress for a show.
/// Assumes progress is always provided by the parent/provider (never fetched async).
/// Defensive UI: shows title if no traktId, and a fallback if progress is missing.
class WatchProgressInfo extends StatelessWidget {
  final String? traktId;
  final String title;
  final TraktApi apiService;
  final Map<String, dynamic>? progress;

  const WatchProgressInfo({
    super.key,
    required this.traktId,
    required this.title,
    required this.apiService,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold);
    final episodeStyle = Theme.of(context).textTheme.bodyMedium;

    // Defensive: If no traktId, show only the title.
    if (traktId == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text(title, style: titleStyle)],
      );
    }

    // If progress is missing, show fallback UI
    if (progress == null || progress!.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: titleStyle),
          const SizedBox(height: 8),
          Text('Sin progreso disponible', style: TextStyle(color: Colors.grey)),
        ],
      );
    }

    // If progress exists, show details
    return _ProgressDetails(
      title: title,
      progress: progress!,
      traktId: traktId!,
      apiService: apiService,
      titleStyle: titleStyle,
      episodeStyle: episodeStyle,
    );
  }
}


/// Internal widget to render progress details, next episode, and progress bar.
class _ProgressDetails extends StatelessWidget {
  final String title;
  final Map<String, dynamic> progress;
  final String traktId;
  final TraktApi apiService;
  final TextStyle? titleStyle;
  final TextStyle? episodeStyle;

  const _ProgressDetails({
    required this.title,
    required this.progress,
    required this.traktId,
    required this.apiService,
    required this.titleStyle,
    required this.episodeStyle,
  });

  @override
  Widget build(BuildContext context) {
    final episodesWatched = progress['completed'] ?? 0;
    final totalEpisodes = progress['aired'] ?? 1;
    final nextEpisode = progress['next_episode'];
    final percent =
        totalEpisodes > 0
            ? (episodesWatched / totalEpisodes).clamp(0.0, 1.0)
            : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: titleStyle),
        if (nextEpisode != null) ...[
          const SizedBox(height: 6),
          Text(
            'T${nextEpisode['season']}E${nextEpisode['number']} - ${nextEpisode['title']}',
            style: episodeStyle?.copyWith(color: Colors.grey[700]),
          ),
          const SizedBox(height: 6),
          ProgressBar(
            percent: percent,
            watched: episodesWatched,
            total: totalEpisodes,
          ),
          const SizedBox(height: 6),
          EpisodeInfoButton(
            traktId: traktId,
            season: nextEpisode['season'],
            episode: nextEpisode['number'],
            apiService: apiService,
          ),
        ],
      ],
    );
  }
}
