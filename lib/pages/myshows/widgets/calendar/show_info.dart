import 'package:flutter/material.dart';
import 'package:watching/l10n/app_localizations.dart';
import 'show_more_button.dart';
import 'package:watching/shared/utils/dates.dart';

class CalendarShowInfo extends StatelessWidget {
  final Map<String, dynamic> show;
  final bool isSeasonPremiere;
  final Map<String, dynamic>? nextEpisode;
  final DateTime? airDate;
  final int episodeCount;
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final int days;

  const CalendarShowInfo({
    super.key,
    required this.show,
    required this.isSeasonPremiere,
    required this.nextEpisode,
    required this.airDate,
    required this.episodeCount,
    required this.isExpanded,
    required this.onToggleExpand,
    required this.days,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._buildDateIndicator(context),
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
            ShowMoreButton(
              isExpanded: isExpanded,
              episodeCount: episodeCount,
              onToggleExpand: onToggleExpand,
            ),
        ],
      ),
    );
  }

  List<Widget> _buildDateIndicator(BuildContext context) {
    String text;
    final l10n = AppLocalizations.of(context)!;

    if (days == 0) {
      text = l10n.today;
    } else if (days == 1) {
      text = l10n.tomorrow;
    } else if (days > 1 && days <= 7) {
      text = l10n.thisWeek;
    } else if (days > 7 && days <= 30) {
      final weeks = (days / 7).floor();
      text = weeks == 1 ? l10n.inAWeek : l10n.inNWeeks(weeks);
    } else if (days > 30 && days <= 365) {
      final months = (days / 30).floor();
      text = months == 1 ? l10n.inAMonth : l10n.inNMonths(months);
    } else {
      final years = (days / 365).floor();
      text = years == 1 ? l10n.inAYear : l10n.inNYears(years);
    }

    return [
      Text(
        text.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 0.5,
        ),
      ),
      const SizedBox(height: 2),
    ];
  }
}
