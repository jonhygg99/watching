import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watching/providers/app_providers.dart';
import 'package:watching/shared/enum/list_type.dart';
import 'package:watching/shared/models/show_models.dart';
import 'package:watching/shared/pages/show_list/show_list_page.dart';
import 'package:watching/shared/widgets/carousel/carousel.dart';

class ShowCarousel extends StatelessWidget {
  final String title;
  final Future<List<TraktShow>> future;
  final String emptyText;
  final ListType listType;

  const ShowCarousel({
    super.key,
    required this.title,
    required this.future,
    required this.emptyText,
    required this.listType,
  });

  @override
  Widget build(BuildContext context) {
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
      switch (listType) {
        case ListType.trending:
          return api.getTrendingShows(page: page, limit: limit);
        case ListType.popular:
          return api.getPopularShows(page: page, limit: limit);
        case ListType.mostFavoritedWeekly:
          return api.getMostFavoritedShows(
            period: 'weekly',
            page: page,
            limit: limit,
          );
        case ListType.mostFavoritedMonthly:
          return api.getMostFavoritedShows(
            period: 'monthly',
            page: page,
            limit: limit,
          );
        case ListType.mostCollectedWeekly:
          return api.getMostCollectedShows(
            period: 'weekly',
            page: page,
            limit: limit,
          );
        case ListType.mostPlayedWeekly:
          return api.getMostPlayedShows(
            period: 'weekly',
            page: page,
            limit: limit,
          );
        case ListType.mostWatchedWeekly:
          return api.getMostWatchedShows(
            period: 'weekly',
            page: page,
            limit: limit,
          );
        case ListType.mostAnticipated:
          return api.getMostAnticipatedShows(page: page, limit: limit);
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
