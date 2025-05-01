import 'package:flutter/material.dart';
import '../api_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../show_details/details_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _query = '';
  List<String> _types = ['movie', 'show']; // opciones seleccionadas

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: _SearchScroll(
        query: _query,
        types: _types,
        onQueryChanged: (value) => setState(() => _query = value),
        onTypesChanged: (types) => setState(() => _types = types),
      ),
    );
  }
}

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
                        if (newTypes.isEmpty) newTypes.add('movie');
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
                        if (newTypes.isEmpty) newTypes.add('show');
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

class _TrendingGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: apiService.getTrendingShows(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final shows = snapshot.data ?? [];
        if (shows.isEmpty) {
          return const Center(child: Text('No hay shows en tendencia.'));
        }
        return GridView.count(
          padding: const EdgeInsets.all(12),
          crossAxisCount: 3,
          childAspectRatio: 0.55,
          crossAxisSpacing: 10,
          mainAxisSpacing: 0,
          children: [
            for (final item in shows)
              _ShowGridTile(
                show: Map<String, dynamic>.from(item['show'] as Map),
                onTap: () {
                  final show = Map<String, dynamic>.from(item['show'] as Map);
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
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        );
      },
    );
  }
}

class _SearchResultsGrid extends StatelessWidget {
  final String query;
  final List<String> types;
  const _SearchResultsGrid({required this.query, required this.types});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: apiService.searchMoviesAndShows(query, types: types),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error al buscar.'));
        }
        final results = snapshot.data ?? [];
        final filtered =
            results
                .where(
                  (item) => item['type'] == 'show' || item['type'] == 'movie',
                )
                .toList();
        if (filtered.isEmpty) {
          return Center(
            child: Text('No se encontraron resultados para "$query".'),
          );
        }
        return GridView.count(
          padding: const EdgeInsets.all(12),
          crossAxisCount: 3,
          childAspectRatio: 0.55,
          crossAxisSpacing: 10,
          mainAxisSpacing: 0,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (final item in filtered)
              _ShowGridTile(
                show: Map<String, dynamic>.from(item[item['type']] as Map),
                onTap: () {
                  final show = Map<String, dynamic>.from(
                    item[item['type']] as Map,
                  );
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
  }
}

class _ShowGridTile extends StatelessWidget {
  final Map<String, dynamic> show;
  final VoidCallback? onTap;
  const _ShowGridTile({required this.show, this.onTap});

  String? getPosterUrl(dynamic posterList) {
    if (posterList is List &&
        posterList.isNotEmpty &&
        posterList.first is String) {
      final url = posterList.first as String;
      if (url.startsWith('http')) return url;
      return 'https://$url';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final images = show['images'] as Map<String, dynamic>?;
    final poster = getPosterUrl(images?['poster']);
    final title = show['title'] ?? 'Sin título';
    return LayoutBuilder(
      builder: (context, constraints) {
        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: AspectRatio(
                  aspectRatio: 0.7,
                  child:
                      poster != null
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: poster,
                              fit: BoxFit.cover,
                              placeholder:
                                  (context, url) => const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                              errorWidget:
                                  (context, url, error) =>
                                      const Icon(Icons.broken_image, size: 48),
                            ),
                          )
                          : Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image, size: 48),
                          ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
