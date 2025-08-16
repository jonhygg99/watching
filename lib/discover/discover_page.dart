import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watching/providers/app_providers.dart';
import 'package:watching/discover/discover_skeleton.dart';
import 'package:watching/discover/show_carousel.dart';
import 'package:watching/discover/show_list_page.dart';

/// DiscoverPage displays curated carousels of TV shows using data from ApiService.
/// - Follows Windsurf Development Guidelines for Riverpod usage and code structure.
/// - Uses generated provider for ApiService for optimal DI and testability.
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
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Error loading data: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        key: const PageStorageKey('discover-list'), // preserves scroll position
        children: [
          // Trending Shows
          SizedBox(height: 16),
          buildCarousel(
            title: 'Trending Shows',
            future: api.getTrendingShows(),
            extractShow: (item) => item['show'],
            emptyText: 'No trending shows.',
            onViewMore:
                (shows) => navigateToShowList(
                  context: context,
                  title: 'Trending Shows',
                  shows: shows,
                  extractShow: (item) => item['show'],
                ),
          ),
          // Popular Shows
          SizedBox(height: 16),
          buildCarousel(
            title: 'Popular Shows',
            future: api.getPopularShows(),
            extractShow: (item) => Map<String, dynamic>.from(item),
            emptyText: 'No popular shows.',
            onViewMore:
                (shows) => navigateToShowList(
                  context: context,
                  title: 'Popular Shows',
                  shows: shows,
                  extractShow: (item) => Map<String, dynamic>.from(item),
                ),
          ),
          // Most Favorited (7d)
          SizedBox(height: 16),
          buildCarousel(
            title: 'Most Favorited (7 days)',
            future: api.getMostFavoritedShows(period: 'weekly'),
            extractShow: (item) => item['show'],
            emptyText: 'No most favorited shows this week.',
            onViewMore:
                (shows) => navigateToShowList(
                  context: context,
                  title: 'Most Favorited (7 days)',
                  shows: shows,
                  extractShow: (item) => item['show'],
                ),
          ),
          // Most Favorited (30d)
          SizedBox(height: 16),
          buildCarousel(
            title: 'Most Favorited (30 days)',
            future: api.getMostFavoritedShows(period: 'monthly'),
            extractShow: (item) => item['show'],
            emptyText: 'No most favorited shows this month.',
            onViewMore:
                (shows) => navigateToShowList(
                  context: context,
                  title: 'Most Favorited (30 days)',
                  shows: shows,
                  extractShow: (item) => item['show'],
                ),
          ),
          // Most Collected (7d)
          SizedBox(height: 16),
          buildCarousel(
            title: 'Most Collected (7 days)',
            future: api.getMostCollectedShows(period: 'weekly'),
            extractShow: (item) => item['show'],
            emptyText: 'No most collected shows this week.',
            onViewMore:
                (shows) => navigateToShowList(
                  context: context,
                  title: 'Most Collected (7 days)',
                  shows: shows,
                  extractShow: (item) => item['show'],
                ),
          ),
          // Most Played (7d)
          SizedBox(height: 16),
          buildCarousel(
            title: 'Most Played (7 days)',
            future: api.getMostPlayedShows(period: 'weekly'),
            extractShow: (item) => item['show'],
            emptyText: 'No most played shows this week.',
            onViewMore:
                (shows) => navigateToShowList(
                  context: context,
                  title: 'Most Played (7 days)',
                  shows: shows,
                  extractShow: (item) => item['show'],
                ),
          ),
          // Most Watched (7d)
          SizedBox(height: 16),
          buildCarousel(
            title: 'Most Watched (7 days)',
            future: api.getMostWatchedShows(period: 'weekly'),
            extractShow: (item) => item['show'],
            emptyText: 'No most watched shows this week.',
            onViewMore:
                (shows) => navigateToShowList(
                  context: context,
                  title: 'Most Watched (7 days)',
                  shows: shows,
                  extractShow: (item) => item['show'],
                ),
          ),
          // Most Anticipated
          SizedBox(height: 16),
          buildCarousel(
            title: 'Most Anticipated',
            future: api.getMostAnticipatedShows(),
            extractShow:
                (item) => {
                  ...Map<String, dynamic>.from(item['show']),
                  'list_count': item['list_count'],
                },
            emptyText: 'No anticipated shows.',
            onViewMore:
                (shows) => navigateToShowList(
                  context: context,
                  title: 'Most Anticipated',
                  shows: shows,
                  extractShow:
                      (item) => {
                        ...Map<String, dynamic>.from(item['show']),
                        'list_count': item['list_count'],
                      },
                ),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}
