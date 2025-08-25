import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:watching/l10n/app_localizations.dart';
import 'package:watching/pages/watchlist/state/watchlist_notifier.dart';
import 'package:watching/shared/widgets/tiny_progress_bar.dart';

import 'providers/season_detail_provider.dart';
import 'providers/seasons_provider.dart';
import 'utils/season_helpers.dart';
import 'widgets/season_bulk_actions.dart';
import 'widgets/season_episode_list.dart';
import 'widgets/season_navigation.dart';

class SeasonDetailPage extends ConsumerWidget {
  final int seasonNumber;
  final String showId;
  final Map<String, dynamic> showData;
  final String? languageCode;
  final VoidCallback? onEpisodeWatched;

  const SeasonDetailPage({
    super.key,
    required this.seasonNumber,
    required this.showId,
    required this.showData,
    this.languageCode,
    this.onEpisodeWatched,
  });

  void _navigateToSeason(BuildContext context, int newSeasonNumber) {
    if (newSeasonNumber == seasonNumber) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SeasonDetailPage(
          seasonNumber: newSeasonNumber,
          showId: showId,
          showData: showData,
          languageCode: languageCode,
          onEpisodeWatched: onEpisodeWatched,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seasonDetail = ref.watch(seasonDetailProvider(
      showId: showId,
      seasonNumber: seasonNumber,
      languageCode: languageCode,
    ));
    final seasonsAsync = ref.watch(seasonsProvider(showId: showId));

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(AppLocalizations.of(context)!.seasonTitle(seasonNumber)),
        actions: [
          seasonDetail.when(
            data: (details) => SeasonBulkActionButton(
              allWatched: allEpisodesWatched(
                details.episodes,
                details.progress,
                seasonNumber,
              ),
              loading: false,
              episodeNumbers:
                  details.episodes.map((e) => e['number'] as int).toList(),
              onBulkAction: (watched) async {
                await ref
                    .read(seasonDetailProvider(
                      showId: showId,
                      seasonNumber: seasonNumber,
                      languageCode: languageCode,
                    ).notifier)
                    .toggleSeasonWatched(watched, details.episodes);
                onEpisodeWatched?.call();
                ref.read(watchlistProvider.notifier).updateShowProgress(showId);
              },
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: seasonDetail.when(
        data: (details) {
          final seasons = seasonsAsync.asData?.value ?? [];
          final currentIndex = seasons.indexWhere((s) => s['number'] == seasonNumber);
          final hasPreviousSeason = currentIndex > 0;
          final hasNextSeason = currentIndex < seasons.length - 1;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SeasonNavigation(
                hasPreviousSeason: hasPreviousSeason,
                hasNextSeason: hasNextSeason,
                isLoadingSeasons: seasonsAsync.isLoading,
                seasonNumber: seasonNumber,
                seasonsList: seasons,
                onSeasonChanged: (newSeason) => _navigateToSeason(context, newSeason),
                onPreviousSeason: () {
                  if (hasPreviousSeason) {
                    final prevSeason = seasons[currentIndex - 1];
                    _navigateToSeason(context, prevSeason['number']);
                  }
                },
                onNextSeason: () {
                  if (hasNextSeason) {
                    final nextSeason = seasons[currentIndex + 1];
                    _navigateToSeason(context, nextSeason['number']);
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 16.0,
                ),
                child: TinyProgressBar(
                  percent: getSeasonProgress(details.progress, seasonNumber),
                  watched: (details.progress['seasons'] as List?)
                          ?.firstWhere((s) => s['number'] == seasonNumber, orElse: () => {'completed': 0})
                          ['completed'] ??
                      0,
                  total: (details.progress['seasons'] as List?)
                          ?.firstWhere((s) => s['number'] == seasonNumber, orElse: () => {'aired': 1})
                          ['aired'] ??
                      1,
                ),
              ),
              Expanded(
                child: SeasonEpisodeList(
                  episodes: details.episodes,
                  progress: details.progress,
                  seasonNumber: seasonNumber,
                  markingColors: const {}, // Initialize with empty map
                  loading: false, // Set to false as we already have the data
                  showId: showId,
                  showData: showData,
                  languageCode: languageCode,
                  onToggleEpisode: (epNumber, watched) async {
                    await ref
                        .read(seasonDetailProvider(
                          showId: showId,
                          seasonNumber: seasonNumber,
                          languageCode: languageCode,
                        ).notifier)
                        .toggleEpisodeWatched(watched, epNumber);
                    onEpisodeWatched?.call();
                    ref.read(watchlistProvider.notifier).updateShowProgress(showId);
                  },
                  setMarkingColor: (epNumber, color, {delayMs = 0}) async {
                    // This can be implemented if needed for visual feedback
                    if (delayMs > 0) {
                      await Future.delayed(Duration(milliseconds: delayMs));
                    }
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}
