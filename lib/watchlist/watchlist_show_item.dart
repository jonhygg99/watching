import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:watching/providers/app_providers.dart';
import 'package:watching/watchlist/animated_show_card.dart';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final show = item['show'] as Map<String, dynamic>?;
    final title =
        show != null ? show['title'] as String? ?? 'Sin título' : 'Sin título';
    final ids = show != null ? show['ids'] as Map<String, dynamic>? : null;
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
    // Defensive: always provide a progress map for downstream widgets
    final progress = item['progress'] as Map<String, dynamic>? ?? {};
    final watched = progress['completed'] as int? ?? 0;
    final total = progress['aired'] as int? ?? 1;
    // print(progress);
    // print("$title $watched $total");
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
          apiService: ref.read(apiServiceProvider),
          progress: progress,
        ),
        builder:
            (context, child) => ShowCard(
              traktId: traktId,
              posterUrl: posterUrl,
              infoWidget: child,
              apiService: ref.read(apiServiceProvider),
              parentContext: context,
              countryCode: Localizations.localeOf(context).countryCode,
            ),
        onFullyWatched: () => onFullyWatched?.call(traktId),
      );
    }

    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap!(traktId);
        } else {
          // Default navigation: open ShowDetailPage
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ShowDetailPage(showId: traktId!)),
          );
        }
      },
      child: ShowCard(
        traktId: traktId,
        posterUrl: posterUrl,
        apiService: ref.read(apiServiceProvider),
        parentContext: context,
        countryCode: Localizations.localeOf(context).countryCode,
        infoWidget: WatchProgressInfo(
          traktId: traktId,
          title: title,
          apiService: ref.read(apiServiceProvider),
          progress: progress,
        ),
      ),
    );
  }
}
