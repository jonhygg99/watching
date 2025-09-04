import 'package:flutter/material.dart';
import 'package:watching/api/trakt/trakt_api.dart';
import 'package:watching/l10n/app_localizations.dart' show AppLocalizations;
import 'package:watching/shared/constants/colors.dart';
import 'package:watching/shared/models/show_summary_model.dart';
import 'package:watching/shared/pages/show_details/pages/seasons/season_detail_page.dart';
import 'package:watching/shared/pages/show_details/widgets/current_episode/widgets/episode_helpers.dart';
import 'package:watching/shared/widgets/episode_info_modal/episode_info_modal.dart';

class ActionButtons extends StatelessWidget {
  final Map<String, dynamic>? nextEpisode;
  final ShowSummary showData;
  final String traktId;
  final String? languageCode;
  final VoidCallback? onWatchedStatusChanged;
  final VoidCallback onRefreshProgress;
  final int? seasonNumber;
  final int? episodeNumber;
  final Map<String, dynamic>? progressData;
  final VoidCallback? onEpisodeWatched;

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
    this.onEpisodeWatched,
  });

  @override
  Widget build(BuildContext context) {
    final trakt = TraktApi();

    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: nextEpisode == null
                ? EdgeInsets.zero
                : const EdgeInsets.only(right: 4.0),
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
                  if (showData != null) {
                    final currentSeason = nextEpisode != null
                        ? nextEpisode!['season'] as int? ?? 1
                        : findLastSeason(progressData);

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SeasonDetailPage(
                          seasonNumber: currentSeason,
                          showId: traktId,
                          showData: showData!,
                          languageCode: languageCode,
                          onEpisodeWatched: onEpisodeWatched,
                        ),
                      ),
                    );
                  }
                },
                label: Text(
                  AppLocalizations.of(context)!.checkOutAllEpisodes,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.visible,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    height: 1.1,
                  ),
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                        : [
                            kGradientLightColorLight,
                            kGradientDarkColorLight,
                          ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FilledButton.icon(
                  onPressed: () {
                    if (seasonNumber != null && episodeNumber != null) {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        useSafeArea: true,
                        builder: (context) => EpisodeInfoModal(
                          episodeFuture: trakt.getEpisodeInfo(
                            id: traktId,
                            season: seasonNumber!,
                            episode: episodeNumber!,
                            language: languageCode,
                          ),
                          showData: showData!,
                          seasonNumber: seasonNumber!,
                          episodeNumber: episodeNumber!,
                          onWatchedStatusChanged: (_) {
                            onRefreshProgress();
                            if (context.mounted) {
                              onWatchedStatusChanged?.call();
                            }
                          },
                        ),
                      );
                    }
                  },
                  label: Text(
                    AppLocalizations.of(context)!.episodeInfo,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.visible,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      height: 1.1,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
