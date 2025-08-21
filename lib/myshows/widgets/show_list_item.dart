import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:watching/myshows/widgets/days_bubble.dart';
import 'package:watching/shared/pages/show_details/details_page.dart';
import 'package:watching/myshows/widgets/show_info.dart';
import 'package:watching/myshows/widgets/expanded_episode_item.dart';
import 'package:watching/myshows/widgets/show_poster.dart';
import 'package:watching/api/trakt/show_translation.dart';
import 'package:watching/providers/app_providers.dart';

class ShowListItem extends StatelessWidget {
  final Map<String, dynamic> show;
  final List<Map<String, dynamic>> episodes;
  final bool isExpanded;
  final VoidCallback onToggleExpand;

  const ShowListItem({
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
    final daysUntil = airDate?.difference(DateTime.now()).inDays ?? 0;
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
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                        return ShowInfo(
                          show: translatedShow,
                          isSeasonPremiere: isSeasonPremiere,
                          nextEpisode: nextEpisode,
                          airDate: airDate,
                          episodeCount: episodes.length,
                          isExpanded: isExpanded,
                          onToggleExpand: onToggleExpand,
                        );
                      },
                    );
                  },
                ),
                if (daysUntil >= 0) DaysBubble(days: daysUntil),
              ],
            ),
            if (isExpanded && episodes.length > 1)
              ..._buildExpandedEpisodes(context),
          ],
        ),
      ),
    );
  }

  Widget _buildShowPoster() {
    return ShowPoster(show: show);
  }

  List<Widget> _buildExpandedEpisodes(BuildContext context) {
    return episodes.sublist(1).map((episode) {
      final airDate = DateTime.tryParse(episode['first_aired'] ?? '');
      return ExpandedEpisodeItem(
        episode: episode,
        getEpisodeTitle: getEpisodeTitle,
        airDate: airDate,
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
