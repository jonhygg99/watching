import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/app_providers.dart';
import '../providers/watchlist_providers.dart';
import 'seasons_progress_widget.dart';
import 'show_info_chips.dart';
import 'show_description.dart';
import 'header.dart';
import 'videos.dart';
import 'cast.dart';
import 'related.dart';
import 'comments.dart';

/// Displays detailed information about a TV show, including header, seasons, videos, cast, related shows, and comments.
/// Uses Riverpod for dependency injection and state management.
class ShowDetailPage extends HookConsumerWidget {
  final String showId;
  const ShowDetailPage({super.key, required this.showId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // State hooks
    final fullyWatched = useState(false);
    final sort = useState('likes');
    final refreshKey = useState(0); // Used to force refresh of data
    final refreshTrigger = useState(0); // Separate trigger for episode updates
    final apiService = ref.watch(traktApiProvider);
    final countryCode = ref.watch(countryCodeProvider);
    final watchlistNotifier = ref.read(watchlistProvider.notifier);
    
    // Function to refresh watchlist data
    Future<void> refreshWatchlist() async {
      await watchlistNotifier.updateShowProgress(showId);
    }
    
    // Watch for changes to the refresh key to trigger a rebuild
    useEffect(() {
      // This will run whenever refreshKey changes
      return null;
    }, [refreshKey.value]);
    
    final sortLabels = const {
      'likes': 'Más likes',
      'newest': 'Más recientes',
      'oldest': 'Más antiguos',
      'replies': 'Más respuestas',
      'highest': 'Mejor valorados',
      'lowest': 'Peor valorados',
      'plays': 'Más reproducidos',
      'watched': 'Más vistos',
    };

    // Comments future (updates when sort, showId, or refreshKey changes)
    final commentsFuture = useMemoized(
      () => apiService.getShowComments(id: showId, sort: sort.value),
      [apiService, showId, sort.value, refreshKey.value, refreshTrigger.value],
    );

    // Function to refresh show data
    void refreshShowData() {
      refreshTrigger.value++;
    }

    // Intercept back navigation to pass result if fully watched
    return WillPopScope(
      onWillPop: () async {
        // Always refresh the watchlist when going back
        await refreshWatchlist();
        
        if (fullyWatched.value) {
          Navigator.pop(context, {'traktId': showId, 'fullyWatched': true});
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Detalle del Show')),
        body: FutureBuilder<List<dynamic>>(
          future: Future.wait([
            apiService.getShowById(id: showId),
            apiService.getShowTranslations(
              id: showId,
              language: countryCode.substring(0, 2).toLowerCase(),
            ),
            apiService.getShowVideos(id: showId),
            apiService.getShowPeople(id: showId),
            apiService.getRelatedShows(id: showId),
          ]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: \\${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }
            final results = snapshot.data;

            if (results == null || results.length < 5) {
              return const Center(child: Text('No se encontraron datos.'));
            }
            final show = results[0] as Map<String, dynamic>?;
            final translations = results[1] as List<dynamic>?;
            final videos = results[2] as List<dynamic>?;
            final people = results[3] as Map<String, dynamic>?;
            final relatedShows = results[4] as List<dynamic>?;
            final certifications =
                show?['certifications'] as List<dynamic>? ?? [];
            if (show == null) {
              return const Center(child: Text('No se encontraron datos.'));
            }

            // Filter out null values and find the best translation
            Map<String, dynamic>? translation;
            if (translations != null && translations.isNotEmpty) {
              // Filter out translations with null title
              final validTranslations =
                  translations.where((t) => t['title'] != null).toList();

              if (validTranslations.isNotEmpty) {
                // Try to find exact match for user's country
                translation = validTranslations.firstWhere(
                  (t) =>
                      t['language']?.toString().toLowerCase() ==
                      countryCode.substring(0, 2).toLowerCase(),
                  orElse: () => validTranslations.first,
                );
              }
            }

            // Get title, overview, and tagline from translation if available, otherwise use original
            final originalTitle = translation?['title'] ?? show['title'] ?? '';
            final originalOverview =
                translation?['overview'] ?? show['overview'] ?? '';
            final originalTagline =
                translation?['tagline'] ?? show['tagline'] ?? '';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShowDetailHeader(show: show, title: originalTitle),
                  ShowDescription(
                    tagline: originalTagline,
                    overview: originalOverview,
                  ),
                  ShowInfoChips(
                    show: show,
                    certifications: certifications,
                    countryCode: countryCode,
                  ),
                  SeasonsProgressWidget(
                    showId: showId,
                    onProgressChanged: () async {
                      // Check if all seasons are now watched
                      final api = ref.read(traktApiProvider);
                      final progress = await api.getShowWatchedProgress(
                        id: showId,
                      );
                      final total = progress['aired'] ?? 0;
                      final completed = progress['completed'] ?? 0;
                      if (total > 0 && completed == total) {
                        fullyWatched.value = true;
                      }
                    },
                    onEpisodeWatched: () {
                      // Refresh the UI and watchlist data
                      refreshShowData();
                      refreshWatchlist();
                    },
                    onWatchlistUpdate: refreshWatchlist,
                  ),
                  ShowDetailVideos(videos: videos),
                  ShowDetailCast(
                    people: people,
                    showId: showId,
                    apiService: apiService,
                  ),
                  ShowDetailRelated(
                    relatedShows: relatedShows,
                    apiService: apiService,
                    countryCode: countryCode,
                  ),
                  ShowDetailComments(
                    commentsFuture: commentsFuture,
                    sort: sort.value,
                    sortLabels: sortLabels,
                    onChangeSort: (value) {
                      if (value != null && value != sort.value) {
                        sort.value = value;
                      }
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
