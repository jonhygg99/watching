import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../api/trakt/show_translation.dart';
import '../shared/pages/show_details/details_page.dart';
import 'search_result_item.dart';

/// Grid for search results using Freezed model and improved tile widget.
class SearchResultsGrid extends ConsumerWidget {
  final String query;
  final List<String> types;

  const SearchResultsGrid({
    super.key,
    required this.query,
    required this.types,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Show message if no types are selected
    if (types.isEmpty) {
      return const Center(
        child: Text('Selecciona al menos un tipo (Película o Serie)'),
      );
    }

    final api = ref.watch(traktApiProvider);
    final translationService = ref.watch(showTranslationServiceProvider);
    final countryCode = ref.watch(countryCodeProvider);
    final searchType = types.join(',');

    return FutureBuilder<Map<String, dynamic>>(
      future:
          query.isNotEmpty
              ? api.searchMoviesAndShows(query: query, type: searchType)
              : Future.value({'items': []}),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error al buscar.'));
        }

        final results = snapshot.data?['items'] ?? [];
        final filtered =
            (results as List<dynamic>)
                .where(
                  (item) => item['type'] == 'show' || item['type'] == 'movie',
                )
                .toList();

        if (filtered.isEmpty) {
          return Center(
            child: Text(
              query.isEmpty
                  ? 'Ingresa un término de búsqueda'
                  : 'No se encontraron resultados para "$query".',
            ),
          );
        }

        // Process items to get translated titles for shows
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: Future.wait(
            filtered.map((item) async {
              final type = item['type'] as String;
              var itemData = Map<String, dynamic>.from(item[type] as Map);

              // Only translate if it's a show and we have a country code
              if (type == 'show' && countryCode.isNotEmpty) {
                final title = await translationService.getTranslatedTitle(
                  show: itemData,
                  traktApi: api,
                );
                if (title != itemData['title']) {
                  itemData = Map<String, dynamic>.from(itemData)
                    ..['title'] = title;
                }
              }

              return {
                'type': type,
                'data': itemData,
                'originalData': item[type],
              };
            }),
          ),
          builder: (context, processedSnapshot) {
            if (processedSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final processedItems = processedSnapshot.data ?? [];

            return GridView.count(
              padding: const EdgeInsets.all(12),
              crossAxisCount: 3,
              childAspectRatio: 0.55,
              crossAxisSpacing: 10,
              mainAxisSpacing: 0,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (final item in processedItems)
                  SearchResultGridTile(
                    item: SearchResultItem(
                      data: item['data'],
                      type: item['type'] as String,
                    ),
                    onTap: () {
                      final show = item['originalData'];
                      final showId =
                          show['ids']?['trakt']?.toString() ??
                          show['ids']?['slug'] ??
                          '';
                      if (showId.isEmpty) return;
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ShowDetailPage(showId: showId),
                        ),
                      );
                    },
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
