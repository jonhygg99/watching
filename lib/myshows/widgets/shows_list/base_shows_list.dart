import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:watching/l10n/app_localizations.dart';
import 'package:watching/pages/myshows/providers/my_shows_provider.dart';
import 'package:watching/myshows/widgets/shows_list/show_grid.dart';

/// A helper function to safely convert dynamic maps to Map<String, dynamic>
Map<String, dynamic> convertToTypedMap(dynamic data) {
  if (data is Map<String, dynamic>) {
    return data;
  } else if (data is Map) {
    return Map<String, dynamic>.from(data);
  }
  return <String, dynamic>{};
}

/// Base abstract class for shows lists
abstract class BaseShowsList extends ConsumerStatefulWidget {
  final String title;

  const BaseShowsList({super.key, required this.title});

  @override
  ConsumerState<BaseShowsList> createState();

  bool shouldIncludeShow(Map<String, dynamic> showData);
}

/// Base state class for shows lists
abstract class BaseShowsListState<T extends BaseShowsList>
    extends ConsumerState<T> {
  // Cache for shows to prevent unnecessary rebuilds
  @protected
  List<Map<String, dynamic>> cachedShows = [];

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
          cachedShows = [];
        });
      }
      return;
    }

    final List<Map<String, dynamic>> filteredShows = [];

    for (final item in state.items) {
      try {
        // Safely convert the item to a typed map
        final typedItem = convertToTypedMap(item);
        // Get the show data, which might be nested under 'show' key or the item itself
        final showData = typedItem['show'] ?? typedItem;
        final typedShow = convertToTypedMap(showData);

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
      cachedShows.map((e) => e['show']?['ids']?['trakt']).toList(),
      filteredShows.map((e) => e['show']?['ids']?['trakt']).toList(),
    )) {
      if (mounted) {
        setState(() {
          cachedShows = filteredShows;
        });
      }
    }
  }

  @protected
  Widget buildHeader(MyShowsState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.title} (${cachedShows.length})',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          if (state.isLoading || state.isRefreshing) const SizedBox(height: 8),
          if (state.isLoading || state.isRefreshing)
            const LinearProgressIndicator(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myShowsWithStatusProvider);

    // Process shows whenever the state changes
    processShows(state);

    if (state.error != null) {
      return Center(
        child: Text(AppLocalizations.of(context)!.errorLoadingShows),
      );
    }

    // Don't show anything if we don't have any shows and not loading
    if (cachedShows.isEmpty && !state.isLoading) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [buildHeader(state), ShowGrid(shows: cachedShows)],
    );
  }
}
