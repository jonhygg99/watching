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

    // Function to refresh watchlist data
    Future<void> refreshWatchlist() async {
      await ref.read(watchlistProvider.notifier).updateShowProgress(showId);
    }

    Future<void> showAllComments(
      BuildContext context,
      String showId,
      ValueNotifier<String> sort,
      Map<String, String> sortLabels,
    ) async {
      final apiService = ref.read(traktApiProvider);
      // Fetch comments with the current sort order when the modal is opened
      final commentsFuture = apiService.getShowComments(
        id: showId,
        sort: sort.value,
      );

      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder:
            (context) => Container(
              height: MediaQuery.of(context).size.height * 0.9,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Comentarios',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: FutureBuilder<List<dynamic>>(
                      future: commentsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'Error loading comments: ${snapshot.error}',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }

                        final comments = snapshot.data ?? [];

                        if (comments.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'No comments yet',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 8.0,
                          ),
                          itemCount: comments.length,
                          itemBuilder: (context, index) {
                            final comment = comments[index];
                            final user = comment['user'] ?? {};
                            final userName = user['username'] ?? 'Unknown';
                            final userAvatar =
                                user['images']?['avatar']?['full'];
                            final commentText = comment['comment'] ?? '';
                            final likes = comment['likes'] ?? 0;
                            final isSpoiler = comment['spoiler'] == true;
                            final isReview = comment['review'] == true;
                            final date =
                                comment['created_at']?.substring(0, 10) ?? '';

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                vertical: 4.0,
                                horizontal: 8.0,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (userAvatar != null)
                                          CircleAvatar(
                                            backgroundImage: NetworkImage(
                                              userAvatar,
                                            ),
                                            radius: 20,
                                          )
                                        else
                                          const CircleAvatar(
                                            radius: 20,
                                            child: Icon(Icons.person),
                                          ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                userName,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleSmall
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                              if (date.isNotEmpty)
                                                Text(
                                                  date,
                                                  style: Theme.of(
                                                    context,
                                                  ).textTheme.bodySmall?.copyWith(
                                                    color:
                                                        Theme.of(context)
                                                            .colorScheme
                                                            .onSurfaceVariant,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        if (isSpoiler || isReview) ...[
                                          if (isSpoiler)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                              margin: const EdgeInsets.only(
                                                left: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                'SPOILER',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelSmall
                                                    ?.copyWith(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                            ),
                                          if (isReview)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                              margin: const EdgeInsets.only(
                                                left: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.blue,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                'REVIEW',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelSmall
                                                    ?.copyWith(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                            ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      commentText,
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        const Icon(Icons.thumb_up, size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          likes.toString(),
                                          style:
                                              Theme.of(
                                                context,
                                              ).textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
      );
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
                          onPressed:
                              () => showAllComments(
                                context,
                                showId,
                                sort,
                                sortLabels,
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
