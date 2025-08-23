import 'package:flutter/material.dart';
import 'package:watching/l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:watching/api/trakt/trakt_api.dart';
import 'package:watching/pages/watchlist/state/watchlist_notifier.dart';
import 'package:watching/shared/widgets/tiny_progress_bar.dart';
import 'season_bulk_actions.dart';
import 'season_episode_list.dart';
import 'controllers/season_actions.dart';

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

  final watchedEpisodes =
      (season['episodes'] as List)
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

/// Página de detalle de temporada modularizada según Windsurf Guidelines.
/// Se apoya en widgets hijos para acciones bulk y renderizado de episodios.

/// Page to display details and episodes of a season, with actions to mark all or individual episodes as watched.
class SeasonDetailPage extends HookConsumerWidget {
  final int seasonNumber;
  final String showId;
  final Map<String, dynamic> showData;
  final String? languageCode;
  final Function()? onEpisodeWatched;
  final Function()? onWatchlistUpdate;

  const SeasonDetailPage({
    super.key,
    required this.seasonNumber,
    required this.showId,
    required this.showData,
    this.languageCode,
    this.onEpisodeWatched,
    this.onWatchlistUpdate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final traktApi = TraktApi();
    final ValueNotifier<bool> loading = useState<bool>(true);
    final ValueNotifier<List<Map<String, dynamic>>> episodes =
        useState<List<Map<String, dynamic>>>([]);
    final ValueNotifier<Map<String, dynamic>?> progress =
        useState<Map<String, dynamic>?>(null);
    final ValueNotifier<Map<int, Color>> markingColors =
        useState<Map<int, Color>>({});
    final ValueNotifier<List<Map<String, dynamic>>> seasonsList =
        useState<List<Map<String, dynamic>>>(showData['seasons'] ?? []);
    final ValueNotifier<bool> isLoadingSeasons = useState<bool>(false);

    // Fetch seasons if not already available and filter out season 0 if it has no episodes
    Future<void> fetchSeasonsIfNeeded() async {
      if (seasonsList.value.isEmpty) {
        try {
          isLoadingSeasons.value = true;
          final seasons = await traktApi.getSeasons(showId);

          // Filter out season 0 (specials) if it has 0 episodes
          final filteredSeasons = List<Map<String, dynamic>>.from(seasons)
            ..removeWhere((season) {
              final number = season['number'];
              final episodeCount = season['episode_count'] ?? 0;
              // Hide only specials (season 0) if empty
              return number == 0 && episodeCount == 0;
            });

          seasonsList.value = filteredSeasons;
        } catch (e) {
          debugPrint('Error fetching seasons: $e');
        } finally {
          isLoadingSeasons.value = false;
        }
      }
    }

    // Find the current season index and check for previous/next seasons
    final (hasPreviousSeason, hasNextSeason) = useMemoized(() {
      if (seasonsList.value.isEmpty) return (false, false);

      final currentIndex = seasonsList.value.indexWhere(
        (s) => s['number'] == seasonNumber,
      );

      return (
        currentIndex > 0, // has previous
        currentIndex < seasonsList.value.length - 1, // has next
      );
    }, [seasonsList.value, seasonNumber]);

    // Navigate to a different season
    void navigateToSeason(int newSeasonNumber) {
      if (newSeasonNumber == seasonNumber) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) => SeasonDetailPage(
                seasonNumber: newSeasonNumber,
                showId: showId,
                showData: showData,
                languageCode: languageCode,
                onEpisodeWatched: onEpisodeWatched,
                onWatchlistUpdate: onWatchlistUpdate,
              ),
        ),
      );
    }

    // Fetch episodes and progress for the season
    useEffect(() {
      Future<void> fetchData() async {
        loading.value = true;
        try {
          // Fetch seasons first if needed
          await fetchSeasonsIfNeeded();

          // Then fetch episodes and progress
          final List<Map<String, dynamic>> eps =
              List<Map<String, dynamic>>.from(
                await traktApi.getSeasonEpisodes(
                  id: showId,
                  season: seasonNumber,
                  translations: languageCode,
                ),
              );
          final Map<String, dynamic> prog = Map<String, dynamic>.from(
            await traktApi.getShowWatchedProgress(id: showId),
          );
          episodes.value = eps;
          progress.value = prog;
        } finally {
          loading.value = false;
        }
      }

      fetchData();
      return null;
    }, [showId, seasonNumber, languageCode]);

    // Helper for marking color feedback
    Future<void> setMarkingColor(
      int epNumber,
      Color color, {
      int delayMs = 0,
    }) async {
      markingColors.value = {...markingColors.value, epNumber: color};
      if (delayMs > 0) {
        await Future.delayed(Duration(milliseconds: delayMs));
      }
    }

    // --- Controladores de acciones ---
    Future<void> handleBulkAction(bool allWatched) async {
      await SeasonActions.handleBulkAction(
        allWatched: allWatched,
        episodes: episodes.value,
        seasonNumber: seasonNumber,
        showId: showId,
        languageCode: languageCode,
        traktApi: traktApi,
        setMarkingColor: setMarkingColor,
        episodesState: episodes,
        progressState: progress,
      );
      // Notify parent that episodes were updated
      if (onEpisodeWatched != null) {
        onEpisodeWatched!();
      }
    }

    Future<void> handleToggleEpisode(int epNumber, bool watched) async {
      await SeasonActions.handleToggleEpisode(
        epNumber: epNumber,
        watched: watched,
        seasonNumber: seasonNumber,
        showId: showId,
        languageCode: languageCode,
        traktApi: traktApi,
        setMarkingColor: setMarkingColor,
        episodesState: episodes,
        progressState: progress,
        onEpisodeToggled: () {
          // Update only the specific show in the watchlist
          final container = ProviderScope.containerOf(context);
          final watchlistNotifier = container.read(watchlistProvider.notifier);

          // Update just this show's progress
          watchlistNotifier.updateShowProgress(showId);

          // Notify parent that an episode's watched status changed
          onEpisodeWatched?.call();
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(AppLocalizations.of(context)!.seasonTitle(seasonNumber)),
        actions: [
          SeasonBulkActionButton(
            allWatched: allEpisodesWatched(
              episodes.value,
              progress.value,
              seasonNumber,
            ),
            loading: loading.value,
            episodeNumbers:
                episodes.value.map((e) => e['number'] as int).toList(),
            onBulkAction: handleBulkAction,
          ),
        ],
      ),
      body:
          loading.value
              ? const Center(child: CircularProgressIndicator())
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Season Navigation Row
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 16.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Previous Season Button
                        TextButton(
                          onPressed:
                              hasPreviousSeason
                                  ? () {
                                    final currentIndex = seasonsList.value
                                        .indexWhere(
                                          (s) => s['number'] == seasonNumber,
                                        );
                                    if (currentIndex > 0) {
                                      final prevSeason =
                                          seasonsList.value[currentIndex - 1];
                                      navigateToSeason(prevSeason['number']);
                                    }
                                  }
                                  : null,
                          child: Text(
                            AppLocalizations.of(context)!.previousSeason,
                          ),
                        ),

                        // Season Dropdown
                        if (isLoadingSeasons.value)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        else if (seasonsList.value.isNotEmpty)
                          DropdownButton<int>(
                            value: seasonNumber,
                            items:
                                seasonsList.value.map<DropdownMenuItem<int>>((
                                  season,
                                ) {
                                  return DropdownMenuItem<int>(
                                    value: season['number'],
                                    child: Text('Season ${season['number']}'),
                                  );
                                }).toList(),
                            onChanged: (int? newValue) {
                              if (newValue != null) {
                                navigateToSeason(newValue);
                              }
                            },
                          ),

                        // Next Season Button
                        TextButton(
                          onPressed:
                              hasNextSeason
                                  ? () {
                                    final currentIndex = seasonsList.value
                                        .indexWhere(
                                          (s) => s['number'] == seasonNumber,
                                        );
                                    if (currentIndex <
                                        seasonsList.value.length - 1) {
                                      final nextSeason =
                                          seasonsList.value[currentIndex + 1];
                                      navigateToSeason(nextSeason['number']);
                                    }
                                  }
                                  : null,
                          child: Text(AppLocalizations.of(context)!.nextSeason),
                        ),
                      ],
                    ),
                  ),

                  // Progress Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 16.0,
                    ),
                    child: TinyProgressBar(
                      percent: getSeasonProgress(progress.value, seasonNumber),
                      watched:
                          (progress.value != null)
                              ? (progress.value!["seasons"] as List)
                                  .firstWhere(
                                    (s) => s["number"] == seasonNumber,
                                    orElse: () => {},
                                  )
                                  .putIfAbsent("completed", () => 0)
                              : 0,
                      total:
                          (progress.value != null)
                              ? (progress.value!["seasons"] as List)
                                  .firstWhere(
                                    (s) => s["number"] == seasonNumber,
                                    orElse: () => {},
                                  )
                                  .putIfAbsent("aired", () => 1)
                              : 1,
                    ),
                  ),

                  // Episodes List
                  Expanded(
                    child: SeasonEpisodeList(
                      episodes: episodes.value,
                      progress: progress.value,
                      markingColors: markingColors.value,
                      loading: loading.value,
                      seasonNumber: seasonNumber,
                      showId: showId,
                      showData: showData,
                      languageCode: languageCode,
                      setMarkingColor: setMarkingColor,
                      onToggleEpisode: handleToggleEpisode,
                    ),
                  ),
                ],
              ),
    );
  }
}
