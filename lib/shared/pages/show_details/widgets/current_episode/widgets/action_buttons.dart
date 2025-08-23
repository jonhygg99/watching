import 'package:flutter/material.dart';
import 'package:watching/api/trakt/trakt_api.dart';
import 'package:watching/l10n/app_localizations.dart' show AppLocalizations;
import 'package:watching/shared/constants/colors.dart';
import 'package:watching/shared/pages/show_details/pages/seasons/season_detail_page.dart';
import 'package:watching/shared/pages/show_details/widgets/current_episode/widgets/episode_helpers.dart';
import 'package:watching/shared/widgets/episode_info_modal/episode_info_modal.dart';

class ActionButtons extends StatelessWidget {
  final Map<String, dynamic>? nextEpisode;
  final Map<String, dynamic>? showData;
  final String traktId;
  final String? languageCode;
  final VoidCallback? onWatchedStatusChanged;
  final VoidCallback onRefreshProgress;
  final int? seasonNumber;
  final int? episodeNumber;
  final Map<String, dynamic>? progressData;

  const ActionButtons({
    super.key,
    required this.nextEpisode,
    required this.showData,
    required this.traktId,
    required this.languageCode,
    required this.onWatchedStatusChanged,
    required this.onRefreshProgress,
    required this.seasonNumber,
    required this.episodeNumber,
    required this.progressData,
  });

  @override
  Widget build(BuildContext context) {
    final trakt = TraktApi();

    return Row(
      children: [
        Expanded(
          child: Padding(
            padding:
                nextEpisode == null
                    ? EdgeInsets.zero
                    : const EdgeInsets.only(right: 4.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors:
                      Theme.of(context).brightness == Brightness.dark
                          ? [kGradientLightColor, kGradientDarkColor]
                          : [kGradientLightColorLight, kGradientDarkColorLight],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: FilledButton.icon(
                onPressed: () {
                  if (showData != null) {
                    final currentSeason =
                        nextEpisode != null
                            ? nextEpisode!['season'] as int? ?? 1
                            : findLastSeason(progressData);

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (context) => SeasonDetailPage(
                              seasonNumber: currentSeason,
                              showId: traktId,
                              showData: showData!,
                              languageCode: languageCode,
                              onEpisodeWatched: onWatchedStatusChanged,
                            ),
                      ),
                    );
                  }
                },
                label: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    AppLocalizations.of(context)!.checkOutAllEpisodes,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (nextEpisode != null) ...[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: Theme.of(context).brightness == Brightness.dark
                        ? [kGradientLightColor, kGradientDarkColor]
                        : [kGradientLightColorLight, kGradientDarkColorLight],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FilledButton.icon(
                  onPressed: () {
                    if (seasonNumber != null &&
                        episodeNumber != null &&
                        showData != null) {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        useSafeArea: true,
                        builder:
                            (context) => EpisodeInfoModal(
                              episodeFuture: trakt.getEpisodeInfo(
                                id: traktId,
                                season: seasonNumber!,
                                episode: episodeNumber!,
                                language: languageCode,
                              ),
                              showData: showData!,
                              seasonNumber: seasonNumber!,
                              episodeNumber: episodeNumber!,
                              onWatchedStatusChanged: () {
                                onRefreshProgress();
                                if (context.mounted) {
                                  onWatchedStatusChanged?.call();
                                }
                              },
                            ),
                      );
                    }
                  },
                  label: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      AppLocalizations.of(context)!.episodeInfo,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
