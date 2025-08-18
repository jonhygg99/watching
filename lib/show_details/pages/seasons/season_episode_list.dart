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

  /// Extract screenshot URL from episode data
  String? _getScreenshotUrl(Map<String, dynamic> episode) {
    // Try the new format first (images object with screenshot array)
    if (episode['images']?['screenshot'] is List &&
        (episode['images']?['screenshot'] as List).isNotEmpty) {
      final screenshot = episode['images']['screenshot'][0];
      if (screenshot is String) {
        return screenshot.startsWith('http') ? screenshot : 'https://$screenshot';
      } else if (screenshot is Map<String, dynamic>) {
        // If it's a map, try to get the full image URL
        return screenshot['full'] ??
            screenshot['medium'] ??
            screenshot['thumb'] ??
            (screenshot.values.isNotEmpty ? screenshot.values.first : null);
      }
    }
    
    // Fall back to the old format if present
    if (episode['screenshot'] is Map<String, dynamic>) {
      final screenshot = episode['screenshot'] as Map<String, dynamic>;
      return screenshot['full'] ?? screenshot['medium'] ?? screenshot['thumb'];
    }
    
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      itemCount: widget.episodes.length,
      itemBuilder: (BuildContext context, int idx) {
        final Map<String, dynamic> ep = widget.episodes[idx];
        final int epNumber = ep['number'] as int;
        final String epTitle = ep['title'] ?? '';
        final bool watched = _epWatched(epNumber);
        final String? imageUrl = _getScreenshotUrl(ep);

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () async {
              // Existing tap handler code
              final epInfo = await _fetchEpisodeInfo(epNumber);
              if (!mounted) return;

              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (sheetContext) {
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
                      // Check if the parent widget is still mounted
                      if (!mounted) return;
                      final currentWatchedState = _epWatched(epNumber);
                      widget.onToggleEpisode(epNumber, !currentWatchedState);
                    },
                  );
                },
              );
            },
            child: SizedBox(
              height: 100,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Episode image on the left
                  if (imageUrl != null)
                    Image.network(
                      imageUrl,
                      width: 150,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            width: 150,
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.tv,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                    )
                  else
                    Container(
                      width: 150,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.tv, size: 40, color: Colors.grey),
                      ),
                    ),

                  // Episode info in the middle
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'T${widget.seasonNumber}E${epNumber.toString().padLeft(2, '0')}',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            epTitle,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w500),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Watch status button on the right
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: IconButton(
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
                        size: 28,
                        color:
                            watched
                                ? (widget.markingColors[epNumber] ??
                                    Colors.green)
                                : (widget.markingColors[epNumber] ??
                                    Colors.grey[400]),
                      ),
                      tooltip:
                          watched
                              ? 'Eliminar episodio del historial'
                              : 'Marcar como visto',
                      onPressed:
                          widget.loading
                              ? null
                              : () =>
                                  widget.onToggleEpisode(epNumber, !watched),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
