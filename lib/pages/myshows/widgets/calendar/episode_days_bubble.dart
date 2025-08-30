import 'package:flutter/material.dart';
import 'package:watching/l10n/app_localizations.dart';

class EpisodeDaysBubble extends StatelessWidget {
  const EpisodeDaysBubble({super.key, required this.airDate});

  final DateTime airDate;

  @override
  Widget build(BuildContext context) {
    final days = airDate.difference(DateTime.now()).inDays;
    final isToday = days == 0;
    final text =
        isToday
            ? AppLocalizations.of(context)!.episodeToday
            : AppLocalizations.of(context)!.episodeDaysAway(days);

    return Text(
      text,
      style: TextStyle(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
