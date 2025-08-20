import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:watching/show_details/widgets/fridge/episode_batch_actions.dart';

class SeasonMarkButton extends HookWidget {
  final bool isComplete;
  final int number;
  final String showId;
  final dynamic traktApi;
  final ValueNotifier<List<dynamic>?> seasons;
  final ValueNotifier<Map<String, dynamic>?> progress;
  final VoidCallback? onProgressChanged;

  const SeasonMarkButton({
    super.key,
    required this.isComplete,
    required this.number,
    required this.showId,
    required this.traktApi,
    required this.seasons,
    required this.progress,
    this.onProgressChanged,
  });

  @override
  Widget build(BuildContext context) {
    // State for marking colors
    final markingColors = useState<Map<int, Color>>({});

    // Helper for color feedback
    Future<void> setMarkingColor(Color color, {int delayMs = 0}) async {
      markingColors.value = {...markingColors.value, number: color};
      if (delayMs > 0) {
        await Future.delayed(Duration(milliseconds: delayMs));
      }
    }

    Future<void> refreshData() async {
      final s = await traktApi.getSeasons(showId);
      final p = await traktApi.getShowWatchedProgress(id: showId);
      seasons.value = s;
      progress.value = p;
      onProgressChanged?.call();
    }

    Future<void> handleError() async {
      await setMarkingColor(Colors.red, delayMs: 500); // Red: error
      await setMarkingColor(Colors.grey);
    }

    // Mark a season as unwatched by marking all its episodes as unwatched
    Future<void> markSeasonAsUnwatched() async {
      // Set to blue immediately to show loading state
      await setMarkingColor(Colors.blue);

      try {
        // First get all episodes in the season to mark them as unwatched
        final episodes = await traktApi.getSeasonEpisodes(
          id: showId,
          season: number,
        );

        // Mark each episode as unwatched using batch actions
        final completer = Completer<void>();
        int remainingEpisodes = episodes.length;

        for (final episode in episodes) {
          final epNumber = episode['number'] as int;

          EpisodeBatchActions.toggleEpisode(
            showId: showId,
            seasonNumber: number,
            episodeNumber: epNumber,
            watched: false,
            traktApi: traktApi,
            onComplete: () async {
              remainingEpisodes--;
              if (remainingEpisodes == 0 && !completer.isCompleted) {
                await refreshData();
                await setMarkingColor(Colors.grey);
                completer.complete();
              }
            },
          );
        }

        // If no episodes, just complete immediately
        if (episodes.isEmpty) {
          await refreshData();
          await setMarkingColor(Colors.grey);
          completer.complete();
        }

        return completer.future;
      } catch (e) {
        await handleError();
        rethrow;
      }
    }

    // Mark a season as watched by marking all its episodes as watched
    Future<void> markSeasonAsWatched() async {
      // Set to blue immediately to show loading state
      await setMarkingColor(Colors.blue);

      try {
        // First get all episodes in the season to mark them as watched
        final episodes = await traktApi.getSeasonEpisodes(
          id: showId,
          season: number,
        );

        // Mark each episode as watched using batch actions
        final completer = Completer<void>();
        int remainingEpisodes = episodes.length;

        for (final episode in episodes) {
          final epNumber = episode['number'] as int;

          EpisodeBatchActions.toggleEpisode(
            showId: showId,
            seasonNumber: number,
            episodeNumber: epNumber,
            watched: true,
            traktApi: traktApi,
            onComplete: () async {
              remainingEpisodes--;
              if (remainingEpisodes == 0 && !completer.isCompleted) {
                await refreshData();
                await setMarkingColor(
                  Colors.green,
                  delayMs: 400,
                ); // Green: success
                await setMarkingColor(Colors.grey);
                completer.complete();
              }
            },
          );
        }

        // If no episodes, just complete immediately
        if (episodes.isEmpty) {
          await refreshData();
          await setMarkingColor(Colors.green, delayMs: 400);
          await setMarkingColor(Colors.grey);
          completer.complete();
        }

        return completer.future;
      } catch (e) {
        await handleError();
        rethrow;
      }
    }

    // Track the current loading state
    final isLoading = useState(false);

    // Handle the mark season action with loading state
    void onMarkSeason() {
      if (isLoading.value) return; // Prevent multiple clicks

      isLoading.value = true;

      Future<void> markAction =
          isComplete ? markSeasonAsUnwatched() : markSeasonAsWatched();

      markAction
          .whenComplete(() {
            isLoading.value = false;
          })
          .catchError((_) {
            isLoading.value = false;
          });
    }

    // Determine button color based on state
    final Color buttonColor =
        isLoading.value
            ? Colors.blue
            : (isComplete
                ? Colors.green
                : (markingColors.value[number] ?? Colors.grey));

    return IconButton(
      icon: Icon(Icons.check_circle, color: buttonColor),
      onPressed:
          isLoading.value ? null : onMarkSeason, // Disable button while loading
      tooltip:
          isLoading.value
              ? 'Procesando...'
              : (isComplete
                  ? 'Eliminar temporada del historial'
                  : 'Marcar temporada como vista'),
    );
  }
}
