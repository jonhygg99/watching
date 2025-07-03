/// Controlador de acciones bulk y toggle para episodios de temporada.
import 'package:flutter/material.dart';
import '../../../services/trakt/trakt_api.dart';

class SeasonActions {
  /// Acción bulk: marcar o desmarcar todos los episodios de la temporada.
  static Future<void> handleBulkAction({
    required bool allWatched,
    required List<Map<String, dynamic>> episodes,
    required int seasonNumber,
    required String showId,
    required String? languageCode,
    required TraktApi traktApi,
    required Future<void> Function(int, Color, {int delayMs}) setMarkingColor,
    required ValueNotifier<List<Map<String, dynamic>>> episodesState,
    required ValueNotifier<Map<String, dynamic>?> progressState,
  }) async {
    for (final ep in episodes.map((e) => e['number'] as int)) {
      await setMarkingColor(ep, Colors.blue);
    }
    try {
      if (allWatched) {
        await traktApi.removeFromHistory(
          shows: [
            {
              "ids":
                  int.tryParse(showId) != null
                      ? {"trakt": int.parse(showId)}
                      : {"slug": showId},
              "seasons": [
                {
                  "number": seasonNumber,
                  "episodes":
                      episodes.map((n) => {"number": n['number']}).toList(),
                },
              ],
            },
          ],
        );
      } else {
        await traktApi.addToWatchHistory(
          shows: [
            {
              "ids":
                  int.tryParse(showId) != null
                      ? {"trakt": int.parse(showId)}
                      : {"slug": showId},
              "seasons": [
                {
                  "number": seasonNumber,
                  "episodes":
                      episodes.map((n) => {"number": n['number']}).toList(),
                },
              ],
            },
          ],
        );
      }
      final List<Map<String, dynamic>> eps = List<Map<String, dynamic>>.from(
        await traktApi.getSeasonEpisodes(
          id: showId,
          season: seasonNumber,
          translations: languageCode,
        ),
      );
      final Map<String, dynamic> prog = Map<String, dynamic>.from(
        await traktApi.getShowWatchedProgress(id: showId),
      );
      episodesState.value = eps;
      progressState.value = prog;
      final List<dynamic>? seasons = prog["seasons"] as List<dynamic>?;
      final Map<String, dynamic>? season = seasons
          ?.cast<Map<String, dynamic>>()
          .firstWhere((s) => s["number"] == seasonNumber, orElse: () => {});
      final Set<int> watchedNumbers = <int>{};
      if (season != null && season["episodes"] is List) {
        for (final e in (season["episodes"] as List)) {
          final completed = e["completed"];
          if ((completed is int && completed > 0) || completed == true) {
            watchedNumbers.add(e["number"] as int);
          }
        }
      }
      for (final ep in episodes.map((e) => e['number'] as int)) {
        if (watchedNumbers.contains(ep)) {
          await setMarkingColor(ep, Colors.green);
        } else {
          await setMarkingColor(ep, Colors.grey);
        }
      }
    } catch (e) {
      for (final ep in episodes.map((e) => e['number'] as int)) {
        await setMarkingColor(ep, Colors.red, delayMs: 500);
        await setMarkingColor(ep, Colors.grey);
      }
    }
  }

  /// Acción de marcar/desmarcar un episodio individual.
  static Future<void> handleToggleEpisode({
    required int epNumber,
    required bool watched,
    required int seasonNumber,
    required String showId,
    required String? languageCode,
    required TraktApi traktApi,
    required Future<void> Function(int, Color, {int delayMs}) setMarkingColor,
    required ValueNotifier<List<Map<String, dynamic>>> episodesState,
    required ValueNotifier<Map<String, dynamic>?> progressState,
    VoidCallback? onEpisodeToggled,
  }) async {
    await setMarkingColor(epNumber, Colors.blue);
    try {
      if (watched) {
        await traktApi.removeFromHistory(
          shows: [
            {
              "ids":
                  int.tryParse(showId) != null
                      ? {"trakt": int.parse(showId)}
                      : {"slug": showId},
              "seasons": [
                {
                  "number": seasonNumber,
                  "episodes": [
                    {"number": epNumber},
                  ],
                },
              ],
            },
          ],
        );
      } else {
        await traktApi.addToWatchHistory(
          shows: [
            {
              "ids":
                  int.tryParse(showId) != null
                      ? {"trakt": int.parse(showId)}
                      : {"slug": showId},
              "seasons": [
                {
                  "number": seasonNumber,
                  "episodes": [
                    {"number": epNumber},
                  ],
                },
              ],
            },
          ],
        );
      }
      final List<Map<String, dynamic>> eps = List<Map<String, dynamic>>.from(
        await traktApi.getSeasonEpisodes(
          id: showId,
          season: seasonNumber,
          translations: languageCode,
        ),
      );
      final Map<String, dynamic> prog = Map<String, dynamic>.from(
        await traktApi.getShowWatchedProgress(id: showId),
      );
      episodesState.value = eps;
      progressState.value = prog;
      final List<dynamic>? seasons = prog["seasons"] as List<dynamic>?;
      final Map<String, dynamic>? season = seasons
          ?.cast<Map<String, dynamic>>()
          .firstWhere((s) => s["number"] == seasonNumber, orElse: () => {});
      bool isNowWatched = false;
      if (season != null && season["episodes"] is List) {
        isNowWatched = (season["episodes"] as List).any(
          (e) =>
              e["number"] == epNumber &&
              (e["completed"] == true ||
                  (e["completed"] is int && e["completed"] > 0)),
        );
      }
      if (isNowWatched) {
        await setMarkingColor(epNumber, Colors.green);
        // Notify that an episode was toggled
        onEpisodeToggled?.call();
      } else {
        await setMarkingColor(epNumber, Colors.grey);
        // Notify that an episode was toggled
        onEpisodeToggled?.call();
      }
    } catch (e) {
      await setMarkingColor(epNumber, Colors.red, delayMs: 500);
      await setMarkingColor(epNumber, Colors.grey);
    }
  }
}
