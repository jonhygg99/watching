import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watching/providers/app_providers.dart';
import 'package:watching/discover/discover_skeleton.dart';
import 'package:watching/discover/show_carousel.dart';

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
    Widget buildCarousel({
      required String title,
      required Future<List<dynamic>> future,
      required Map<String, dynamic> Function(dynamic) extractShow,
      required String emptyText,
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
          ),
          // Popular Shows
          SizedBox(height: 16),
          buildCarousel(
            title: 'Popular Shows',
            future: api.getPopularShows(),
            extractShow: (item) => Map<String, dynamic>.from(item),
            emptyText: 'No popular shows.',
          ),
          // Most Favorited (7d)
          SizedBox(height: 16),
          buildCarousel(
            title: 'Most Favorited (7 days)',
            future: api.getMostFavoritedShows(period: 'weekly'),
            extractShow: (item) => item['show'],
            emptyText: 'No most favorited shows this week.',
          ),
          // Most Favorited (30d)
          SizedBox(height: 16),
          buildCarousel(
            title: 'Most Favorited (30 days)',
            future: api.getMostFavoritedShows(period: 'monthly'),
            extractShow: (item) => item['show'],
            emptyText: 'No most favorited shows this month.',
          ),
          // Most Collected (7d)
          SizedBox(height: 16),
          buildCarousel(
            title: 'Most Collected (7 days)',
            future: api.getMostCollectedShows(period: 'weekly'),
            extractShow: (item) => item['show'],
            emptyText: 'No most collected shows this week.',
          ),
          // Most Played (7d)
          SizedBox(height: 16),
          buildCarousel(
            title: 'Most Played (7 days)',
            future: api.getMostPlayedShows(period: 'weekly'),
            extractShow: (item) => item['show'],
            emptyText: 'No most played shows this week.',
          ),
          // Most Watched (7d)
          SizedBox(height: 16),
          buildCarousel(
            title: 'Most Watched (7 days)',
            future: api.getMostWatchedShows(period: 'weekly'),
            extractShow: (item) => item['show'],
            emptyText: 'No most watched shows this week.',
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
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}
