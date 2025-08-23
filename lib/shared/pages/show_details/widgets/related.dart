import 'package:flutter/material.dart';
import 'package:watching/api/trakt/trakt_api.dart';
import 'package:watching/l10n/app_localizations.dart';
import 'package:watching/shared/pages/show_list/show_list_page.dart';
import 'package:watching/shared/widgets/carousel/carousel.dart';

class ShowDetailRelated extends StatelessWidget {
  final List<dynamic>? relatedShows;
  final TraktApi apiService;
  final String showId;

  const ShowDetailRelated({
    super.key,
    required this.relatedShows,
    required this.apiService,
    required this.showId,
  });

  @override
  Widget build(BuildContext context) {
    if (relatedShows == null || relatedShows!.isEmpty) {
      return const SizedBox.shrink();
    }
    return FutureBuilder<Map<String, dynamic>>(
      future: apiService.getRelatedShows(id: showId, page: 1),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        final shows = (snapshot.data?['shows'] as List<dynamic>?) ?? [];

        return Carousel(
          title: AppLocalizations.of(context)!.relatedShows,
          future: Future.value(shows),
          extractShow: (item) => item,
          emptyText: AppLocalizations.of(context)!.noResults,
          onViewMore: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => ShowListPage(
                      title: AppLocalizations.of(context)!.relatedShows,
                      initialShows: relatedShows ?? const [],
                      extractShow: (show) => show,
                      fetchShows: ({int page = 1, int limit = 10}) async {
                        try {
                          final response = await apiService.getRelatedShows(
                            id: showId,
                            page: page,
                          );
                          return response['shows'] as List<dynamic>;
                        } catch (e) {
                          debugPrint('Error fetching related shows: $e');
                          rethrow;
                        }
                      },
                    ),
              ),
            );
          },
        );
      },
    );
  }
}
