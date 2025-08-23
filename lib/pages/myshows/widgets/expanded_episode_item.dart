import 'package:flutter/material.dart';
import 'package:watching/l10n/app_localizations.dart';
import 'package:watching/pages/myshows/widgets/episode_days_bubble.dart';
import 'package:watching/shared/utils/dates.dart';

class ExpandedEpisodeItem extends StatelessWidget {
  final Map<String, dynamic> episode;
  final String Function(Map<String, dynamic>) getEpisodeTitle;
  final DateTime? airDate;

  const ExpandedEpisodeItem({
    super.key,
    required this.episode,
    required this.getEpisodeTitle,
    this.airDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withValues(alpha: 0.5),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Season and episode number
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)!.seasonEpisodeFormat(
                      episode['episode'],
                      episode['season'],
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Episode title and air date
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getEpisodeTitle(episode),
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  if (airDate != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${formatDate(airDate!, context)} • ${formatTime(airDate!)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Days bubble if air date is available
            if (airDate != null) EpisodeDaysBubble(airDate: airDate!),
          ],
        ),
      ),
    );
  }
}
