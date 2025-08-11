import 'package:flutter/material.dart';

class ShowInfo extends StatelessWidget {
  final Map<String, dynamic> show;
  final bool isSeasonPremiere;
  final Map<String, dynamic>? nextEpisode;
  final DateTime? airDate;
  final int episodeCount;
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final String Function(DateTime) formatDate;
  final String Function(DateTime) formatTime;

  const ShowInfo({
    super.key,
    required this.show,
    required this.isSeasonPremiere,
    required this.nextEpisode,
    required this.airDate,
    required this.episodeCount,
    required this.isExpanded,
    required this.onToggleExpand,
    required this.formatDate,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            show['title']?.toString() ?? 'Unknown Show',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            isSeasonPremiere
                ? 'Season Premiere'
                : 'S${nextEpisode?['season'].toString().padLeft(2, '0')} • E${nextEpisode?['episode'].toString().padLeft(2, '0')}',
          ),
          const SizedBox(height: 4),
          if (airDate != null)
            Text(
              '${formatDate(airDate!)} • ${formatTime(airDate!)}',
            ),
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
                    ? 'Hide episodes'
                    : 'Show ${episodeCount - 1} more episodes',
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
