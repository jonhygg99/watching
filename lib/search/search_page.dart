import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../show_details/details_page.dart';
import 'search_result_item.dart';
import '../api/trakt/show_translation.dart';

/// Main search page using hooks and Riverpod for state management.
/// Main search page using Riverpod for state management.
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  String query = '';
  List<String> types = ['movie', 'show'];

  void _onQueryChanged(String value) => setState(() => query = value);
  void _onTypesChanged(List<String> newTypes) =>
      setState(() => types = newTypes);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: _SearchScroll(
        query: query,
        types: types,
        onQueryChanged: _onQueryChanged,
        onTypesChanged: _onTypesChanged,
      ),
    );
  }
}

/// Search scroll view with filter chips and results grid. Stateless, receives all state via props.
class _SearchScroll extends StatelessWidget {
  final String query;
  final List<String> types;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<List<String>> onTypesChanged;
  const _SearchScroll({
    required this.query,
    required this.types,
    required this.onQueryChanged,
    required this.onTypesChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Buscar...',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: onQueryChanged,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('Películas'),
                      selected: types.contains('movie'),
                      onSelected: (selected) {
                        final newTypes = List<String>.from(types);
                        if (selected) {
                          newTypes.add('movie');
                        } else {
                          newTypes.remove('movie');
                        }
                        onTypesChanged(newTypes);
                      },
                    ),
                    FilterChip(
                      label: const Text('Series'),
                      selected: types.contains('show'),
                      onSelected: (selected) {
                        final newTypes = List<String>.from(types);
                        if (selected) {
                          newTypes.add('show');
                        } else {
                          newTypes.remove('show');
                        }
                        onTypesChanged(newTypes);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 10)),
        SliverToBoxAdapter(
          child:
              query.isEmpty
                  ? _TrendingGrid()
                  : _SearchResultsGrid(query: query, types: types),
        ),
      ],
    );
  }
}

/// Grid for trending shows using Freezed model and improved tile widget.
class _TrendingGrid extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final api = ref.watch(traktApiProvider);
    final translationService = ref.watch(showTranslationServiceProvider);
    final countryCode = ref.watch(countryCodeProvider);
    
    return FutureBuilder<List<dynamic>>(
      future: api.getTrendingShows(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final shows = snapshot.data ?? [];
        if (shows.isEmpty) {
          return const Center(child: Text('No hay shows en tendencia.'));
        }
        
        // Process shows to get translated titles
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: Future.wait(shows.map((item) async {
            var showData = Map<String, dynamic>.from(item['show'] as Map);
            
            // Only translate if it's a show
            if (countryCode.isNotEmpty) {
              final title = await translationService.getTranslatedTitle(
                show: showData,
                traktApi: api,
              );
              if (title != showData['title']) {
                showData = Map<String, dynamic>.from(showData)..['title'] = title;
              }
            }
            
            return {
              'show': showData,
              'originalShow': item['show'],
            };
          })),
          builder: (context, processedSnapshot) {
            if (processedSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            final processedShows = processedSnapshot.data ?? [];
            
            return GridView.count(
              padding: const EdgeInsets.all(12),
              crossAxisCount: 3,
              childAspectRatio: 0.55,
              crossAxisSpacing: 10,
              mainAxisSpacing: 0,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (final item in processedShows)
                  SearchResultGridTile(
                    item: SearchResultItem(
                      data: item['show'],
                      type: 'show',
                    ),
                    onTap: () {
                      final show = item['originalShow'];
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

/// Grid for search results using Freezed model and improved tile widget.
class _SearchResultsGrid extends ConsumerWidget {
  final String query;
  final List<String> types;
  const _SearchResultsGrid({required this.query, required this.types});

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
    
    return FutureBuilder<List<dynamic>>(
      future: query.isNotEmpty 
          ? api.searchMoviesAndShows(query: query, type: searchType)
          : Future.value([]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error al buscar.'));
        }
        final results = snapshot.data ?? [];
        final filtered = results
            .where((item) => item['type'] == 'show' || item['type'] == 'movie')
            .toList();
            
        if (filtered.isEmpty) {
          return Center(
            child: Text('No se encontraron resultados para "$query".'),
          );
        }
        
        // Process items to get translated titles for shows
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: Future.wait(filtered.map((item) async {
            final type = item['type'] as String;
            var itemData = Map<String, dynamic>.from(item[type] as Map);
            
            // Only translate if it's a show and we have a country code
            if (type == 'show' && countryCode.isNotEmpty) {
              final title = await translationService.getTranslatedTitle(
                show: itemData,
                traktApi: api,
              );
              if (title != itemData['title']) {
                itemData = Map<String, dynamic>.from(itemData)..['title'] = title;
              }
            }
            
            return {
              'type': type,
              'data': itemData,
              'originalData': item[type],
            };
          })),
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
