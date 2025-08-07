import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'search_results_grid.dart';
import 'trending_grid.dart';

/// Main search page using hooks and Riverpod for state management.
/// Main search page using Riverpod for state management.
class SearchPage extends ConsumerStatefulWidget {
  final List<dynamic>? initialTrendingShows;
  
  const SearchPage({
    super.key,
    this.initialTrendingShows,
  });

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
        initialTrendingShows: widget.initialTrendingShows,
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
  final List<dynamic>? initialTrendingShows;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<List<String>> onTypesChanged;
  const _SearchScroll({
    required this.query,
    required this.types,
    this.initialTrendingShows,
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
                  ? TrendingGrid(initialTrendingShows: initialTrendingShows)
                  : SearchResultsGrid(query: query, types: types),
        ),
      ],
    );
  }
}


