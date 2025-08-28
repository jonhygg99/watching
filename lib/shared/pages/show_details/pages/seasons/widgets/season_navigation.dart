import 'package:flutter/material.dart';
import 'package:watching/l10n/app_localizations.dart';

class SeasonNavigation extends StatelessWidget {
  final bool hasPreviousSeason;
  final bool hasNextSeason;
  final bool isLoadingSeasons;
  final int seasonNumber;
  final List<Map<String, dynamic>> seasonsList;
  final ValueChanged<int> onSeasonChanged;
  final VoidCallback onPreviousSeason;
  final VoidCallback onNextSeason;

  const SeasonNavigation({
    super.key,
    required this.hasPreviousSeason,
    required this.hasNextSeason,
    required this.isLoadingSeasons,
    required this.seasonNumber,
    required this.seasonsList,
    required this.onSeasonChanged,
    required this.onPreviousSeason,
    required this.onNextSeason,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: hasPreviousSeason ? onPreviousSeason : null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.arrow_back_rounded, size: 16),
                const SizedBox(width: 4),
                Text(AppLocalizations.of(context)!.previousSeason),
              ],
            ),
          ),
          if (isLoadingSeasons)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (seasonsList.isNotEmpty)
            DropdownButton<int>(
              value: seasonNumber,
              items:
                  seasonsList.map<DropdownMenuItem<int>>((season) {
                    return DropdownMenuItem<int>(
                      value: season['number'],
                      child: Text('Season ${season['number']}'),
                    );
                  }).toList(),
              onChanged: (int? newValue) {
                if (newValue != null) {
                  onSeasonChanged(newValue);
                }
              },
            ),
          TextButton(
            onPressed: hasNextSeason ? onNextSeason : null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(AppLocalizations.of(context)!.nextSeason),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_rounded, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
