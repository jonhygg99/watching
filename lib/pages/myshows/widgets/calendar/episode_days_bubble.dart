import 'package:flutter/material.dart';
import 'package:watching/l10n/app_localizations.dart';

class EpisodeDaysBubble extends StatelessWidget {
  const EpisodeDaysBubble({super.key, required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    final isToday = days == 0;
    final isTomorrow = days == 1;
    final text =
        isToday
            ? AppLocalizations.of(context)!.episodeToday
            : isTomorrow
            ? AppLocalizations.of(context)!.tomorrow
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
