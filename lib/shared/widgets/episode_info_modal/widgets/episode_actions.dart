import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:watching/pages/watchlist/state/watchlist_notifier.dart';
import 'package:watching/l10n/app_localizations.dart';
import 'package:watching/shared/models/show_summary_model.dart';
import 'star_rating.dart';

class EpisodeActions extends ConsumerWidget {
  final Map<String, dynamic> episode;
  final int seasonNumber;
  final int episodeNumber;
  final double? currentRating;
  final ValueChanged<double?> onRatingChanged;
  final Function(bool) onWatchedStatusChanged;
  final VoidCallback? onCommentsPressed;

  const EpisodeActions({
    super.key,
    required this.episode,
    required this.seasonNumber,
    required this.episodeNumber,
    required this.currentRating,
    required this.onRatingChanged,
    required this.onWatchedStatusChanged,
    this.onCommentsPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Default to false if 'watched' is null
    final isWatched = episode['watched'] == true;
    final isWatching = ref.watch(
      watchlistProvider.select((state) => state.isLoading),
    );

    return Row(
      children: [
        // Comments button (aligned left)
        TextButton(
          onPressed: onCommentsPressed,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          ),
          child: Text(AppLocalizations.of(context)!.comments),
        ),

        // Spacer to push the star rating to the right
        const Spacer(),

        // Always reserve space for the star rating, even when not watched
        if (!isWatching) ...[
          SizedBox(
            width: isWatched ? null : 0, // Take up space only when watched
            child: isWatched
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: StarRating(
                      initialRating: currentRating ?? 0.0,
                      size: 20,
                      onRatingChanged: onRatingChanged,
                    ),
                  )
                : const SizedBox(width: 0), // Invisible placeholder
          ),
          const Spacer(),
        ],

        // Watched toggle button
        isWatching
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : TextButton(
                onPressed: () => onWatchedStatusChanged(!isWatched),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 8,
                  ),
                  backgroundColor:
                      isWatched ? Colors.green.withValues(alpha: 0.1) : null,
                  foregroundColor: isWatched ? Colors.green[700] : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isWatched ? Icons.visibility : Icons.visibility_off,
                      size: 18,
                      color: isWatched ? Colors.green[700] : null,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isWatched
                          ? AppLocalizations.of(context)!.watched
                          : AppLocalizations.of(context)!.unwatched,
                      style: TextStyle(
                        color: isWatched ? Colors.green[700] : null,
                        fontWeight:
                            isWatched ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
      ],
    );
  }
}
