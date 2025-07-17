import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:watching/providers/app_providers.dart';
import 'package:watching/providers/watchlist_providers.dart';

import 'package:watching/show_details/seasons_progress_widget.dart';
import 'package:watching/show_details/show_info_chips.dart';
import 'package:watching/show_details/comments.dart';
import 'show_description.dart';
import 'header.dart';
import 'videos.dart';
import 'cast.dart';
import 'related.dart';

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
    return WillPopScope(
      onWillPop: () async {
        await refreshWatchlist();

        if (fullyWatched.value) {
          Navigator.of(context).pop({'traktId': showId, 'fullyWatched': true});
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
                    showData: show,
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
                    languageCode: countryCode.toLowerCase(),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Comentarios',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        TextButton.icon(
                          onPressed: () => showAllComments(
                            context,
                            showId,
                            title: 'Comentarios',
                          ),
                          icon: const Icon(Icons.comment_outlined),
                          label: const Text('Ver todos'),
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
}
