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
  final trakt = ref.watch(traktApiProvider);
  final type = ref.watch(watchlistTypeProvider);
  final typeStr = type == WatchlistType.shows ? 'shows' : 'movies';

  // Fetch watchlist items from the API
  final items = await trakt.getWatched(type: typeStr);

  // Filter out items that don't have a show object
  final filteredItems =
      items.where((item) {
        // The item should have a 'show' field that contains the show data
        final hasShow = item['show'] is Map<String, dynamic>;
        if (!hasShow) {
          return false;
        }

        // For watched items, we don't need to filter by type since we're already getting
        // the correct type from the API endpoint (/users/me/watched/shows or /users/me/watched/movies)
        return true;
      }).toList();

  // For each show, fetch its watched progress and compute the next episode
  final futures =
      filteredItems.whereType<Map<String, dynamic>>().map((item) async {
        final show = item['show'];
        final ids = show != null ? show['ids'] : null;
        final traktId =
            ids != null ? ids['slug'] ?? ids['trakt']?.toString() : null;

        if (traktId != null) {
          try {
            // Fetch watched progress for this show
            final progress = await trakt.getShowWatchedProgress(id: traktId);
            final Map<String, dynamic> mutableProgress = Map.from(progress);

            // Find the next episode to watch
            Map<String, dynamic>? nextEpisode;
            if (progress['seasons'] is List) {
              final seasons =
                  (progress['seasons'] as List)
                      .where((s) => s['number'] != 0)
                      .toList();

              for (var season in seasons) {
                if (season['episodes'] is List) {
                  for (var episode in season['episodes']) {
                    if (episode['completed'] == false) {
                      nextEpisode = {
                        'season': season['number'],
                        'episode': episode['number'],
                      };
                      break;
                    }
                  }
                }
                if (nextEpisode != null) break;
              }
            }

            // If a next episode is found, fetch its full details
            if (nextEpisode != null) {
              final episodeInfo = await trakt.getEpisodeInfo(
                id: traktId,
                season: nextEpisode['season'],
                episode: nextEpisode['episode'],
              );
              mutableProgress['next_episode'] = episodeInfo;
            }

            return {...item, 'progress': mutableProgress};
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
