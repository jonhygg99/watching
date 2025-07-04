import 'package:flutter/material.dart';
import 'package:watching/watchlist/episode_info_modal.dart';
import 'package:watching/services/trakt/trakt_api.dart';

class EpisodeInfoButton extends StatelessWidget {
  final String? traktId;
  final int season;
  final int episode;
  final TraktApi apiService;

  const EpisodeInfoButton({
    super.key,
    required this.traktId,
    required this.season,
    required this.episode,
    required this.apiService,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      icon: const Icon(Icons.info_outline),
      label: const Text('Episode Info'),
      onPressed:
          traktId == null
              ? null
              : () async {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  builder: (ctx) {
                    return EpisodeInfoModal(
                      episodeFuture: apiService.getEpisodeInfo(
                        id: traktId!,
                        season: season,
                        episode: episode,
                        language: 'es', // Using Spanish as default
                      ),
                    );
                  },
                );
              },
    );
  }
}
