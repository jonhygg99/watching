import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:watching/features/myshows/providers/my_shows_provider.dart';
import 'package:watching/myshows/widgets/show_poster.dart';
import 'package:watching/show_details/details_page.dart';

// A helper function to safely convert dynamic maps to Map<String, dynamic>
Map<String, dynamic> _convertToTypedMap(dynamic data) {
  if (data is Map<String, dynamic>) {
    return data;
  } else if (data is Map) {
    return Map<String, dynamic>.from(data);
  }
  return <String, dynamic>{};
}

abstract class BaseShowsList extends ConsumerStatefulWidget {
  final String title;

  const BaseShowsList({super.key, required this.title});

  @override
  ConsumerState<BaseShowsList> createState();

  bool shouldIncludeShow(Map<String, dynamic> showData);
}

abstract class BaseShowsListState<T extends BaseShowsList>
    extends ConsumerState<T> {
  // Cache for shows to prevent unnecessary rebuilds
  List<Map<String, dynamic>> _cachedShows = [];

  @override
  void initState() {
    super.initState();
    // Schedule the initial load after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadShows();
    });
  }

  Future<void> _loadShows() async {
    try {
      final notifier = ref.read(myShowsWithStatusProvider.notifier);
      await notifier.refresh();
    } catch (e) {
      debugPrint('Error loading shows: $e');
    }
  }

  @protected
  void processShows(MyShowsState state) {
    if (state.isLoading) {
      // Don't update cache while loading to prevent flickering
      return;
    }

    if (state.error != null) {
      // Clear cache if there's an error
      if (mounted) {
        setState(() {
          _cachedShows = [];
        });
      }
      return;
    }

    final List<Map<String, dynamic>> filteredShows = [];

    for (final item in state.items) {
      try {
        // Safely convert the item to a typed map
        final typedItem = _convertToTypedMap(item);
        // Get the show data, which might be nested under 'show' key or the item itself
        final showData = typedItem['show'] ?? typedItem;
        final typedShow = _convertToTypedMap(showData);

        // Let the child class decide if this show should be included
        if (widget.shouldIncludeShow(typedShow)) {
          // Create a new map with the show data
          final showWithStatus = Map<String, dynamic>.from(typedItem);
          showWithStatus['show'] = typedShow;
          filteredShows.add(showWithStatus);
        }
      } catch (e) {
        debugPrint('Error processing show: $e');
      }
    }

    // Only update cache if the shows have changed
    if (!listEquals(
      _cachedShows.map((e) => e['show']?['ids']?['trakt']).toList(),
      filteredShows.map((e) => e['show']?['ids']?['trakt']).toList(),
    )) {
      if (mounted) {
        setState(() {
          _cachedShows = filteredShows;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myShowsWithStatusProvider);
    
    // Process shows whenever the state changes
    processShows(state);

    if (state.isLoading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(child: Text('Error: ${state.error}'));
    }

    // Don't show anything if we don't have any shows
    if (_cachedShows.isEmpty) {
      return const SizedBox.shrink();
    }

    // Calculate height based on number of rows needed (3 items per row)
    final rowCount = (_cachedShows.length / 3).ceil();
    final itemHeight = 200.0; // Approximate height of each item
    final gridHeight = (rowCount * itemHeight) + 60.0; // Add some padding

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            '${widget.title} (${_cachedShows.length})',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: gridHeight,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.6,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: _cachedShows.length,
            itemBuilder: (context, index) {
              final showData = _cachedShows[index];
              final show = _convertToTypedMap(showData['show'] ?? showData);
              final traktId =
                  show['ids']?['trakt']?.toString() ??
                  show['ids']?['slug']?.toString();

              return GestureDetector(
                onTap: () {
                  if (traktId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ShowDetailPage(showId: traktId),
                      ),
                    );
                  }
                },
                child: ShowPoster(show: show),
              );
            },
          ),
        ),
      ],
    );
  }
}
