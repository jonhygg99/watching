import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watching/providers/app_providers.dart';
import 'package:watching/l10n/app_localizations.dart';
import 'package:watching/discover/discover_skeleton.dart';
import 'package:watching/discover/show_carousel.dart';
import 'package:watching/discover/show_list_page.dart';
import 'package:watching/shared/constants/colors.dart';
import 'package:watching/shared/constants/measures.dart';

/// DiscoverPage displays curated carousels of TV shows using data from ApiService.
class DiscoverPage extends ConsumerWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use Riverpod's generated provider for ApiService (see app_providers.dart)
    final api = ref.watch(traktApiProvider);

    /// Helper function for each carousel to ensure consistent error/loading handling
    // Navigation method for 'Ver más' button
    void navigateToShowList({
      required BuildContext context,
      required String title,
      required List<dynamic> shows,
      required dynamic Function(dynamic) extractShow,
    }) {
      final api = ref.read(traktApiProvider);

      // Create a function to fetch more shows based on the title
      Future<List<dynamic>> fetchShows({int page = 1, int limit = 20}) async {
        switch (title) {
          case 'Trending Shows':
            return await api.getTrendingShows(page: page, limit: limit);
          case 'Popular Shows':
            return await api.getPopularShows(page: page, limit: limit);
          case 'Most Favorited (7 days)':
            return await api.getMostFavoritedShows(
              period: 'weekly',
              page: page,
              limit: limit,
            );
          case 'Most Favorited (30 days)':
            return await api.getMostFavoritedShows(
              period: 'monthly',
              page: page,
              limit: limit,
            );
          case 'Most Collected (7 days)':
            return await api.getMostCollectedShows(
              period: 'weekly',
              page: page,
              limit: limit,
            );
          case 'Most Played (7 days)':
            return await api.getMostPlayedShows(
              period: 'weekly',
              page: page,
              limit: limit,
            );
          case 'Most Watched (7 days)':
            return await api.getMostWatchedShows(
              period: 'weekly',
              page: page,
              limit: limit,
            );
          case 'Most Anticipated':
            return await api.getMostAnticipatedShows(page: page, limit: limit);
          default:
            return [];
        }
      }

      Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (context) => ShowListPage(
                title: title,
                initialShows: shows,
                extractShow: extractShow,
                fetchShows: fetchShows,
              ),
        ),
      );
    }

    Widget buildCarousel({
      required String title,
      required Future<List<dynamic>> future,
      required Map<String, dynamic> Function(dynamic) extractShow,
      required String emptyText,
      required void Function(List<dynamic>) onViewMore,
    }) {
      return FutureBuilder<List<dynamic>>(
        future: future,
        builder: (context, snapshot) {
          // Always show skeleton while waiting for data
          if (snapshot.connectionState != ConnectionState.done) {
            return const DiscoverSkeleton();
          }
          if (snapshot.hasError) {
            // Use user-friendly, i18n-ready error message
            return Padding(
              padding: kVerticalPaddingPhone,
              child: Center(
                child: Text(
                  'Error loading data: ${snapshot.error}',
                  style: const TextStyle(color: kErrorColorMessage),
                ),
              ),
            );
          }
          final items = snapshot.data ?? [];
          return ShowCarousel(
            title: title,
            shows: items,
            extractShow: extractShow,
            emptyText: emptyText,
            onViewMore: () => onViewMore(items),
          );
        },
      );
    }

    // Section: Main ListView with all carousels
    final l10n =
        AppLocalizations.of(
          context,
        )!; // Using ! because we know it won't be null

    return ListView(
      key: const PageStorageKey('discover-list'), // preserves scroll position
      padding: const EdgeInsets.symmetric(
        vertical: kSpacePhone,
      ), // Add bottom padding to account for navigation bar
      physics:
          const AlwaysScrollableScrollPhysics(), // Ensure the list is always scrollable
      children: [
        // Trending Shows
        buildCarousel(
          title: l10n.trendingShows,
          future: api.getTrendingShows(),
          extractShow: (item) => item['show'],
          emptyText: '${l10n.trendingShows} - ${l10n.noResults}',
          onViewMore:
              (shows) => navigateToShowList(
                context: context,
                title: l10n.trendingShows,
                shows: shows,
                extractShow: (item) => item['show'],
              ),
        ),
        // Popular Shows
        buildCarousel(
          title: l10n.popularShows,
          future: api.getPopularShows(),
          extractShow: (item) => Map<String, dynamic>.from(item),
          emptyText: '${l10n.popularShows} - ${l10n.noResults}',
          onViewMore:
              (shows) => navigateToShowList(
                context: context,
                title: l10n.popularShows,
                shows: shows,
                extractShow: (item) => Map<String, dynamic>.from(item),
              ),
        ),
        // Most Favorited (7d)
        buildCarousel(
          title: l10n.mostFavoritedWeekly,
          future: api.getMostFavoritedShows(period: 'weekly'),
          extractShow: (item) => item['show'],
          emptyText: '${l10n.mostFavoritedWeekly} - ${l10n.noResults}',
          onViewMore:
              (shows) => navigateToShowList(
                context: context,
                title: l10n.mostFavoritedWeekly,
                shows: shows,
                extractShow: (item) => item['show'],
              ),
        ),
        // Most Favorited (30d)
        buildCarousel(
          title: l10n.mostFavoritedMonthly,
          future: api.getMostFavoritedShows(period: 'monthly'),
          extractShow: (item) => item['show'],
          emptyText: '${l10n.mostFavoritedMonthly} - ${l10n.noResults}',
          onViewMore:
              (shows) => navigateToShowList(
                context: context,
                title: l10n.mostFavoritedMonthly,
                shows: shows,
                extractShow: (item) => item['show'],
              ),
        ),
        // Most Collected (7d)
        buildCarousel(
          title: l10n.mostCollectedWeekly,
          future: api.getMostCollectedShows(period: 'weekly'),
          extractShow: (item) => item['show'],
          emptyText: '${l10n.mostCollectedWeekly} - ${l10n.noResults}',
          onViewMore:
              (shows) => navigateToShowList(
                context: context,
                title: l10n.mostCollectedWeekly,
                shows: shows,
                extractShow: (item) => item['show'],
              ),
        ),
        // Most Played (7d)
        buildCarousel(
          title: l10n.mostPlayedWeekly,
          future: api.getMostPlayedShows(period: 'weekly'),
          extractShow: (item) => item['show'],
          emptyText: '${l10n.mostPlayedWeekly} - ${l10n.noResults}',
          onViewMore:
              (shows) => navigateToShowList(
                context: context,
                title: l10n.mostPlayedWeekly,
                shows: shows,
                extractShow: (item) => item['show'],
              ),
        ),
        // Most Watched (7d)
        buildCarousel(
          title: l10n.mostWatchedWeekly,
          future: api.getMostWatchedShows(period: 'weekly'),
          extractShow: (item) => item['show'],
          emptyText: '${l10n.mostWatchedWeekly} - ${l10n.noResults}',
          onViewMore:
              (shows) => navigateToShowList(
                context: context,
                title: l10n.mostWatchedWeekly,
                shows: shows,
                extractShow: (item) => item['show'],
              ),
        ),
        // Most Anticipated
        buildCarousel(
          title: l10n.mostAnticipated,
          future: api.getMostAnticipatedShows(),
          extractShow:
              (item) => {
                ...Map<String, dynamic>.from(item['show']),
                'list_count': item['list_count'],
              },
          emptyText: '${l10n.mostAnticipated} - ${l10n.noResults}',
          onViewMore:
              (shows) => navigateToShowList(
                context: context,
                title: l10n.mostAnticipated,
                shows: shows,
                extractShow:
                    (item) => ({
                      ...Map<String, dynamic>.from(item['show']),
                      'list_count': item['list_count'],
                    }),
              ),
        ),
      ],
    );
  }
}
