import 'package:flutter/material.dart';
import 'package:watching/l10n/app_localizations.dart';
import '../../../shared/utils/dates.dart';

class ShowInfo extends StatelessWidget {
  final Map<String, dynamic> show;
  final bool isSeasonPremiere;
  final Map<String, dynamic>? nextEpisode;
  final DateTime? airDate;
  final int episodeCount;
  final bool isExpanded;
  final VoidCallback onToggleExpand;

  const ShowInfo({
    super.key,
    required this.show,
    required this.isSeasonPremiere,
    required this.nextEpisode,
    required this.airDate,
    required this.episodeCount,
    required this.isExpanded,
    required this.onToggleExpand,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            show['title']?.toString() ?? 'Unknown Show',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            isSeasonPremiere
                ? AppLocalizations.of(context)!.seasonPremiere
                : AppLocalizations.of(context)!.seasonEpisodeFormat(
                  nextEpisode?['episode'],
                  nextEpisode?['season'],
                ),
          ),
          const SizedBox(height: 4),
          if (airDate != null)
            Text('${formatDate(airDate!, context)} • ${formatTime(airDate!)}'),
          if (episodeCount > 1)
            TextButton(
              onPressed: onToggleExpand,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                isExpanded
                    ? AppLocalizations.of(context)!.hideEpisodes
                    : AppLocalizations.of(
                      context,
                    )!.showMoreEpisodes(episodeCount - 1),
                style: const TextStyle(
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
