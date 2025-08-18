import 'package:flutter/material.dart';
import 'package:watching/api/trakt/trakt_api.dart';
import 'package:watching/features/show_list/show_list_page.dart';

class RelatedShowsPage extends StatelessWidget {
  final String showId;
  final String showTitle;
  final TraktApi apiService;
  final List<dynamic>? initialShows;

  const RelatedShowsPage({
    super.key,
    required this.showId,
    required this.showTitle,
    required this.apiService,
    this.initialShows,
  });

  @override
  Widget build(BuildContext context) {
    return ShowListPage(
      title: 'Shows relacionados',
      initialShows: initialShows ?? const [],
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
    );
  }
}
