import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:watching/providers/app_providers.dart';

/// Enum for watchlist type
enum WatchlistType { shows, movies }

/// Provider for selected watchlist type
final watchlistTypeProvider = StateProvider<WatchlistType>(
  (ref) => WatchlistType.shows,
);

/// Async provider for the filtered watchlist.
/// Fetches the latest shows/movies from the Trakt API, including progress as provided by the API.
/// No extra progress fetching is performed. Items are returned as-is.
/// Provider for the user's watchlist with accurate progress for each show.
/// For each show, fetches the watched progress using Trakt's /shows/{id}/progress/watched endpoint.
/// Results are attached as 'progress' and are fully compatible with the UI (WatchProgressInfo).
final watchlistProvider = FutureProvider.autoDispose<
  List<Map<String, dynamic>>
>((ref) async {
  final trakt = ref.watch(apiServiceProvider);
  final type = ref.watch(watchlistTypeProvider);

  // Fetch watched items from the API (basic info only)
  final items = await trakt.getWatched(
    type: type == WatchlistType.shows ? 'shows' : 'movies',
  );

  // For each show, fetch its watched progress in parallel and attach as 'progress'
  final futures =
      items.whereType<Map<String, dynamic>>().map((item) async {
        final show = item['show'];
        final ids = show != null ? show['ids'] : null;
        final traktId =
            ids != null ? ids['slug'] ?? ids['trakt']?.toString() : null;
        if (traktId != null) {
          try {
            // Fetch watched progress for this show
            final progress = await trakt.getShowWatchedProgress(id: traktId);
            return {...item, 'progress': progress};
          } catch (e) {
            // On error, still include the item with empty progress for UI consistency
            return {...item, 'progress': <String, dynamic>{}};
          }
        } else {
          // If no traktId, fallback to empty progress
          return {...item, 'progress': <String, dynamic>{}};
        }
      }).toList();

  // Wait for all progress fetches to complete
  return await Future.wait(futures);
});
