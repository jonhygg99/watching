import 'package:flutter/material.dart';
import 'package:watching/l10n/app_localizations.dart';
import 'package:watching/shared/constants/measures.dart';
import 'package:watching/shared/widgets/tiny_progress_bar.dart';
import 'package:watching/pages/watchlist/widgets/episode_info_button.dart';
import 'package:watching/api/trakt/trakt_api.dart';

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
  final Map<String, dynamic> showData;

  const WatchProgressInfo({
    super.key,
    required this.traktId,
    required this.title,
    required this.apiService,
    required this.showData,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold);
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
          if (titleStyle != null) Text(title, style: titleStyle),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.noProgressAvailable,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      );
    }

    // If progress exists, show details
    return _ProgressDetails(
      title: title,
      traktId: traktId!,
      progress: progress!,
      apiService: apiService,
      showData: showData,
      titleStyle: titleStyle,
      episodeStyle: episodeStyle,
    );
  }
}

/// Internal widget to render progress details, next episode, and progress bar.
class _ProgressDetails extends StatelessWidget {
  final String title;
  final String traktId;
  final Map<String, dynamic> progress;
  final TraktApi apiService;
  final Map<String, dynamic> showData;
  final TextStyle? titleStyle;
  final TextStyle? episodeStyle;

  const _ProgressDetails({
    required this.title,
    required this.traktId,
    required this.progress,
    required this.apiService,
    required this.showData,
    this.titleStyle,
    this.episodeStyle,
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

    final effectiveTitleStyle =
        titleStyle ??
        Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (effectiveTitleStyle != null)
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: effectiveTitleStyle,
          ),
        if (nextEpisode != null) ...[
          const SizedBox(height: kSpaceBtwTitleWidget),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  '${AppLocalizations.of(context)!.seasonEpisodeFormat(nextEpisode['number'], nextEpisode['season'])} · ${nextEpisode['title']}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$episodesWatched/$totalEpisodes',
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: kSpaceBtwTitleWidget),
          TinyProgressBar(
            percent: percent,
            watched: episodesWatched,
            total: totalEpisodes,
            showText: true,
          ),
          const SizedBox(height: kSpaceBtwTitleWidget),
          EpisodeInfoButton(
            traktId: traktId,
            season: nextEpisode['season'],
            episode: nextEpisode['number'],
            apiService: apiService,
            showData: showData,
          ),
        ],
      ],
    );
  }
}
