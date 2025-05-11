import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../services/trakt/trakt_api.dart';
import '../watchlist/progress_bar.dart';

/// Widget que muestra el progreso por temporada de una serie.
/// Usa hooks y Riverpod para el manejo de estado y side-effects.
class SeasonsProgressWidget extends HookConsumerWidget {
  final String showId;
  final VoidCallback? onProgressChanged;
  const SeasonsProgressWidget({
    super.key,
    required this.showId,
    this.onProgressChanged,
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
      Future<void> fetchData() async {
        loading.value = true;
        try {
          final s = await traktApi.getSeasons(showId);
          final p = await traktApi.getShowWatchedProgress(id: showId);
          seasons.value = s;
          progress.value = p;
        } finally {
          loading.value = false;
        }
      }

      fetchData();
      return null;
    }, [showId]);

    // Función para marcar temporada como vista
    Future<void> markSeasonAsWatched(int seasonNumber, int episodeCount) async {
      markingColors.value = {...markingColors.value, seasonNumber: Colors.blue};
      try {
        await traktApi.addToWatchHistory(
          shows: [
            {
              "ids":
                  int.tryParse(showId) != null
                      ? {"trakt": int.parse(showId)}
                      : {"slug": showId},
              "seasons": [
                {"number": seasonNumber},
              ],
            },
          ],
        );
        // Refresca datos tras marcar como vista
        final s = await traktApi.getSeasons(showId);
        final p = await traktApi.getShowWatchedProgress(id: showId);
        seasons.value = s;
        progress.value = p;
        if (onProgressChanged != null) onProgressChanged!();
        markingColors.value = {
          ...markingColors.value,
          seasonNumber: Colors.grey,
        };
      } catch (e) {
        markingColors.value = {
          ...markingColors.value,
          seasonNumber: Colors.red,
        };
        await Future.delayed(const Duration(milliseconds: 500));
        markingColors.value = {
          ...markingColors.value,
          seasonNumber: Colors.grey,
        };
      }
    }

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
          return Padding(
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
                  onPressed:
                      isComplete
                          ? null
                          : () => markSeasonAsWatched(number, episodeCount),
                  tooltip:
                      isComplete ? 'Completada' : 'Marcar temporada como vista',
                ),
                Text('Temporada $number', style: const TextStyle(fontSize: 16)),
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
          );
        }),
      ],
    );
  }
}
