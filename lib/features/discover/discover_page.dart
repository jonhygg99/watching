import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watching/providers/app_providers.dart';
import 'package:watching/l10n/app_localizations.dart';
import 'package:watching/features/show_list/show_list_page.dart';
import 'package:watching/features/discover/widgets/carousel.dart';
import 'package:watching/shared/constants/measures.dart';

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
        _buildCarousel(
          context: context,
          title: l10n.trendingShows,
          future: api.getTrendingShows(),
          extractShow: (item) => item['show'],
          emptyText: '${l10n.trendingShows} - ${l10n.noResults}',
          l10n: l10n,
        ),
        const SizedBox(height: kSpaceBtwWidgets),
        _buildCarousel(
          context: context,
          title: l10n.popularShows,
          future: api.getPopularShows(),
          extractShow: (item) => Map<String, dynamic>.from(item),
          emptyText: '${l10n.popularShows} - ${l10n.noResults}',
          l10n: l10n,
        ),
        const SizedBox(height: kSpaceBtwWidgets),
        _buildCarousel(
          context: context,
          title: l10n.mostFavoritedWeekly,
          future: api.getMostFavoritedShows(period: 'weekly'),
          extractShow: (item) => item['show'],
          emptyText: '${l10n.mostFavoritedWeekly} - ${l10n.noResults}',
          l10n: l10n,
        ),
        const SizedBox(height: kSpaceBtwWidgets),
        _buildCarousel(
          context: context,
          title: l10n.mostFavoritedMonthly,
          future: api.getMostFavoritedShows(period: 'monthly'),
          extractShow: (item) => item['show'],
          emptyText: '${l10n.mostFavoritedMonthly} - ${l10n.noResults}',
          l10n: l10n,
        ),
        const SizedBox(height: kSpaceBtwWidgets),
        _buildCarousel(
          context: context,
          title: l10n.mostCollectedWeekly,
          future: api.getMostCollectedShows(period: 'weekly'),
          extractShow: (item) => item['show'],
          emptyText: '${l10n.mostCollectedWeekly} - ${l10n.noResults}',
          l10n: l10n,
        ),
        const SizedBox(height: kSpaceBtwWidgets),
        _buildCarousel(
          context: context,
          title: l10n.mostPlayedWeekly,
          future: api.getMostPlayedShows(period: 'weekly'),
          extractShow: (item) => item['show'],
          emptyText: '${l10n.mostPlayedWeekly} - ${l10n.noResults}',
          l10n: l10n,
        ),
        const SizedBox(height: kSpaceBtwWidgets),
        _buildCarousel(
          context: context,
          title: l10n.mostWatchedWeekly,
          future: api.getMostWatchedShows(period: 'weekly'),
          extractShow: (item) => item['show'],
          emptyText: '${l10n.mostWatchedWeekly} - ${l10n.noResults}',
          l10n: l10n,
        ),
        const SizedBox(height: kSpaceBtwWidgets),
        _buildCarousel(
          context: context,
          title: l10n.mostAnticipated,
          future: api.getMostAnticipatedShows(),
          extractShow:
              (item) => {
                ...Map<String, dynamic>.from(item['show']),
                'list_count': item['list_count'],
              },
          emptyText: '${l10n.mostAnticipated} - ${l10n.noResults}',
          l10n: l10n,
        ),
      ],
    );
  }

  Widget _buildCarousel({
    required BuildContext context,
    required String title,
    required Future<List<dynamic>> future,
    required Map<String, dynamic> Function(dynamic) extractShow,
    required String emptyText,
    required AppLocalizations l10n,
  }) {
    return FutureBuilder<List<dynamic>>(
      future: future,
      builder: (context, snapshot) {
        final shows = snapshot.data ?? [];
        return Carousel(
          title: title,
          future: future,
          extractShow: extractShow,
          emptyText: emptyText,
          onViewMore:
              () => _navigateToShowList(
                context: context,
                title: title,
                shows: shows,
                extractShow: extractShow,
                l10n: l10n,
              ),
        );
      },
    );
  }

  void _navigateToShowList({
    required BuildContext context,
    required String title,
    required List<dynamic> shows,
    required Map<String, dynamic> Function(dynamic) extractShow,
    required AppLocalizations l10n,
  }) {
    final api = ProviderScope.containerOf(context).read(traktApiProvider);

    Future<List<dynamic>> fetchShows({int page = 1, int limit = 20}) async {
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
}
