import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

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

    Future<void> handleError(Color fallbackColor) async {
      await setMarkingColor(Colors.red, delayMs: 500); // Red: error
      await setMarkingColor(fallbackColor);
    }

    Future<void> removeSeasonFromHistory() async {
      final prevColor = markingColors.value[number] ?? Colors.green;
      await setMarkingColor(Colors.blue); // Blue: updating

      try {
        await traktApi.removeFromHistory(
          shows: [
            {
              "ids":
                  int.tryParse(showId) != null
                      ? {"trakt": int.parse(showId)}
                      : {"slug": showId},
              "seasons": [
                {"number": number},
              ],
            },
          ],
        );
        await refreshData();
        await setMarkingColor(Colors.grey);
      } catch (e) {
        await handleError(prevColor);
      }
    }

    Future<void> markSeasonAsWatched() async {
      await setMarkingColor(Colors.blue); // Blue: updating

      try {
        await traktApi.addToWatchHistory(
          shows: [
            {
              "ids":
                  int.tryParse(showId) != null
                      ? {"trakt": int.parse(showId)}
                      : {"slug": showId},
              "seasons": [
                {"number": number},
              ],
            },
          ],
        );
        await refreshData();
        await setMarkingColor(Colors.green, delayMs: 400); // Green: success
        await setMarkingColor(Colors.grey);
      } catch (e) {
        await handleError(Colors.grey);
      }
    }

    Future<void> handleMarkSeason() async {
      if (isComplete) {
        await removeSeasonFromHistory();
      } else {
        await markSeasonAsWatched();
      }
    }

    return IconButton(
      icon: Icon(
        Icons.check_circle,
        color:
            isComplete
                ? Colors.green
                : (markingColors.value[number] ?? Colors.grey),
      ),
      onPressed: handleMarkSeason,
      tooltip:
          isComplete
              ? 'Eliminar temporada del historial'
              : 'Marcar temporada como vista',
    );
  }
}
