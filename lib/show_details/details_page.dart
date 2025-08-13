import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:watching/providers/app_providers.dart';
import 'package:watching/providers/watchlist_providers.dart';
import 'package:watching/show_details/current_episode.dart';
import 'package:watching/show_details/new_header.dart';
import 'package:watching/show_details/related.dart';
import 'package:watching/api/trakt/trakt_api.dart';

import 'package:watching/show_details/seasons_progress_widget.dart';
import 'package:watching/show_details/show_info_chips.dart';
import 'package:watching/shared/widgets/comments_list.dart';
import 'package:watching/shared/constants/sort_options.dart';
import 'show_description.dart';
import 'header.dart';
import 'videos.dart';
import 'cast.dart';
// Related shows section removed

/// Displays detailed information about a TV show, including header, seasons, videos, cast, related shows, and comments.
/// Uses Riverpod for dependency injection and state management.
class ShowDetailPage extends HookConsumerWidget {
  final String showId;
  const ShowDetailPage({super.key, required this.showId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // State hooks
    final fullyWatched = useState(false);

    final refreshKey = useState(0); // Used to force refresh of data
    final apiService = ref.watch(traktApiProvider);
    final countryCode = ref.watch(countryCodeProvider);

    // Function to refresh watchlist data
    Future<void> refreshWatchlist() async {
      await ref.read(watchlistProvider.notifier).updateShowProgress(showId);
    }

    // Function to refresh show data
    Future<void> refreshShowData() async {
      await refreshWatchlist();
      refreshKey.value++;
    }

    // Intercept back navigation to pass result if fully watched
    return PopScope(
      canPop: true, // Always allow popping
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        // Always refresh watchlist when leaving the page
        await refreshWatchlist();

        // Only do custom navigation if the show is fully watched and widget is still mounted
        if (didPop && fullyWatched.value && context.mounted) {
          Navigator.of(context).pop({'traktId': showId, 'fullyWatched': true});
        }
      },
      child: Scaffold(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NewHeader(show: show, title: originalTitle),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (show['ids']?['trakt'] != null)
                          CurrentEpisode(
                            traktId: show['ids']['trakt'].toString(),
                            title: show['title']?.toString(),
                            languageCode: countryCode.substring(0, 2).toLowerCase(),
                          ),
                        ShowDescription(
                          tagline: originalTagline,
                          overview: originalOverview,
                        ),
                        const SizedBox(height: 16.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Lo que otros dicen',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                final sortNotifier = ValueNotifier<String>(
                                  'likes',
                                );
                                showAllComments(
                                  context,
                                  showId,
                                  sortNotifier,
                                  commentSortOptions,
                                  ref,
                                );
                              },
                              icon: const Icon(Icons.comment_outlined),
                              label: const Text('Comentarios'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        SeasonsProgressWidget(
                          showId: showId,
                          showData: show,
                          onProgressChanged: () async {
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
                          languageCode: countryCode.toLowerCase(),
                          onEpisodeWatched: () {
                            refreshShowData();
                            refreshWatchlist();
                          },
                          onWatchlistUpdate: refreshWatchlist,
                        ),
                        const SizedBox(height: 24.0),
                        if (videos != null && videos.isNotEmpty)
                          ShowDetailVideos(videos: videos),
                        if (videos != null && videos.isNotEmpty)
                          const SizedBox(height: 24.0),
                        if (people != null && people.isNotEmpty)
                          ShowDetailCast(
                            people: people,
                            showId: showId,
                            apiService: apiService,
                          ),
                        if (relatedShows != null && relatedShows.isNotEmpty)
                          ShowDetailRelated(
                            relatedShows: relatedShows,
                            apiService: apiService,
                            countryCode: countryCode,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Find the next episode to watch based on the show's progress
  /// Returns the next episode or null if all episodes are watched
  Map<String, dynamic>? _findNextEpisode(Map<String, dynamic>? progress) {
    try {
      if (progress == null) return null;
      
      // First check if we have a next_episode from the API
      final nextEpisode = progress['next_episode'];
      if (nextEpisode != null) return nextEpisode;
      
      // If no next_episode, try to find the first unwatched episode
      final seasons = progress['seasons'] as List<dynamic>?;
      if (seasons == null) return null;
      
      for (final season in seasons) {
        final episodes = season['episodes'] as List<dynamic>?;
        if (episodes == null) continue;
        
        for (final episode in episodes) {
          final completed = episode['completed'] as bool? ?? false;
          if (!completed) {
            return {
              'season': season['number'],
              'number': episode['number'],
              'title': episode['title'],
            };
          }
        }
      }
      
      return null; // All episodes watched
    } catch (e) {
      debugPrint('Error finding next episode: $e');
      return null;
    }
  }
}
