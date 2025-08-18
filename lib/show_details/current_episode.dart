import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:watching/api/trakt/trakt_api.dart';
import 'package:watching/shared/constants/colors.dart';
import 'package:watching/shared/widgets/tiny_progress_bar.dart';
import 'package:watching/show_details/pages/seasons/season_detail_page.dart';
import 'package:watching/show_details/widgets/skeleton/widgets/skeleton_episode.dart';
import 'package:watching/watchlist/episode_info_modal/episode_info_modal.dart';

/// A widget that displays the current episode information and progress for a show.

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

  /// Find the last season number from progress data
  int _findLastSeason(Map<String, dynamic>? progress) {
    try {
      if (progress == null) return 1;

      final seasons = progress['seasons'] as List<dynamic>?;
      if (seasons == null || seasons.isEmpty) return 1;

      // Find the maximum season number
      int maxSeason = 1;
      for (final season in seasons) {
        final seasonNumber = (season['number'] as int?) ?? 0;
        if (seasonNumber > maxSeason) {
          maxSeason = seasonNumber;
        }
      }
      return maxSeason;
    } catch (e) {
      debugPrint('Error finding last season: $e');
      return 1;
    }
  }

  /// Find the next episode to watch based on the show's progress
  /// Returns the next episode or null if all episodes are watched
  Map<String, dynamic>? _findNextEpisode(Map<String, dynamic>? progress) {
    try {
      if (progress == null) return null;

      // First check if we have a next_episode from the API
      final nextEpisode = progress['next_episode'];
      if (nextEpisode != null) return nextEpisode;

      // If no next_episode, try to find the first unwatched episode
      final seasons = progress['seasons'] as List<dynamic>?;
      if (seasons == null) return null;

      for (final season in seasons) {
        final episodes = season['episodes'] as List<dynamic>?;
        if (episodes == null) continue;

        for (final episode in episodes) {
          final completed = episode['completed'] as bool? ?? false;
          if (!completed) {
            return {
              'season': season['number'],
              'number': episode['number'],
              'title': episode['title'],
            };
          }
        }
      }

      return null; // All episodes watched
    } catch (e) {
      debugPrint('Error finding next episode: $e');
      return null;
    }
  }

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

      final episode = episodes.firstWhere(
        (e) => e['number'] == episodeNumber,
        orElse: () => null,
      );
      return episode?['title'] as String?;
    } catch (e) {
      debugPrint('Error fetching translated episode name: $e');
    }
    return null;
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
        final nextEpisode = _findNextEpisode(progressData);
        if (nextEpisode != null) {
          final seasonNumber = nextEpisode['season'] as int?;
          final episodeNumber = nextEpisode['number'] as int?;

          // Only fetch translation if not already loaded
          if (seasonNumber != null &&
              episodeNumber != null &&
              !translatedEpisodeName.value.containsKey(
                'S${seasonNumber}E$episodeNumber',
              )) {
            final translatedName = await _getTranslatedEpisodeName(
              trakt,
              seasonNumber,
              episodeNumber,
              effectiveLanguageCode,
            );

            if (translatedName != null && context.mounted) {
              translatedEpisodeName.value = {
                ...translatedEpisodeName.value,
                'S${seasonNumber}E$episodeNumber': translatedName,
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
          'Error loading progress: ${error.value}',
          style: textTheme.bodyMedium?.copyWith(color: Colors.red),
        ),
      );
    }

    final progressData = progress.value;
    if (progressData == null) {
      return const SizedBox.shrink();
    }

    final nextEpisode = _findNextEpisode(progressData);
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
          'Episodio $episodeNumber';

      return _buildEpisodeInfo(
        context: context,
        seasonNumber: seasonNumber,
        episodeNumber: episodeNumber,
        episodeName: episodeName,
        watchedEpisodes: watched,
        totalEpisodes: total,
        progressPercent: total > 0 ? (watched / total).clamp(0.0, 1.0) : 0.0,
        onRefreshProgress: refreshProgress,
        progressData: progressData,
        nextEpisode: nextEpisode,
      );
    } else if (total > 0) {
      // Show progress for completed shows
      return _buildEpisodeInfo(
        context: context,
        seasonNumber: 1,
        episodeNumber: 1,
        episodeName: 'All episodes watched',
        watchedEpisodes: watched,
        totalEpisodes: total,
        progressPercent: 1.0,
        onRefreshProgress: refreshProgress,
        progressData: progressData,
        nextEpisode: null,
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildEpisodeInfo({
    required BuildContext context,
    required int? seasonNumber,
    required int? episodeNumber,
    required String? episodeName,
    required int watchedEpisodes,
    required int totalEpisodes,
    required double progressPercent,
    required VoidCallback onRefreshProgress,
    required Map<String, dynamic>? progressData,
    Map<String, dynamic>? nextEpisode,
  }) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final trakt = TraktApi();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Episode info row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Season and episode info
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (seasonNumber != null &&
                            episodeNumber != null &&
                            watchedEpisodes < totalEpisodes)
                          Text(
                            'T$seasonNumber:E$episodeNumber ',
                            style: textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        if (episodeName != null && episodeName.isNotEmpty)
                          Expanded(
                            child: Text(
                              episodeName,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Watched/total episodes
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$watchedEpisodes/$totalEpisodes',
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Progress bar
        TinyProgressBar(
          percent: progressPercent,
          watched: watchedEpisodes,
          total: totalEpisodes,
        ),

        const SizedBox(height: 16),

        // Action buttons
        Row(
          children: [
            // Check Out All Episodes button - full width when all episodes are watched
            Expanded(
              child: Padding(
                padding:
                    nextEpisode == null
                        ? EdgeInsets.zero
                        : const EdgeInsets.only(right: 4.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [kGradientLightColor, kGradientDarkColor],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: FilledButton.icon(
                    onPressed: () {
                      if (showData != null) {
                        // If we have a next episode, use its season
                        // Otherwise, find the last available season
                        final currentSeason =
                            nextEpisode != null
                                ? nextEpisode['season'] as int? ?? 1
                                : _findLastSeason(progressData);

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
                    label: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        'Check Out All Episodes',
                        style: TextStyle(
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

            // Episode Info button - only show if there are unwatched episodes
            if (nextEpisode != null) ...[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD6C498), Color(0xFF966D39)],
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
                                    season: seasonNumber,
                                    episode: episodeNumber,
                                    language: languageCode,
                                  ),
                                  showData: showData!,
                                  seasonNumber: seasonNumber,
                                  episodeNumber: episodeNumber,
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
                      label: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          'Episode Info',
                          style: TextStyle(
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
        ),
      ],
    );
  }
}
