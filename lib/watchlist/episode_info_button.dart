import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:watching/watchlist/episode_info_modal/episode_info_modal.dart';
import 'package:watching/services/trakt/trakt_api.dart';
import 'package:watching/providers/app_providers.dart';

/// A button that shows episode information in a modal
class EpisodeInfoButton extends HookConsumerWidget {
  final String? traktId;
  final int season;
  final int episode;
  final TraktApi apiService;
  final String? countryCode;
  final Map<String, dynamic> showData;

  const EpisodeInfoButton({
    super.key,
    required this.traktId,
    required this.season,
    required this.episode,
    required this.apiService,
    required this.showData,
    this.countryCode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countryCodeState = ref.watch(countryCodeProvider);
    final effectiveCountryCode = countryCode ?? countryCodeState;
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
                        language: effectiveCountryCode.toLowerCase(),
                      ),
                      showData: showData,
                      seasonNumber: season,
                      episodeNumber: episode,
                    );
                  },
                );
              },
    );
  }
}
