import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watching/providers/app_providers.dart';
import 'package:watching/l10n/app_localizations.dart';
import 'package:watching/shared/pages/show_list/show_list_page.dart';
import 'package:watching/shared/widgets/carousel/carousel.dart';
import 'package:watching/shared/constants/measures.dart';
import 'package:watching/shared/models/movie_models.dart';
import 'package:watching/api/trakt/movies_lists_api.dart';
import 'package:watching/shared/models/show_models.dart';

/// DiscoverPage displays curated carousels of TV shows using data from Trakt API.
class DiscoverPage extends ConsumerWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final api = ref.watch(traktApiProvider);
    final l10n = AppLocalizations.of(context)!;

    // Helper method to test API calls
    Future<void> _testApiCall(
      String name,
      Future<List<TraktMovie>> Function() apiCall,
    ) async {
      debugPrint('\n$name:');
      try {
        final movies = await apiCall();
        debugPrint('✅ Success! Found ${movies.length} movies');

        if (movies.isNotEmpty) {
          for (var i = 0; i < movies.take(3).length; i++) {
            final movie = movies[i];
            debugPrint('${i + 1}. ${movie.title}');
            debugPrint('   ID: ${movie.ids.trakt}');
            debugPrint('   TMDB: ${movie.ids.tmdb}');
            debugPrint('   IMDB: ${movie.ids.imdb}');
            if (movie.images != null && movie.images!.isNotEmpty) {
              debugPrint('   Images: ${movie.images!.keys.join(', ')}');
            }
            debugPrint('---');
          }
        } else {
          debugPrint('ℹ️ No results found');
        }
      } catch (e, stackTrace) {
        debugPrint('❌ Error in $name: $e');
        debugPrint('Stack trace: $stackTrace');
        rethrow;
      }
    }

    // Test function for movie APIs
    void _testMovieApis() async {
      try {
        debugPrint('=== Testing Movie APIs ===');

        // Test trending movies
        await _testApiCall(
          'Trending Movies',
          () => api.getTrendingMovies(),
        );

        // Test popular movies
        await _testApiCall(
          'Popular Movies',
          () => api.getPopularMovies(),
        );

        // Test favorited movies (weekly)
        await _testApiCall(
          'Weekly Favorited Movies',
          () => api.getFavoritedMovies(period: TimePeriod.weekly),
        );

        // Test played movies (weekly)
        await _testApiCall(
          'Weekly Played Movies',
          () => api.getPlayedMovies(period: TimePeriod.weekly),
        );

        // Test watched movies (weekly)
        await _testApiCall(
          'Weekly Watched Movies',
          () => api.getWatchedMovies(period: TimePeriod.weekly),
        );

        debugPrint('=== End of Movie API Test ===');
      } catch (e) {
        debugPrint('Error testing movie APIs: $e');
      }
    }

    // _testMovieApis();
    return Stack(
      children: [
        ListView(
          key: const PageStorageKey('discover-list'),
          padding: const EdgeInsets.symmetric(vertical: kPhoneSpaceVertical),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            _buildCarousel(
              context: context,
              title: l10n.trendingShows,
              future: api.getTrendingShows(),
              emptyText: '${l10n.trendingShows} - ${l10n.noResults}',
            ),
            const SizedBox(height: kSpaceBtwWidgets),
            _buildCarousel(
              context: context,
              title: l10n.popularShows,
              future: api.getPopularShows(),
              emptyText: '${l10n.popularShows} - ${l10n.noResults}',
            ),
            const SizedBox(height: kSpaceBtwWidgets),
            _buildCarousel(
              context: context,
              title: l10n.mostFavoritedWeekly,
              future: api.getMostFavoritedShows(period: 'weekly'),
              emptyText: '${l10n.mostFavoritedWeekly} - ${l10n.noResults}',
            ),
            const SizedBox(height: kSpaceBtwWidgets),
            _buildCarousel(
              context: context,
              title: l10n.mostFavoritedMonthly,
              future: api.getMostFavoritedShows(period: 'monthly'),
              emptyText: '${l10n.mostFavoritedMonthly} - ${l10n.noResults}',
            ),
            const SizedBox(height: kSpaceBtwWidgets),
            _buildCarousel(
              context: context,
              title: l10n.mostCollectedWeekly,
              future: api.getMostCollectedShows(period: 'weekly'),
              emptyText: '${l10n.mostCollectedWeekly} - ${l10n.noResults}',
            ),
            const SizedBox(height: kSpaceBtwWidgets),
            _buildCarousel(
              context: context,
              title: l10n.mostPlayedWeekly,
              future: api.getMostPlayedShows(period: 'weekly'),
              emptyText: '${l10n.mostPlayedWeekly} - ${l10n.noResults}',
            ),
            const SizedBox(height: kSpaceBtwWidgets),
            _buildCarousel(
              context: context,
              title: l10n.mostWatchedWeekly,
              future: api.getMostWatchedShows(period: 'weekly'),
              emptyText: '${l10n.mostWatchedWeekly} - ${l10n.noResults}',
            ),
            const SizedBox(height: kSpaceBtwWidgets),
            _buildCarousel(
              context: context,
              title: l10n.mostAnticipated,
              future: api.getMostAnticipatedShows(),
              emptyText: '${l10n.mostAnticipated} - ${l10n.noResults}',
            ),
          ],
        ),
        // Floating action button to test movie APIs
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            onPressed: _testMovieApis,
            child: const Icon(Icons.movie_creation),
          ),
        ),
      ],
    );
  }

  Widget _buildCarousel({
    required BuildContext context,
    required String title,
    required Future<List<TraktShow>> future,
    required String emptyText,
  }) {
    return FutureBuilder<List<TraktShow>>(
      future: future,
      builder: (context, snapshot) {
        final shows = snapshot.data ?? [];
        return Carousel(
          title: title,
          future: future,
          extractShow: (show) => show.toJson(),
          emptyText: emptyText,
          onViewMore: () => _navigateToShowList(
            context: context,
            title: title,
            shows: shows,
          ),
        );
      },
    );
  }

  void _navigateToShowList({
    required BuildContext context,
    required String title,
    required List<TraktShow> shows,
  }) {
    final api = ProviderScope.containerOf(context).read(traktApiProvider);

    Future<List<TraktShow>> fetchShows({int page = 1, int limit = 20}) async {
      switch (title) {
        case 'Trending Shows':
          return api.getTrendingShows(page: page, limit: limit);
        case 'Popular Shows':
          return api.getPopularShows(page: page, limit: limit);
        case 'Most Favorited (7 days)':
          return api.getMostFavoritedShows(
            period: 'weekly',
            page: page,
            limit: limit,
          );
        case 'Most Favorited (30 days)':
          return api.getMostFavoritedShows(
            period: 'monthly',
            page: page,
            limit: limit,
          );
        case 'Most Collected (7 days)':
          return api.getMostCollectedShows(
            period: 'weekly',
            page: page,
            limit: limit,
          );
        case 'Most Played (7 days)':
          return api.getMostPlayedShows(
            period: 'weekly',
            page: page,
            limit: limit,
          );
        case 'Most Watched (7 days)':
          return api.getMostWatchedShows(
            period: 'weekly',
            page: page,
            limit: limit,
          );
        case 'Most Anticipated':
          return api.getMostAnticipatedShows(page: page, limit: limit);
        default:
          return [];
      }
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ShowListPage(
          title: title,
          initialShows: shows.map((show) => show.toJson()).toList(),
          extractShow: (show) => show,
          fetchShows: ({int page = 1, int limit = 20}) async {
            final shows = await fetchShows(page: page, limit: limit);
            return shows.map((show) => show.toJson()).toList();
          },
        ),
      ),
    );
  }
}
