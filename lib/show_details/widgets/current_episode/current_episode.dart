import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:watching/api/trakt/trakt_api.dart';
import 'package:watching/l10n/app_localizations.dart' show AppLocalizations;
import 'package:watching/shared/constants/colors.dart';
import 'package:watching/show_details/widgets/current_episode/widgets/current_episode_details.dart';
import 'package:watching/show_details/widgets/current_episode/widgets/episode_helpers.dart';
import 'package:watching/show_details/widgets/skeleton/widgets/skeleton_episode.dart';

/// A widget that displays the current episode information and progress for a show.
///
/// Displays the current episode information including season, episode number,
/// translated name, and watch progress.
class CurrentEpisode extends HookWidget {
  final String traktId;
  final String? title;
  final String? languageCode;
  final Map<String, dynamic>? showData;
  final VoidCallback? onWatchedStatusChanged;

  const CurrentEpisode({
    super.key,
    required this.traktId,
    this.title,
    this.languageCode,
    this.showData,
    this.onWatchedStatusChanged,
  });

  /// Fetches the translated episode name
  Future<String?> _getTranslatedEpisodeName(
    TraktApi trakt,
    int seasonNumber,
    int episodeNumber,
    String? languageCode,
  ) async {
    if (languageCode == null) return null;

    try {
      final episodes = await trakt.getSeasonEpisodes(
        id: traktId,
        season: seasonNumber,
        translations: languageCode,
      );

      // Find the episode by number
      final episode = episodes.firstWhere(
        (e) => (e['number'] as int?) == episodeNumber,
        orElse: () => <String, dynamic>{},
      );

      // Check if we have translations
      if (episode.containsKey('translations') &&
          episode['translations'] is List) {
        final translations = episode['translations'] as List;
        if (translations.isNotEmpty) {
          return translations.first['title'] as String?;
        }
      }

      // Fall back to the default title if no translation is found
      return episode['title'] as String?;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final locale = Localizations.localeOf(context);
    final effectiveLanguageCode = languageCode ?? locale.languageCode;
    final trakt = TraktApi();

    // State variables
    final progress = useState<Map<String, dynamic>?>(null);
    final isLoading = useState(true);
    final error = useState<String?>(null);
    final translatedEpisodeName = useState<Map<String, String>>({});

    // Create a callback for refreshing progress that can be used throughout the widget
    final refreshProgress = useCallback(() async {
      try {
        final progressData = await trakt.getShowWatchedProgress(id: traktId);
        if (!context.mounted) return;

        progress.value = progressData;

        // Find the next episode to get translated name
        final nextEpisode = findNextEpisode(progressData);
        if (nextEpisode != null) {
          final seasonNumber = nextEpisode['season'] as int?;
          final episodeNumber = nextEpisode['number'] as int?;

          // Only fetch translation if not already loaded
          if (seasonNumber != null &&
              episodeNumber != null &&
              !translatedEpisodeName.value.containsKey(
                AppLocalizations.of(
                  context,
                )!.seasonEpisodeFormat(seasonNumber, episodeNumber),
              )) {
            final translatedName = await _getTranslatedEpisodeName(
              trakt,
              seasonNumber,
              episodeNumber,
              effectiveLanguageCode,
            );

            if (translatedName != null && context.mounted) {
              // Use the same key format as used in the lookup
              final episodeKey = 'S${seasonNumber}E$episodeNumber';
              translatedEpisodeName.value = {
                ...translatedEpisodeName.value,
                episodeKey: translatedName,
              };
            }
          }
        }

        isLoading.value = false;
      } catch (e) {
        if (context.mounted) {
          error.value = e.toString();
          isLoading.value = false;
        }
      }
    }, [traktId, effectiveLanguageCode]);

    // Initial load
    useEffect(() {
      refreshProgress();
      return () {};
    }, [refreshProgress]);

    if (isLoading.value) {
      return const SkeletonEpisode();
    }

    if (error.value != null) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.errorLoadingData,
          style: textTheme.bodyMedium?.copyWith(color: kErrorColorMessage),
        ),
      );
    }

    final progressData = progress.value;
    if (progressData == null) {
      return const SizedBox.shrink();
    }

    final nextEpisode = findNextEpisode(progressData);
    final watched = progressData['completed'] as int? ?? 0;
    final total = progressData['aired'] as int? ?? 0;

    if (nextEpisode != null) {
      final seasonNumber = nextEpisode['season'] as int;
      final episodeNumber = nextEpisode['number'] as int;
      final episodeKey = 'S${seasonNumber}E$episodeNumber';

      // Use translated name if available, fallback to original
      final episodeName =
          translatedEpisodeName.value[episodeKey] ??
          nextEpisode['title'] ??
          AppLocalizations.of(context)!.episodeNumber(episodeNumber);

      return CurrentEpisodeDetails(
        seasonNumber: seasonNumber,
        episodeNumber: episodeNumber,
        episodeName: episodeName,
        watchedEpisodes: watched,
        totalEpisodes: total,
        progressPercent: total > 0 ? (watched / total).clamp(0.0, 1.0) : 0.0,
        onRefreshProgress: refreshProgress,
        progressData: progressData,
        nextEpisode: nextEpisode,
        showData: showData,
        traktId: traktId,
        languageCode: languageCode,
        onWatchedStatusChanged: onWatchedStatusChanged,
      );
    } else if (total > 0) {
      // Show progress for completed shows
      return CurrentEpisodeDetails(
        seasonNumber: null,
        episodeNumber: null,
        episodeName: AppLocalizations.of(context)!.allEpisodesWatched,
        watchedEpisodes: watched,
        totalEpisodes: total,
        progressPercent: 1.0,
        onRefreshProgress: refreshProgress,
        progressData: progressData,
        nextEpisode: null,
        showData: showData,
        traktId: traktId,
        languageCode: languageCode,
        onWatchedStatusChanged: onWatchedStatusChanged,
      );
    }

    return const SizedBox.shrink();
  }
}
