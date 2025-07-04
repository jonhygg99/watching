import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../services/trakt/trakt_api.dart';
import '../watchlist/progress_bar.dart';
import 'seasons/season_detail_page.dart';

/// Widget que muestra el progreso por temporada de una serie.
/// Usa hooks y Riverpod para el manejo de estado y side-effects.
class SeasonsProgressWidget extends HookConsumerWidget {
  final String showId;
  final String? languageCode;
  final Function()? onProgressChanged;
  final Function()? onEpisodeWatched;
  final Function()? onWatchlistUpdate;
  const SeasonsProgressWidget({
    super.key,
    required this.showId,
    this.languageCode,
    this.onProgressChanged,
    this.onEpisodeWatched,
    this.onWatchlistUpdate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Estado local con hooks
    final loading = useState(true);
    final seasons = useState<List<dynamic>?>(null);
    final progress = useState<Map<String, dynamic>?>(null);
    final markingColors = useState<Map<int, Color>>({});

    // Instancia de la API (puede ser un provider si lo tienes)
    final traktApi = TraktApi();

    // Efecto para cargar datos al montar el widget o cuando showId cambia
    useEffect(() {
      bool isMounted = true;
      
      Future<void> fetchData() async {
        if (!isMounted) return;
        loading.value = true;
        try {
          final s = await traktApi.getSeasons(showId);
          final p = await traktApi.getShowWatchedProgress(id: showId);
          if (isMounted) {
            seasons.value = s;
            progress.value = p;
          }
        } finally {
          if (isMounted) {
            loading.value = false;
          }
        }
      }

      fetchData();
      return () {
        isMounted = false; // Cleanup function
      };
    }, [showId]);

    // (Eliminada función markSeasonAsWatched: ahora la lógica está integrada en el onPressed del botón)

    if (loading.value) {
      return const Center(child: CircularProgressIndicator());
    }
    if (seasons.value == null || progress.value == null) {
      return const SizedBox();
    }
    final progressSeasons = Map.fromEntries(
      (progress.value!["seasons"] as List).map((s) => MapEntry(s["number"], s)),
    );

    // Filtrar temporadas: ocultar SOLO la temporada 0 (especiales) si tiene 0 episodios.
    // Mostrar SIEMPRE todas las temporadas "reales" aunque tengan 0 episodios.
    // Only hide season 0 (specials) if it has 0 episodes. Show all real seasons, even with 0 episodes.
    final filteredSeasons = List<Map<String, dynamic>>.from(seasons.value!)
      ..removeWhere((season) {
        final number = season["number"];
        final episodeCount = season["episode_count"] ?? 0;
        // Hide only specials (season 0) if empty
        return number == 0 && episodeCount == 0;
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Temporadas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ...filteredSeasons.map<Widget>((season) {
          final number = season["number"];
          final episodeCount = season["episode_count"] ?? 0;
          final seasonProgress = progressSeasons[number] ?? {};
          final completed = seasonProgress["completed"] ?? 0;
          final aired = seasonProgress["aired"] ?? episodeCount;
          final isComplete = completed == aired && aired > 0;
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => SeasonDetailPage(
                        showId: showId,
                        seasonNumber: number,
                        languageCode: languageCode,
                        onEpisodeWatched: () {
                          // Call all callbacks if they exist
                          onEpisodeWatched?.call();
                          onProgressChanged?.call();
                          onWatchlistUpdate?.call();
                        },
                        onWatchlistUpdate: onWatchlistUpdate,
                      ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.check_circle,
                      color:
                          isComplete
                              ? Colors.green
                              : (markingColors.value[number] ?? Colors.grey),
                    ),
                    // If season is complete, pressing removes from history; else, it adds to history
                    onPressed: () async {
                      // Helper for color feedback
                      Future<void> setMarkingColor(
                        Color color, {
                        int delayMs = 0,
                      }) async {
                        markingColors.value = {
                          ...markingColors.value,
                          number: color,
                        };
                        if (delayMs > 0) {
                          await Future.delayed(Duration(milliseconds: delayMs));
                        }
                      }

                      if (isComplete) {
                        // Remove season from history with feedback
                        final prevColor =
                            markingColors.value[number] ?? Colors.green;
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
                          // Refresh data after removal
                          final s = await traktApi.getSeasons(showId);
                          final p = await traktApi.getShowWatchedProgress(
                            id: showId,
                          );
                          seasons.value = s;
                          progress.value = p;
                          if (onProgressChanged != null) onProgressChanged!();
                          // Grey: success (no green)
                          await setMarkingColor(Colors.grey);
                        } catch (e) {
                          await setMarkingColor(
                            Colors.red,
                            delayMs: 500,
                          ); // Red: error
                          await setMarkingColor(
                            prevColor,
                          ); // Restore previous color
                        }
                      } else {
                        // Mark season as watched with feedback
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
                          // Refresh data after marking as watched
                          final s = await traktApi.getSeasons(showId);
                          final p = await traktApi.getShowWatchedProgress(
                            id: showId,
                          );
                          seasons.value = s;
                          progress.value = p;
                          if (onProgressChanged != null) onProgressChanged!();
                          await setMarkingColor(
                            Colors.green,
                            delayMs: 400,
                          ); // Green: success
                          await setMarkingColor(Colors.grey);
                        } catch (e) {
                          await setMarkingColor(
                            Colors.red,
                            delayMs: 500,
                          ); // Red: error
                          await setMarkingColor(Colors.grey);
                        }
                      }
                    },
                    tooltip:
                        isComplete
                            ? 'Eliminar temporada del historial'
                            : 'Marcar temporada como vista',
                  ),
                  Text(
                    'Temporada $number',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ProgressBar(
                      percent:
                          (aired == 0 || completed < 0 || aired < 0)
                              ? 0.0
                              : (completed / aired).clamp(0.0, 1.0),
                      watched: completed,
                      total: aired,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
