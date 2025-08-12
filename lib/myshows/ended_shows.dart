import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:watching/features/myshows/providers/my_shows_provider.dart';
import 'package:watching/myshows/widgets/show_poster.dart';

// A helper function to safely convert dynamic maps to Map<String, dynamic>
Map<String, dynamic> _convertToTypedMap(dynamic data) {
  if (data is Map<String, dynamic>) {
    return data;
  } else if (data is Map) {
    return Map<String, dynamic>.from(data);
  }
  return <String, dynamic>{};
}

class EndedShows extends ConsumerStatefulWidget {
  const EndedShows({super.key});

  @override
  ConsumerState<EndedShows> createState() => _EndedShowsState();
}

class _EndedShowsState extends ConsumerState<EndedShows> {
  // Cache for ended shows to prevent unnecessary rebuilds
  List<Map<String, dynamic>> _cachedEndedShows = [];
  
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myShowsWithStatusProvider);
    
    // Only process shows if we have data and we're not refreshing
    if (!state.isRefreshing && state.hasData) {
      // Convert and filter shows that have ended
      final List<Map<String, dynamic>> endedShows = [];

      for (final item in state.items) {
        try {
          // Safely convert the item to a typed map
          final typedItem = _convertToTypedMap(item);
          
          // Get the show data, which might be nested under 'show' key or the item itself
          final showData = typedItem['show'] ?? typedItem;
          final typedShow = _convertToTypedMap(showData);
          
          // Check if the show has ended
          final status = (typedShow['status'] ?? '').toString().toLowerCase();
          if (status == 'ended') {
            // Create a new map with the show data
            final showWithStatus = Map<String, dynamic>.from(typedItem);
            showWithStatus['show'] = typedShow;
            endedShows.add(showWithStatus);
          }
        } catch (e) {
          debugPrint('Error processing show: $e');
        }
      }
      
      // Only update cache if we have shows to prevent unnecessary rebuilds
      if (endedShows.isNotEmpty) {
        _cachedEndedShows = endedShows;
      }
    }

    // Show loading indicator if data is being loaded for the first time
    if (state.isLoading && !state.hasData) {
      return const Center(child: CircularProgressIndicator());
    }
    
    // Show error message if there was an error
    if (state.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Error loading shows: ${state.error}',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    // Don't show anything if we don't have any ended shows
    if (_cachedEndedShows.isEmpty) {
      return const SizedBox.shrink();
    }

    // Calculate height based on number of rows needed (3 items per row)
    final rowCount = (_cachedEndedShows.length / 3).ceil();
    final itemHeight = 200.0; // Approximate height of each item
    final gridHeight = (rowCount * itemHeight) + 60.0; // Add some padding

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Ended Shows (${_cachedEndedShows.length})',
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
            itemCount: _cachedEndedShows.length,
            itemBuilder: (context, index) {
              final showData = _cachedEndedShows[index];
              final show = _convertToTypedMap(showData['show'] ?? showData);
              return ShowPoster(show: show);
            },
          ),
        ),
      ],
    );
  }
}
