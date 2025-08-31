import 'package:flutter/material.dart';
import 'package:watching/shared/constants/measures.dart';
import 'package:watching/shared/widgets/tiny_progress_bar.dart';
import 'package:watching/shared/pages/show_details/widgets/current_episode/widgets/action_buttons.dart';
import 'package:watching/shared/pages/show_details/widgets/current_episode/widgets/episode_info_row.dart';

class CurrentEpisodeDetails extends StatelessWidget {
  final int? seasonNumber;
  final int? episodeNumber;
  final String? episodeName;
  final int watchedEpisodes;
  final int totalEpisodes;
  final double progressPercent;
  final VoidCallback onRefreshProgress;
  final Map<String, dynamic>? progressData;
  final Map<String, dynamic>? nextEpisode;
  final Map<String, dynamic>? showData;
  final String traktId;
  final String? languageCode;
  final VoidCallback? onWatchedStatusChanged;
  final VoidCallback? onEpisodeWatched;

  const CurrentEpisodeDetails({
    super.key,
    required this.seasonNumber,
    required this.episodeNumber,
    required this.episodeName,
    required this.watchedEpisodes,
    required this.totalEpisodes,
    required this.progressPercent,
    required this.onRefreshProgress,
    required this.progressData,
    required this.nextEpisode,
    required this.showData,
    required this.traktId,
    required this.languageCode,
    required this.onWatchedStatusChanged,
    this.onEpisodeWatched,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: kSpaceBtwWidgets),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EpisodeInfoRow(
            seasonNumber: seasonNumber,
            episodeNumber: episodeNumber,
            episodeName: episodeName,
            watchedEpisodes: watchedEpisodes,
            totalEpisodes: totalEpisodes,
          ),
          const SizedBox(height: 12),
          TinyProgressBar(
            percent: progressPercent,
            watched: watchedEpisodes,
            total: totalEpisodes,
          ),
          const SizedBox(height: 16),
          ActionButtons(
            nextEpisode: nextEpisode,
            showData: showData,
            traktId: traktId,
            languageCode: languageCode,
            onWatchedStatusChanged: onWatchedStatusChanged,
            onRefreshProgress: onRefreshProgress,
            seasonNumber: seasonNumber,
            episodeNumber: episodeNumber,
            progressData: progressData,
            onEpisodeWatched: onEpisodeWatched,
          ),
        ],
      ),
    );
  }
}
