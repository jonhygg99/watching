import 'package:flutter/material.dart';
import 'package:watching/l10n/app_localizations.dart' show AppLocalizations;
import 'package:watching/shared/constants/measures.dart';

class EpisodeInfoRow extends StatelessWidget {
  final int? seasonNumber;
  final int? episodeNumber;
  final String? episodeName;
  final int watchedEpisodes;
  final int totalEpisodes;

  const EpisodeInfoRow({
    super.key,
    required this.seasonNumber,
    required this.episodeNumber,
    required this.episodeName,
    required this.watchedEpisodes,
    required this.totalEpisodes,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (seasonNumber != null &&
                  episodeNumber != null &&
                  watchedEpisodes < totalEpisodes)
                Text(
                  AppLocalizations.of(
                    context,
                  )!.seasonEpisodeFormat(episodeNumber!, seasonNumber!),
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
              const SizedBox(width: kSpaceBtwTitleWidget),
              if (episodeName != null && episodeName!.isNotEmpty)
                Expanded(
                  child: Text(
                    episodeName!,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$watchedEpisodes/$totalEpisodes',
            style: textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
