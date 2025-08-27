import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watching/l10n/app_localizations.dart';
import 'package:watching/pages/watchlist/state/watchlist_notifier.dart';
import 'package:watching/shared/widgets/tiny_progress_bar.dart';

import 'providers/season_detail_provider.dart';
import 'providers/seasons_provider.dart';
import 'utils/season_helpers.dart';
import 'widgets/season_bulk_actions.dart';
import 'widgets/season_episode_list.dart';
import 'widgets/season_navigation.dart';

class SeasonDetailPage extends ConsumerStatefulWidget {
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

  @override
  ConsumerState<SeasonDetailPage> createState() => _SeasonDetailPageState();
}

class _SeasonDetailPageState extends ConsumerState<SeasonDetailPage> {
  static const kErrorColorMessage = Color(
    0xFFDC3545,
  ); // Red color for error state
  final Map<int, bool> _loadingEpisodes = {};
  final Map<int, Color> _markingColors = {};

  void _navigateToSeason(BuildContext context, int newSeasonNumber) {
    if (newSeasonNumber == widget.seasonNumber) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (context) => SeasonDetailPage(
              seasonNumber: newSeasonNumber,
              showId: widget.showId,
              showData: widget.showData,
              languageCode: widget.languageCode,
              onEpisodeWatched: widget.onEpisodeWatched,
            ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Initialize any required state here
  }

  @override
  Widget build(BuildContext context) {
    final seasonDetail = ref.watch(
      seasonDetailProvider(
        showId: widget.showId,
        seasonNumber: widget.seasonNumber,
        languageCode: widget.languageCode,
      ),
    );
    final seasonsAsync = ref.watch(seasonsProvider(showId: widget.showId));

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(
          AppLocalizations.of(context)!.seasonTitle(widget.seasonNumber),
        ),
        actions: [
          seasonDetail.when(
            data:
                (details) => SeasonBulkActionButton(
                  allWatched: allEpisodesWatched(
                    details.episodes,
                    details.progress,
                    widget.seasonNumber,
                  ),
                  loading: false,
                  episodeNumbers:
                      details.episodes.map((e) => e['number'] as int).toList(),
                  onBulkAction: (watched) async {
                    await ref
                        .read(
                          seasonDetailProvider(
                            showId: widget.showId,
                            seasonNumber: widget.seasonNumber,
                            languageCode: widget.languageCode,
                          ).notifier,
                        )
                        .toggleSeasonWatched(watched, details.episodes);
                    widget.onEpisodeWatched?.call();
                    ref
                        .read(watchlistProvider.notifier)
                        .updateShowProgress(widget.showId);
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
          final currentIndex = seasons.indexWhere(
            (s) => s['number'] == widget.seasonNumber,
          );
          final hasPreviousSeason = currentIndex > 0;
          final hasNextSeason = currentIndex < seasons.length - 1;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SeasonNavigation(
                hasPreviousSeason: hasPreviousSeason,
                hasNextSeason: hasNextSeason,
                isLoadingSeasons: seasonsAsync.isLoading,
                seasonNumber: widget.seasonNumber,
                seasonsList: seasons,
                onSeasonChanged:
                    (newSeason) => _navigateToSeason(context, newSeason),
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
                  percent: getSeasonProgress(
                    details.progress,
                    widget.seasonNumber,
                  ),
                  watched:
                      (details.progress['seasons'] as List?)?.firstWhere(
                        (s) => s['number'] == widget.seasonNumber,
                        orElse: () => {'completed': 0},
                      )['completed'] ??
                      0,
                  total:
                      (details.progress['seasons'] as List?)?.firstWhere(
                        (s) => s['number'] == widget.seasonNumber,
                        orElse: () => {'aired': 1},
                      )['aired'] ??
                      1,
                ),
              ),
              Expanded(
                child: SeasonEpisodeList(
                  episodes: details.episodes,
                  progress: details.progress,
                  seasonNumber: widget.seasonNumber,
                  markingColors: _markingColors,
                  loadingEpisodes: _loadingEpisodes,
                  showId: widget.showId,
                  showData: widget.showData,
                  languageCode: widget.languageCode,
                  onToggleEpisode: (epNumber, watched) async {
                    // Save the original color before making any changes
                    setState(() {
                      _loadingEpisodes[epNumber] = true;
                    });

                    try {
                      final provider = ref.read(
                        seasonDetailProvider(
                          showId: widget.showId,
                          seasonNumber: widget.seasonNumber,
                          languageCode: widget.languageCode,
                        ).notifier,
                      );

                      await provider.toggleEpisodeWatched(watched, epNumber);

                      widget.onEpisodeWatched?.call();
                      if (mounted) {
                        ref
                            .read(watchlistProvider.notifier)
                            .updateShowProgress(widget.showId);
                      }
                    } catch (e) {
                      if (mounted) {
                        // Set error color and reset loading state immediately
                        setState(() {
                          _markingColors[epNumber] = kErrorColorMessage;
                          _loadingEpisodes[epNumber] = false;
                        });

                        // Wait for 5 seconds before resetting the error color
                        await Future.delayed(const Duration(milliseconds: 500));

                        // Only update if still mounted
                        if (mounted) {
                          setState(() {
                            // Remove the error color and let the UI show the actual watched state
                            _markingColors.remove(epNumber);
                          });
                        }
                      }
                    } finally {
                      if (mounted) {
                        setState(() {
                          _loadingEpisodes[epNumber] = false;
                        });
                      }
                    }
                  },
                  setMarkingColor: (epNumber, color, {delayMs = 0}) async {
                    if (color != _markingColors[epNumber]) {
                      if (delayMs > 0) {
                        await Future.delayed(Duration(milliseconds: delayMs));
                      }
                      if (mounted) {
                        setState(() {
                          _markingColors[epNumber] = color;
                        });
                      }
                    }
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
