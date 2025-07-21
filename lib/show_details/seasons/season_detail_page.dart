import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../services/trakt/trakt_api.dart';
import '../../../providers/watchlist_providers.dart';
import '../../watchlist/progress_bar.dart';
import 'season_bulk_actions.dart';
import 'season_episode_list.dart';
import 'helpers/season_helpers.dart';
import 'controllers/season_actions.dart';

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

    // Fetch episodes and progress for the season
    useEffect(() {
      Future<void> fetchData() async {
        loading.value = true;
        try {
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
        title: Text('Temporada $seasonNumber'),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 16.0,
                    ),
                    child: ProgressBar(
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
