import 'package:flutter/material.dart';
import 'package:watching/shared/constants/colors.dart';
import 'widgets/back_button.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:watching/l10n/app_localizations.dart';
import 'package:watching/features/watchlist/state/watchlist_notifier.dart';
import 'package:watching/providers/app_providers.dart';
import 'package:watching/shared/constants/measures.dart';
import 'package:watching/show_details/widgets/current_episode/current_episode.dart';
import 'package:watching/show_details/widgets/header/header.dart';
import 'package:watching/show_details/widgets/related.dart';
import 'package:watching/shared/widgets/comments/comments_list.dart';
import 'package:watching/shared/constants/sort_options.dart';
import 'package:watching/show_details/widgets/skeleton/show_detail_skeleton.dart';
import 'widgets/show_description.dart';
import 'widgets/videos.dart';
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

    final apiService = ref.watch(traktApiProvider);
    final countryCode = ref.watch(countryCodeProvider);

    // Function to refresh watchlist data
    Future<void> refreshWatchlist() async {
      await ref.read(watchlistProvider.notifier).updateShowProgress(showId);
    }

    // Intercept back navigation to pass result if fully watched
    // Create a scroll controller for the page
    final scrollController = useScrollController();

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
        body: Stack(
          children: [
            FutureBuilder<List<dynamic>>(
              future: Future.wait([
                apiService.getShowById(id: showId),
                apiService.getShowTranslations(
                  id: showId,
                  language: countryCode.substring(0, 2).toLowerCase(),
                ),
                apiService.getShowPeople(id: showId),
                apiService.getShowVideos(id: showId),
                apiService.getRelatedShows(id: showId),
              ]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const ShowDetailSkeleton();
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: \\${snapshot.error}',
                      style: const TextStyle(color: kErrorColorMessage),
                    ),
                  );
                }
                final results = snapshot.data;

                if (results == null || results.length < 5) {
                  return Center(
                    child: Text(AppLocalizations.of(context)!.noResults),
                  );
                }
                final show = results[0] as Map<String, dynamic>?;
                final translations = results[1] as List<dynamic>?;
                final people = results[2] as Map<String, dynamic>?;
                final videos = results[3] as List<dynamic>?;
                final relatedShowsResponse =
                    results[4] as Map<String, dynamic>?;
                final relatedShows =
                    relatedShowsResponse?['shows'] as List<dynamic>?;

                if (show == null) {
                  return Center(
                    child: Text(AppLocalizations.of(context)!.noResults),
                  );
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
                final originalTitle =
                    translation?['title'] ?? show['title'] ?? '';
                final originalOverview =
                    translation?['overview'] ?? show['overview'] ?? '';
                final originalTagline =
                    translation?['tagline'] ?? show['tagline'] ?? '';

                return CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    SliverToBoxAdapter(
                      child: Header(
                        show: show,
                        title: originalTitle,
                        scrollController: scrollController,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: kSpacePhoneHorizontal,
                          right: kSpacePhoneHorizontal,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CurrentEpisode(
                              traktId: show['ids']['trakt'].toString(),
                              title: show['title']?.toString(),
                              languageCode:
                                  countryCode.substring(0, 2).toLowerCase(),
                              showData: show,
                            ),
                            ShowDescription(
                              tagline: originalTagline,
                              overview: originalOverview,
                            ),
                            if (people != null && people.isNotEmpty) ...[
                              const SizedBox(height: kSpaceBtwWidgets),
                              ShowDetailCast(
                                people: people,
                                showId: showId,
                                apiService: apiService,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    if (videos != null && videos.isNotEmpty)
                      SliverToBoxAdapter(
                        child: ShowDetailVideos(
                          videos: videos,
                          title: originalTitle,
                        ),
                      ),
                    SliverToBoxAdapter(
                      child: ShowDetailRelated(
                        relatedShows: relatedShows,
                        apiService: apiService,
                        showId: showId,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: kSpaceBtwWidgets,
                          left: kSpacePhoneHorizontal,
                          right: kSpacePhoneHorizontal,
                          bottom: 50,
                        ),
                        child: Row(
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
                      ),
                    ),
                  ],
                );
              },
            ),
            // Back button
            const BackButtonWidget(),
          ],
        ),
      ),
    );
  }
}
