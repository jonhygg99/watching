import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:watching/providers/app_providers.dart';
import 'package:watching/watchlist/animated_show_card.dart';
import 'package:watching/features/watchlist/state/watchlist_notifier.dart';
import 'package:watching/watchlist/show_card.dart';
import 'package:watching/watchlist/watch_progress_info.dart';
import 'package:watching/show_details/details_page.dart';

/// Widget for a single show/movie item in the watchlist.
class WatchlistShowItem extends HookConsumerWidget {
  final Map<String, dynamic> item;
  final Set<String> animatingOut;
  final void Function(String traktId)? onFullyWatched;
  final void Function(String traktId)? onTap;

  const WatchlistShowItem({
    super.key,
    required this.item,
    required this.animatingOut,
    this.onFullyWatched,
    this.onTap,
  });

  // Toggle watched status of the next/last episode
  Future<void> _toggleWatchedStatus(
    WidgetRef ref,
    String traktId,
    bool markAsWatched,
    BuildContext context,
  ) async {
    try {
      final notifier = ref.read(watchlistProvider.notifier);
      if (markAsWatched) {
        await notifier.markEpisodeAsWatched(traktId);
      } else {
        await notifier.markEpisodeAsUnwatched(traktId);
      }
      // Force a refresh of the watchlist
      await notifier.updateShowProgress(traktId);

      // Show success message
      if (context.mounted) {
        final message =
            markAsWatched
                ? 'Episode marked as watched'
                : 'Episode marked as unwatched';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error toggling watched status: $e');
      // Show error to user
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Safely get the show map with proper type handling
    final show =
        item['show'] is Map
            ? Map<String, dynamic>.from(item['show'] as Map)
            : null;
    final title = show?['title']?.toString() ?? 'No title';

    // Safely get the ids map with proper type handling
    final idsMap = show?['ids'];
    final ids = idsMap is Map ? Map<String, dynamic>.from(idsMap) : null;
    final traktId =
        ids != null ? ids['slug'] ?? ids['trakt']?.toString() : null;

    // Extract poster URL defensively (handle missing/relative URLs)
    String? posterUrl;
    if (show != null &&
        show['images'] != null &&
        show['images']['poster'] != null &&
        (show['images']['poster'] as List).isNotEmpty) {
      posterUrl = show['images']['poster'][0] as String?;
      if (posterUrl != null && !posterUrl.startsWith('http')) {
        posterUrl = 'https://$posterUrl';
      }
    }

    // Safely get progress with proper type handling
    final progressMap = item['progress'];
    final progress =
        progressMap is Map
            ? Map<String, dynamic>.from(progressMap)
            : <String, dynamic>{};

    final watched = progress['completed'] as int? ?? 0;
    final total = progress['aired'] as int? ?? 1;
    if (traktId == null || watched == total) {
      return const SizedBox.shrink();
    }

    if (animatingOut.contains(traktId)) {
      return AnimatedShowCard(
        traktId: traktId,
        posterUrl: posterUrl,
        watched: watched,
        total: total,
        infoWidget: WatchProgressInfo(
          traktId: traktId,
          title: title,
          apiService: ref.read(traktApiProvider),
          progress: progress,
        ),
        builder:
            (context, child) => ShowCard(
              traktId: traktId,
              posterUrl: posterUrl,
              infoWidget: child,
              apiService: ref.read(traktApiProvider),
              parentContext: context,
            ),
        onFullyWatched: () => onFullyWatched?.call(traktId),
      );
    }

    // Use a state variable to prevent the widget from being dismissed
    final ValueNotifier<bool> isProcessingNotifier = ValueNotifier<bool>(false);

    return ValueListenableBuilder<bool>(
      valueListenable: isProcessingNotifier,
      builder: (context, isProcessing, _) {
        return AbsorbPointer(
          absorbing: isProcessing,
          child: Dismissible(
            key: ValueKey('dismissible_$traktId'),
            direction: DismissDirection.horizontal,
            confirmDismiss: (direction) async {
              try {
                isProcessingNotifier.value = true;
                if (direction == DismissDirection.startToEnd) {
                  // Swipe right to mark as unwatched
                  await _toggleWatchedStatus(ref, traktId, false, context);
                } else if (direction == DismissDirection.endToStart) {
                  // Swipe left to mark as watched
                  await _toggleWatchedStatus(ref, traktId, true, context);
                }
                return false; // Never dismiss the item
              } catch (e) {
                debugPrint('Error in confirmDismiss: $e');
                return false; // Don't dismiss on error
              } finally {
                isProcessingNotifier.value = false;
              }
            },
            background: Container(
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
              decoration: BoxDecoration(
                color:
                    isProcessing
                        ? Colors.grey.withValues(alpha: 0.3)
                        : Colors.red[700]?.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 20),
              child:
                  isProcessing
                      ? const CircularProgressIndicator()
                      : const Icon(Icons.undo, color: Colors.white, size: 30),
            ),
            secondaryBackground: Container(
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
              decoration: BoxDecoration(
                color:
                    isProcessing
                        ? Colors.grey.withValues(alpha: 0.3)
                        : Colors.green[700]?.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child:
                  isProcessing
                      ? const CircularProgressIndicator()
                      : const Icon(Icons.check, color: Colors.white, size: 30),
            ),
            child: GestureDetector(
              onTap: () {
                if (onTap != null) {
                  onTap!(traktId);
                } else {
                  // Default navigation: open ShowDetailPage
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ShowDetailPage(showId: traktId!),
                    ),
                  );
                }
              },
              child: ShowCard(
                key: ValueKey('show_card_$traktId'),
                traktId: traktId,
                posterUrl: posterUrl,
                apiService: ref.read(traktApiProvider),
                parentContext: context,
                infoWidget: WatchProgressInfo(
                  traktId: traktId,
                  title: title,
                  apiService: ref.read(traktApiProvider),
                  progress: progress,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
