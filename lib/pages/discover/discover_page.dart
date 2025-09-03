import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watching/providers/app_providers.dart';
import 'package:watching/l10n/app_localizations.dart';
import 'package:watching/shared/enum/list_type.dart';
import 'package:watching/shared/widgets/carousel/widgets/movie_carousel.dart';
import 'package:watching/shared/widgets/carousel/widgets/show_carousel.dart';
import 'package:watching/shared/constants/measures.dart';
import 'package:watching/api/trakt/movies_lists_api.dart';

/// DiscoverPage displays curated carousels of TV shows using data from Trakt API.
class DiscoverPage extends ConsumerWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final api = ref.watch(traktApiProvider);
    final l10n = AppLocalizations.of(context)!;

    return ListView(
      key: const PageStorageKey('discover-list'),
      padding: const EdgeInsets.symmetric(vertical: kPhoneSpaceVertical),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        // Movies Section
        MovieCarousel(
          listType: ListType.trending,
          title: l10n.trendingMovies,
          future: api.getTrendingMovies(),
          emptyText: '${l10n.trendingMovies} - ${l10n.noResults}',
        ),
        const SizedBox(height: kSpaceBtwWidgets),
        MovieCarousel(
          listType: ListType.popular,
          title: l10n.popularMovies,
          future: api.getPopularMovies(),
          emptyText: '${l10n.popularMovies} - ${l10n.noResults}',
        ),
        const SizedBox(height: kSpaceBtwWidgets),
        MovieCarousel(
          listType: ListType.mostFavoritedWeekly,
          title: l10n.weeklyFavoritedMovies,
          future: api.getFavoritedMovies(period: TimePeriod.weekly),
          emptyText: '${l10n.weeklyFavoritedMovies} - ${l10n.noResults}',
        ),
        const SizedBox(height: kSpaceBtwWidgets),
        MovieCarousel(
          listType: ListType.mostWatchedWeekly,
          title: l10n.weeklyWatchedMovies,
          future: api.getWatchedMovies(period: TimePeriod.weekly),
          emptyText: '${l10n.weeklyWatchedMovies} - ${l10n.noResults}',
        ),
        const SizedBox(height: kSpaceBtwWidgets),
        MovieCarousel(
          listType: ListType.mostPlayedWeekly,
          title: l10n.weeklyPlayedMovies,
          future: api.getPlayedMovies(period: TimePeriod.weekly),
          emptyText: '${l10n.weeklyPlayedMovies} - ${l10n.noResults}',
        ),
        const SizedBox(height: kSpaceBtwWidgets),
        ShowCarousel(
          listType: ListType.trending,
          title: l10n.trendingShows,
          future: api.getTrendingShows(),
          emptyText: '${l10n.trendingShows} - ${l10n.noResults}',
        ),
        const SizedBox(height: kSpaceBtwWidgets),
        ShowCarousel(
          listType: ListType.popular,
          title: l10n.popularShows,
          future: api.getPopularShows(),
          emptyText: '${l10n.popularShows} - ${l10n.noResults}',
        ),
        const SizedBox(height: kSpaceBtwWidgets),
        ShowCarousel(
          listType: ListType.mostFavoritedWeekly,
          title: l10n.mostFavoritedWeekly,
          future: api.getMostFavoritedShows(period: 'weekly'),
          emptyText: '${l10n.mostFavoritedWeekly} - ${l10n.noResults}',
        ),
        const SizedBox(height: kSpaceBtwWidgets),
        ShowCarousel(
          listType: ListType.mostFavoritedMonthly,
          title: l10n.mostFavoritedMonthly,
          future: api.getMostFavoritedShows(period: 'monthly'),
          emptyText: '${l10n.mostFavoritedMonthly} - ${l10n.noResults}',
        ),
        const SizedBox(height: kSpaceBtwWidgets),
        ShowCarousel(
          listType: ListType.mostCollectedWeekly,
          title: l10n.mostCollectedWeekly,
          future: api.getMostCollectedShows(period: 'weekly'),
          emptyText: '${l10n.mostCollectedWeekly} - ${l10n.noResults}',
        ),
        const SizedBox(height: kSpaceBtwWidgets),
        ShowCarousel(
          listType: ListType.mostPlayedWeekly,
          title: l10n.mostPlayedWeekly,
          future: api.getMostPlayedShows(period: 'weekly'),
          emptyText: '${l10n.mostPlayedWeekly} - ${l10n.noResults}',
        ),
        const SizedBox(height: kSpaceBtwWidgets),
        ShowCarousel(
          listType: ListType.mostWatchedWeekly,
          title: l10n.mostWatchedWeekly,
          future: api.getMostWatchedShows(period: 'weekly'),
          emptyText: '${l10n.mostWatchedWeekly} - ${l10n.noResults}',
        ),
        const SizedBox(height: kSpaceBtwWidgets),
        ShowCarousel(
          listType: ListType.mostAnticipated,
          title: l10n.mostAnticipated,
          future: api.getMostAnticipatedShows(),
          emptyText: '${l10n.mostAnticipated} - ${l10n.noResults}',
        ),
      ],
    );
  }
}
