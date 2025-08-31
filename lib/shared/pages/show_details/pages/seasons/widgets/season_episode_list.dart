import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:watching/l10n/app_localizations.dart';
import 'package:watching/shared/constants/measures.dart';
import 'package:watching/shared/utils/get_image.dart';
import 'package:watching/shared/widgets/episode_info_modal/episode_info_modal.dart';
import 'package:watching/api/trakt/trakt_api.dart';
import '../models/episode_state.dart';

/// Lista modular de episodios de temporada según Windsurf Guidelines.
/// Permite marcar/desmarcar episodios y feedback visual según progreso.

class SeasonEpisodeList extends StatefulWidget {
  final List<Map<String, dynamic>> episodes;
  final Map<String, dynamic>? progress;
  final Map<int, Color> markingColors;
  final Map<int, bool> loadingEpisodes;
  final Map<int, EpisodeState>? episodeStates;
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
    required this.loadingEpisodes,
    required this.seasonNumber,
    required this.showId,
    required this.showData,
    required this.languageCode,
    required this.onToggleEpisode,
    required this.setMarkingColor,
    this.episodeStates,
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

  /// Returns the current state of an episode, considering both the server state and local UI state
  EpisodeState _getEpisodeState(int epNumber) {
    // First check if we have a local UI state for this episode
    if (widget.episodeStates != null && widget.episodeStates!.containsKey(epNumber)) {
      return widget.episodeStates![epNumber]!;
    }
    
    // Fall back to server state if no local UI state
    if (widget.progress == null) return EpisodeState.unwatched;
    if (widget.progress!['seasons'] == null) return EpisodeState.unwatched;
    
    final seasons = widget.progress!['seasons'] as List;
    for (final season in seasons) {
      if (season['number'] == widget.seasonNumber) {
        final episodes = season['episodes'] as List?;
        if (episodes == null) return EpisodeState.unwatched;
        for (final ep in episodes) {
          if (ep['number'] == epNumber) {
            return (ep['completed'] == true) 
                ? EpisodeState.watched 
                : EpisodeState.unwatched;
          }
        }
      }
    }
    return EpisodeState.unwatched;
  }

  Widget _buildWatchButton(int epNumber, EpisodeState state) {
    return IconButton(
      onPressed: state.isProcessing 
          ? null 
          : () async {
              await widget.onToggleEpisode(epNumber, !state.isWatched);
            },
      icon: state.isProcessing
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            )
          : Icon(
              state.isWatched ? Icons.check_circle : Icons.circle_outlined,
              size: 28,
              color: state.isProcessing 
                  ? Colors.blue 
                  : state.isWatched 
                      ? Colors.green 
                      : Colors.grey[400],
            ),
      tooltip: state.isProcessing
          ? ''
          : (state.isWatched
              ? AppLocalizations.of(context)!.removeFromHistory
              : AppLocalizations.of(context)!.markAsWatched),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(
        left: kSpacePhoneHorizontal,
        right: kSpacePhoneHorizontal,
        top: 10,
        bottom: 30,
      ),
      itemCount: widget.episodes.length,
      itemBuilder: (BuildContext context, int idx) {
        final Map<String, dynamic> ep = widget.episodes[idx];
        final int epNumber = ep['number'] as int;
        final String epTitle = ep['title'] ?? '';
        final episodeState = _getEpisodeState(epNumber);
        final String? imageUrl = getScreenshotUrl(ep);

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 5.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () async {
              final epInfo = await _fetchEpisodeInfo(epNumber);
              if (!mounted) return;
              
              await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => EpisodeInfoModal(
                  episodeFuture: Future.value(epInfo ?? ep),
                  showData: widget.showData,
                  seasonNumber: widget.seasonNumber,
                  episodeNumber: epNumber,
                  onWatchedStatusChanged: (isWatched) async {
                    // Toggle the episode watched status
                    await widget.onToggleEpisode(epNumber, isWatched);
                    // Refresh the UI
                    if (mounted) setState(() {});
                  },
                ),
              );
              
              // Refresh the episode list after the modal is closed
              if (mounted) setState(() {});
            },
            child: Row(
              children: [
                // Episode thumbnail
                if (imageUrl != null)
                  CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 100,
                    height: 70,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Container(
                      width: 100,
                      height: 70,
                      color: Colors.grey[300],
                      child: const Icon(Icons.error_outline),
                    ),
                  )
                else
                  Container(
                    width: 100,
                    height: 70,
                    color: Colors.grey[200],
                    child: const Icon(Icons.tv, size: 30, color: Colors.grey),
                  ),

                // Episode info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 8.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Episode $epNumber',
                          style: Theme.of(context).textTheme.bodySmall,
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
                  child: _buildWatchButton(epNumber, episodeState),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
