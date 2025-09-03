import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watching/api/trakt/movies_lists_api.dart';
import 'package:watching/providers/app_providers.dart';
import 'package:watching/shared/enum/list_type.dart';

import 'package:watching/shared/models/movie_models.dart';
import 'package:watching/shared/pages/show_list/show_list_page.dart';
import 'package:watching/shared/widgets/carousel/carousel.dart';

class MovieCarousel extends StatelessWidget {
  final String title;
  final Future<List<TraktMovie>> future;
  final String emptyText;
  final ListType listType;

  const MovieCarousel({
    super.key,
    required this.title,
    required this.future,
    required this.emptyText,
    required this.listType,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TraktMovie>>(
      future: future,
      builder: (context, snapshot) {
        final movies = snapshot.data ?? [];
        return Carousel(
          title: title,
          future: future,
          extractShow: (movie) => movie.toJson(),
          emptyText: emptyText,
          onViewMore: () => _navigateToMovieList(
            context: context,
            title: title,
            movies: movies,
          ),
        );
      },
    );
  }

  void _navigateToMovieList({
    required BuildContext context,
    required String title,
    required List<TraktMovie> movies,
  }) {
    final api = ProviderScope.containerOf(context).read(traktApiProvider);

    Future<List<TraktMovie>> fetchMovies({int page = 1, int limit = 20}) async {
      switch (listType) {
        case ListType.trending:
          return api.getTrendingMovies(page: page, limit: limit);
        case ListType.popular:
          return api.getPopularMovies(page: page, limit: limit);
        case ListType.mostFavoritedWeekly:
          return api.getFavoritedMovies(
            period: TimePeriod.weekly,
            page: page,
            limit: limit,
          );
        case ListType.mostWatchedWeekly:
          return api.getWatchedMovies(
            period: TimePeriod.weekly,
            page: page,
            limit: limit,
          );
        case ListType.mostPlayedWeekly:
          return api.getPlayedMovies(
            period: TimePeriod.weekly,
            page: page,
            limit: limit,
          );
        default:
          return [];
      }
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ShowListPage(
          title: title,
          initialShows: movies.map((movie) => movie.toJson()).toList(),
          extractShow: (show) => show,
          fetchShows: ({int page = 1, int limit = 20}) async {
            final movies = await fetchMovies(page: page, limit: limit);
            return movies.map((movie) => movie.toJson()).toList();
          },
        ),
      ),
    );
  }
}
