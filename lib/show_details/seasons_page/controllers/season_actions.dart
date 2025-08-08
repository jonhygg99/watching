/// Controlador de acciones bulk y toggle para episodios de temporada.
import 'package:flutter/material.dart';
import 'package:watching/api/trakt/trakt_api.dart';

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
    required String showId,
    required int seasonNumber,
    required int epNumber,
    required bool watched,
    required TraktApi traktApi,
    required Future<void> Function(int, Color, {int delayMs}) setMarkingColor,
    required ValueNotifier<List<Map<String, dynamic>>> episodesState,
    required ValueNotifier<Map<String, dynamic>?> progressState,
    String? languageCode,
    VoidCallback? onEpisodeToggled,
  }) async {
    await setMarkingColor(epNumber, Colors.blue);
    try {
      if (watched) {
        await traktApi.addToWatchHistory(
          shows: [
            {
              "ids": int.tryParse(showId) != null 
                  ? {"trakt": int.parse(showId)} 
                  : {"slug": showId},
              "seasons": [
                {
                  "number": seasonNumber,
                  "episodes": [
                    {"number": epNumber}
                  ],
                },
              ],
            },
          ],
        );
      } else {
        await traktApi.removeFromHistory(
          shows: [
            {
              "ids": int.tryParse(showId) != null 
                  ? {"trakt": int.parse(showId)} 
                  : {"slug": showId},
              "seasons": [
                {
                  "number": seasonNumber,
                  "episodes": [
                    {"number": epNumber}
                  ],
                },
              ],
            },
          ],
        );
      }

      // Refresh the data
      final eps = await traktApi.getSeasonEpisodes(
        id: showId,
        season: seasonNumber,
        translations: languageCode,
      );
      final prog = await traktApi.getShowWatchedProgress(id: showId);
      
      // Update state
      episodesState.value = List<Map<String, dynamic>>.from(eps);
      progressState.value = Map<String, dynamic>.from(prog);
      
      // Update marking color based on new state
      final isWatched = _isEpisodeWatched(prog, seasonNumber, epNumber);
      await setMarkingColor(
        epNumber,
        isWatched ? Colors.green : Colors.grey,
      );
      
      // Notify that an episode was toggled
      onEpisodeToggled?.call();
    } catch (e) {
      await setMarkingColor(epNumber, Colors.red, delayMs: 500);
      await setMarkingColor(epNumber, Colors.grey);
      onEpisodeToggled?.call();
      rethrow;
    }
  }

  static bool _isEpisodeWatched(Map<String, dynamic> progress, int seasonNumber, int epNumber) {
    final seasons = progress['seasons'] as List?;
    if (seasons == null) return false;
    
    for (final season in seasons.cast<Map<String, dynamic>>()) {
      if (season['number'] == seasonNumber) {
        final episodes = season['episodes'] as List?;
        if (episodes == null) return false;
        
        for (final ep in episodes.cast<Map<String, dynamic>>()) {
          if (ep['number'] == epNumber) {
            final completed = ep['completed'];
            return (completed is int && completed > 0) || completed == true;
          }
        }
      }
    }
    return false;
  }
}
