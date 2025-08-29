import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:watching/l10n/app_localizations.dart';
import 'package:watching/pages/watchlist/state/watchlist_notifier.dart';
import 'package:watching/shared/constants/colors.dart';
import 'package:watching/shared/widgets/tiny_progress_bar.dart';

import 'providers/season_detail_provider.dart';
import 'providers/seasons_provider.dart';
import 'utils/season_helpers.dart';
import 'widgets/season_bulk_actions.dart';
import 'widgets/season_episode_list.dart';
import 'widgets/season_navigation.dart';

class SeasonDetailPage extends HookConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    return _SeasonDetailPageState(
      seasonNumber: seasonNumber,
      showId: showId,
      showData: showData,
      languageCode: languageCode,
      onEpisodeWatched: onEpisodeWatched,
    );
  }
}

class _SeasonDetailPageState extends HookConsumerWidget {
  const _SeasonDetailPageState({
    required this.showId,
    required this.seasonNumber,
    required this.showData,
    this.languageCode,
    this.onEpisodeWatched,
  });

  final String showId;
  final int seasonNumber;
  final String? languageCode;
  final VoidCallback? onEpisodeWatched;
  final Map<String, dynamic> showData;

  void _navigateToSeason(PageController pageController, int newSeasonNumber, int currentSeasonNumber) {
    if (newSeasonNumber == currentSeasonNumber) return;
    pageController.animateToPage(
      newSeasonNumber - 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageController = usePageController(initialPage: seasonNumber - 1);
    final currentSeasonNumber = useState(seasonNumber);
    final seasonsAsync = ref.watch(seasonsProvider(showId: showId));

    useEffect(() {
      return () => pageController.dispose();
    }, const []);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Consumer(
          builder: (context, ref, _) {
            final seasonDetail = ref.watch(
              seasonDetailProvider(
                showId: showId,
                seasonNumber: currentSeasonNumber.value,
                languageCode: languageCode,
              ),
            );

            return seasonDetail.when(
              data: (_) => Text(
                AppLocalizations.of(context)!.seasonTitle(currentSeasonNumber.value),
              ),
              loading: () => Text(
                AppLocalizations.of(context)!.seasonTitle(currentSeasonNumber.value),
              ),
              error: (_, __) => Text(
                AppLocalizations.of(context)!.seasonTitle(currentSeasonNumber.value),
              ),
            );
          },
        ),
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final seasonDetail = ref.watch(
                seasonDetailProvider(
                  showId: showId,
                  seasonNumber: currentSeasonNumber.value,
                  languageCode: languageCode,
                ),
              );

              return seasonDetail.when(
                data: (details) => SeasonBulkActionButton(
                  allWatched: allEpisodesWatched(
                    details.episodes,
                    details.progress,
                    currentSeasonNumber.value,
                  ),
                  loading: false,
                  episodeNumbers: details.episodes
                      .map((e) => e['number'] as int)
                      .toList(),
                  onBulkAction: (allCurrentlyWatched) async {
                    // If all episodes are already watched, unwatch them all
                    // Otherwise, mark all as watched
                    final shouldMarkAsWatched = !allCurrentlyWatched;
                    
                    await ref.read(
                      seasonDetailProvider(
                        showId: showId,
                        seasonNumber: currentSeasonNumber.value,
                        languageCode: languageCode,
                      ).notifier,
                    ).toggleSeasonWatched(shouldMarkAsWatched);
                    
                    onEpisodeWatched?.call();
                    ref.read(watchlistProvider.notifier).updateShowProgress(showId);
                  },
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              );
            },
          ),
        ],
      ),
      body: seasonsAsync.when(
        data: (seasons) {
          return Column(
            children: [
              SeasonNavigation(
                hasPreviousSeason: currentSeasonNumber.value > 1,
                hasNextSeason: currentSeasonNumber.value <
                    (seasons.last['number'] as int? ?? currentSeasonNumber.value),
                isLoadingSeasons: false,
                seasonNumber: currentSeasonNumber.value,
                seasonsList: seasons,
                onSeasonChanged: (newSeason) => _navigateToSeason(
                  pageController,
                  newSeason,
                  currentSeasonNumber.value,
                ),
                onPreviousSeason: () {
                  if (currentSeasonNumber.value > 1) {
                    _navigateToSeason(
                      pageController,
                      currentSeasonNumber.value - 1,
                      currentSeasonNumber.value,
                    );
                  }
                },
                onNextSeason: () {
                  if (currentSeasonNumber.value <
                      (seasons.last['number'] as int? ?? currentSeasonNumber.value)) {
                    _navigateToSeason(
                      pageController,
                      currentSeasonNumber.value + 1,
                      currentSeasonNumber.value,
                    );
                  }
                },
              ),
              Expanded(
                child: PageView.builder(
                  controller: pageController,
                  itemCount: seasons.length,
                  onPageChanged: (index) {
                    currentSeasonNumber.value = index + 1;
                  },
                  itemBuilder: (context, index) {
                    return _SeasonContent(
                      showId: showId,
                      seasonNumber: index + 1,
                      languageCode: languageCode,
                      onEpisodeWatched: onEpisodeWatched,
                      showData: showData,
                    );
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

class _SeasonContent extends HookConsumerWidget {
  const _SeasonContent({
    required this.showId,
    required this.seasonNumber,
    required this.languageCode,
    required this.onEpisodeWatched,
    required this.showData,
  });

  final String showId;
  final int seasonNumber;
  final String? languageCode;
  final VoidCallback? onEpisodeWatched;
  final Map<String, dynamic> showData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loadingEpisodes = useState<Map<int, bool>>({});
    final markingColors = useState<Map<int, Color>>({});

    useEffect(() {
      return () {
        loadingEpisodes.value.clear();
        markingColors.value.clear();
      };
    }, []);

    Future<void> handleToggleEpisode(int epNumber, bool watched) async {
      // Update local UI state immediately for better UX
      loadingEpisodes.value = {...loadingEpisodes.value, epNumber: true};

      try {
        await ref
            .read(
              seasonDetailProvider(
                showId: showId,
                seasonNumber: seasonNumber,
                languageCode: languageCode,
              ).notifier,
            )
            .toggleEpisodeWatched(epNumber, watched);

        onEpisodeWatched?.call();

        if (context.mounted) {
          ref.read(watchlistProvider.notifier).updateShowProgress(showId);
        }
      } catch (e) {
        if (context.mounted) {
          // Set error color and reset loading state immediately
          markingColors.value = {
            ...markingColors.value,
            epNumber: kErrorColorMessage,
          };
          loadingEpisodes.value = {
            ...loadingEpisodes.value,
            epNumber: false,
          };

          // Wait for 5 seconds before resetting the error color
          await Future.delayed(const Duration(milliseconds: 500));

          // Only update if still mounted
          if (context.mounted) {
            final updatedMarkingColors = {...markingColors.value};
            updatedMarkingColors.remove(epNumber);
            markingColors.value = updatedMarkingColors;
          }
        }
      } finally {
        if (context.mounted) {
          loadingEpisodes.value = {
            ...loadingEpisodes.value,
            epNumber: false,
          };
        }
      }
    }

    void handleSetMarkingColor(int epNumber, Color color, {int delayMs = 0}) {
      markingColors.value = {...markingColors.value, epNumber: color};

      if (delayMs > 0) {
        Future.delayed(Duration(milliseconds: delayMs), () {
          if (context.mounted) {
            final updatedMarkingColors = {...markingColors.value};
            updatedMarkingColors.remove(epNumber);
            markingColors.value = updatedMarkingColors;
          }
        });
      }
    }
    final seasonDetail = ref.watch(
      seasonDetailProvider(
        showId: showId,
        seasonNumber: seasonNumber,
        languageCode: languageCode,
      ),
    );

    return seasonDetail.when(
      data: (details) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 16.0,
            ),
            child: TinyProgressBar(
              percent: getSeasonProgress(details.progress, seasonNumber),
              watched: (details.progress['seasons'] as List?)?.firstWhere(
                (s) => s['number'] == seasonNumber,
                orElse: () => {'completed': 0},
              )['completed'] ?? 0,
              total: (details.progress['seasons'] as List?)?.firstWhere(
                (s) => s['number'] == seasonNumber,
                orElse: () => {'aired': 1},
              )['aired'] ?? 1,
            ),
          ),
          Expanded(
            child: SeasonEpisodeList(
              episodes: details.episodes,
              progress: details.progress,
              seasonNumber: seasonNumber,
              episodeStates: details.episodeStates,
              markingColors: markingColors.value,
              loadingEpisodes: loadingEpisodes.value,
              showId: showId,
              showData: showData,
              languageCode: languageCode,
              onToggleEpisode: handleToggleEpisode,
              setMarkingColor: handleSetMarkingColor,
            ),
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
    );
  }
}
