import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:watching/pages/myshows/widgets/calendar/show_days_left.dart';
import 'package:watching/shared/constants/measures.dart';
import 'package:watching/shared/pages/show_details/details_page.dart';
import 'package:watching/pages/myshows/widgets/calendar/show_info.dart';
import 'package:watching/pages/myshows/widgets/calendar/show_episodes.dart';
import 'package:watching/pages/myshows/widgets/show_poster.dart';
import 'package:watching/api/trakt/show_translation.dart';
import 'package:watching/providers/app_providers.dart';

class CalendarItem extends StatelessWidget {
  final Map<String, dynamic> show;
  final List<Map<String, dynamic>> episodes;
  final bool isExpanded;
  final VoidCallback onToggleExpand;

  const CalendarItem({
    super.key,
    required this.show,
    required this.episodes,
    required this.isExpanded,
    required this.onToggleExpand,
  });

  @override
  Widget build(BuildContext context) {
    // Get the next airing episode
    final nextEpisode = episodes.isNotEmpty ? episodes[0] : null;
    final airDate =
        nextEpisode != null
            ? DateTime.tryParse(nextEpisode['first_aired'])
            : null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final difference = airDate?.difference(today);
    final days = difference?.inDays ?? 0;

    final isSeasonPremiere = nextEpisode != null && nextEpisode['episode'] == 1;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    ShowDetailPage(showId: show['ids']['trakt'].toString()),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: kSpacePhoneHorizontal,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(12),
            bottom: Radius.circular(12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildShowPoster(),
                const SizedBox(width: 16),
                Consumer(
                  builder: (context, ref, _) {
                    final traktApi = ref.watch(traktApiProvider);
                    final translationService = ref.watch(
                      showTranslationServiceProvider,
                    );

                    return FutureBuilder<String>(
                      future: translationService.getTranslatedTitle(
                        show: show,
                        traktApi: traktApi,
                      ),
                      builder: (context, snapshot) {
                        final translatedShow = Map<String, dynamic>.from(show);
                        if (snapshot.hasData) {
                          translatedShow['title'] = snapshot.data!;
                        }
                        return CalendarShowInfo(
                          show: translatedShow,
                          isSeasonPremiere: isSeasonPremiere,
                          nextEpisode: nextEpisode,
                          airDate: airDate,
                          episodeCount: episodes.length,
                          isExpanded: isExpanded,
                          onToggleExpand: onToggleExpand,
                          days: days,
                        );
                      },
                    );
                  },
                ),
                if (days >= 0) ShowDaysLeft(days: days),
              ],
            ),
            if (episodes.length > 1)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SizeTransition(
                      sizeFactor: animation,
                      axisAlignment: -1.0,
                      child: child,
                    ),
                  );
                },
                child:
                    isExpanded
                        ? Column(
                          key: ValueKey(
                            'expanded_episodes_${show['ids']['trakt']}',
                          ),
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _buildExpandedEpisodes(context, days),
                        )
                        : const SizedBox.shrink(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildShowPoster() {
    return ShowPoster(show: show);
  }

  List<Widget> _buildExpandedEpisodes(BuildContext context, int days) {
    return episodes.sublist(1).map((episode) {
      final airDate = DateTime.tryParse(episode['first_aired'] ?? '');
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: CalendarShowEpisodes(
          episode: episode,
          getEpisodeTitle: getEpisodeTitle,
          airDate: airDate,
          days: days,
        ),
      );
    }).toList();
  }
}

/// Returns 'TBA' if the episode title is null, empty, 'TBA', or exactly 'Episode X' where X is the episode number.
/// Otherwise returns the original title.
String getEpisodeTitle(Map<String, dynamic> episode) {
  final title = episode['title']?.toString().trim();
  if (title == null || title.isEmpty || title == 'TBA') {
    return 'TBA';
  }

  // Check if title is exactly 'Episode X' where X is the episode number
  final episodeNumber = episode['episode']?.toString();
  if (episodeNumber != null && title == 'Episode $episodeNumber') {
    return 'TBA';
  }

  return title;
}
