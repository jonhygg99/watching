import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class EpisodeDaysBubble extends StatelessWidget {
  const EpisodeDaysBubble({super.key, required this.airDate});

  final DateTime airDate;

  @override
  Widget build(BuildContext context) {
    final days = airDate.difference(DateTime.now()).inDays;
    final isToday = days == 0;
    final isPast = days < 0;
    final text =
        isPast
            ? AppLocalizations.of(context)!.episodeAired
            : isToday
            ? AppLocalizations.of(context)!.episodeToday
            : AppLocalizations.of(context)!.episodeDaysAway(days);

    return Container(
      width: 70, // Fixed width for better alignment
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color:
            isPast
                ? Colors.grey[700]
                : isToday
                ? Colors.green[700]
                : const Color(0xFF6A1B9A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
