import 'package:flutter/material.dart';
import 'package:watching/watchlist/episode_info_modal/episode_info_modal.dart';
import 'package:watching/api/trakt/trakt_api.dart';

/// Lista modular de episodios de temporada según Windsurf Guidelines.
/// Permite marcar/desmarcar episodios y feedback visual según progreso.

class SeasonEpisodeList extends StatefulWidget {
  final List<Map<String, dynamic>> episodes;
  final Map<String, dynamic>? progress;
  final Map<int, Color> markingColors;
  final bool loading;
  final int seasonNumber;
  final String showId;
  final Map<String, dynamic> showData;
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
    required this.showData,
    required this.languageCode,
    required this.onToggleEpisode,
    required this.setMarkingColor,
  });

  @override
  State<SeasonEpisodeList> createState() => _SeasonEpisodeListState();
}

class _SeasonEpisodeListState extends State<SeasonEpisodeList> {
  // --- Helper to fetch episode info ---
  Future<Map<String, dynamic>?> _fetchEpisodeInfo(int epNumber) async {
    final traktApi = TraktApi();
    try {
      final ep = await traktApi.getEpisodeInfo(
        id: widget.showId,
        season: widget.seasonNumber,
        episode: epNumber,
        language: widget.languageCode,
      );
      return ep;
    } catch (e) {
      return null;
    }
  }

  /// Devuelve true si el episodio con epNumber está visto.
  bool _epWatched(int epNumber) {
    if (widget.progress == null) return false;
    if (widget.progress!['seasons'] == null) return false;
    final seasons = widget.progress!['seasons'] as List;
    for (final season in seasons) {
      if (season['number'] == widget.seasonNumber) {
        final episodes = season['episodes'] as List?;
        if (episodes == null) return false;
        for (final ep in episodes) {
          if (ep['number'] == epNumber) {
            return ep['completed'] == true;
          }
        }
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16.0),
      itemCount: widget.episodes.length,
      itemBuilder: (BuildContext context, int idx) {
        final Map<String, dynamic> ep = widget.episodes[idx];
        final int epNumber = ep['number'] as int;
        final String epTitle = ep['title'] ?? '';
        final bool watched = _epWatched(epNumber);
        return ListTile(
          leading: CircleAvatar(child: Text('$epNumber')),
          title: Text(epTitle),
          trailing: IconButton(
            onLongPress: () {
              final newWatchedState = !watched;
              widget.onToggleEpisode(epNumber, newWatchedState);
              widget.setMarkingColor(
                epNumber,
                newWatchedState ? Colors.green : Colors.red,
                delayMs: 500,
              );
            },
            icon: Icon(
              Icons.check_circle,
              color:
                  watched
                      ? (widget.markingColors[epNumber] ?? Colors.green)
                      : (widget.markingColors[epNumber] ?? Colors.grey),
            ),
            tooltip:
                watched
                    ? 'Eliminar episodio del historial'
                    : 'Marcar como visto',
            onPressed:
                widget.loading
                    ? null
                    : () => widget.onToggleEpisode(epNumber, !watched),
          ),
          onTap: () async {
            // Espera a que la info esté lista antes de mostrar el modal
            final epInfo = await _fetchEpisodeInfo(epNumber);
            if (!mounted) return;

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
                return EpisodeInfoModal(
                  episodeFuture: Future.value(epInfo),
                  showData: widget.showData,
                  seasonNumber: widget.seasonNumber,
                  episodeNumber: epNumber,
                  onWatchedStatusChanged: () {
                    // Trigger a refresh of the parent component with the new watched state
                    final currentWatchedState = _epWatched(epNumber);
                    widget.onToggleEpisode(epNumber, !currentWatchedState);
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
