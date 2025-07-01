import 'package:flutter/material.dart';
import '../../watchlist/episode_info_modal.dart';
import '../../../services/trakt/trakt_api.dart';

/// Lista modular de episodios de temporada según Windsurf Guidelines.
/// Permite marcar/desmarcar episodios y feedback visual según progreso.

class SeasonEpisodeList extends StatelessWidget {
  // --- Nuevo helper para obtener info del episodio ---
  Future<Map<String, dynamic>?> _fetchEpisodeInfo(int epNumber) async {
    final traktApi = TraktApi();
    try {
      final ep = await traktApi.getEpisodeInfo(
        id: showId,
        season: seasonNumber,
        episode: epNumber,
      );
      return ep;
    } catch (e) {
      return null;
    }
  }

  final List<Map<String, dynamic>> episodes;
  final Map<String, dynamic>? progress;
  final Map<int, Color> markingColors;
  final bool loading;
  final int seasonNumber;
  final String showId;
  final String? languageCode;
  final Future<void> Function(int epNumber, bool watched) onToggleEpisode;
  final void Function(int epNumber, Color color, {int delayMs}) setMarkingColor;

  const SeasonEpisodeList({
    super.key,
    required this.episodes,
    required this.progress,
    required this.markingColors,
    required this.loading,
    required this.seasonNumber,
    required this.showId,
    required this.languageCode,
    required this.onToggleEpisode,
    required this.setMarkingColor,
  });

  /// Devuelve true si el episodio está visto según la estructura de progreso.
  bool _isEpisodeWatched(Map<String, dynamic> e) {
    final dynamic completed = e["completed"];
    if (completed is int) return completed > 0;
    if (completed is bool) return completed;
    return false;
  }

  /// Devuelve true si el episodio con epNumber está visto.
  bool _epWatched(int epNumber) {
    final List<dynamic>? seasons = progress?["seasons"] as List<dynamic>?;
    final Map<String, dynamic>? season = seasons
        ?.cast<Map<String, dynamic>>()
        .firstWhere((s) => s["number"] == seasonNumber, orElse: () => {});
    if (season == null || season.isEmpty || season["episodes"] is! List) {
      return false;
    }
    return (season["episodes"] as List).any(
      (e) =>
          e["number"] == epNumber &&
          _isEpisodeWatched(Map<String, dynamic>.from(e)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: episodes.length,
      itemBuilder: (BuildContext context, int idx) {
        final Map<String, dynamic> ep = episodes[idx];
        final int epNumber = ep['number'] as int;
        final String epTitle = ep['title'] ?? '';
        final bool watched = _epWatched(epNumber);
        return ListTile(
          leading: CircleAvatar(child: Text('$epNumber')),
          title: Text(epTitle),
          trailing: IconButton(
            icon: Icon(
              Icons.check_circle,
              color:
                  watched
                      ? (markingColors[epNumber] ?? Colors.green)
                      : (markingColors[epNumber] ?? Colors.grey),
            ),
            tooltip:
                watched
                    ? 'Eliminar episodio del historial'
                    : 'Marcar como visto',
            onPressed:
                loading ? null : () => onToggleEpisode(epNumber, watched),
          ),
          onTap: () async {
            // Espera a que la info esté lista antes de mostrar el modal
            final epInfo = await _fetchEpisodeInfo(epNumber);
            // TODO: Manejar el caso de que el contexto ya no esté montado
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              builder: (_) {
                if (epInfo == null) {
                  return const Center(
                    child: Text('No hay información del episodio.'),
                  );
                }
                return EpisodeInfoModal(episodeFuture: Future.value(epInfo));
              },
            );
          },
        );
      },
    );
  }
}
