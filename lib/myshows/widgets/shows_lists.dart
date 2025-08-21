import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:watching/l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:watching/pages/myshows/providers/my_shows_provider.dart';
import 'package:watching/myshows/widgets/show_poster.dart';
import 'package:watching/shared/pages/show_details/details_page.dart';
import 'package:watching/shared/constants/show_status.dart';
import 'package:watching/pages/myshows/providers/upcoming_episodes_provider.dart';

extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

// A helper function to safely convert dynamic maps to Map<String, dynamic>
Map<String, dynamic> _convertToTypedMap(dynamic data) {
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

    if (state.error != null) {
      return Center(child: Text(context.l10n.errorLoadingShows));
    }

    // Don't show anything if we don't have any shows and not loading
    if (_cachedShows.isEmpty && !state.isLoading) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${widget.title} (${_cachedShows.length})',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (state.isLoading || state.isRefreshing)
                const SizedBox(height: 8),
              if (state.isLoading || state.isRefreshing)
                const LinearProgressIndicator(),
            ],
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            // Calculate the available width for the grid
            final width = constraints.maxWidth;
            // Calculate item width (3 items per row with spacing)
            const crossAxisCount = 3;
            const spacing = 8.0;
            final itemWidth =
                (width - (spacing * (crossAxisCount - 1)) - 16.0) /
                crossAxisCount;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 0.6,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                mainAxisExtent: itemWidth * 1.67, // Keep aspect ratio
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
            );
          },
        ),
      ],
    );
  }
}

/// Type of shows to display in the list
enum ShowsListType { ended, waiting }

/// A configurable widget that can display different types of shows
class ShowsList extends ConsumerWidget {
  final ShowsListType type;
  final String? title;

  const ShowsList({super.key, required this.type, this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (type == ShowsListType.waiting) {
      final upcomingEpisodesAsync = ref.watch(upcomingEpisodesProvider);

      return upcomingEpisodesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stack) =>
                Center(child: Text(context.l10n.errorLoadingUpcomingEpisodes)),
        data: (showsWithUpcomingEpisodes) {
          return _ShowsListContent(
            type: type,
            title: title,
            showsWithUpcomingEpisodes: showsWithUpcomingEpisodes,
          );
        },
      );
    }

    // For ended shows, we don't need to wait for any additional data
    return _ShowsListContent(
      type: type,
      title: title,
      showsWithUpcomingEpisodes: const {},
    );
  }
}

class _ShowsListContent extends BaseShowsList {
  final ShowsListType type;
  final Set<int> showsWithUpcomingEpisodes;
  final String? _title;

  _ShowsListContent({
    required this.type,
    String? title,
    required this.showsWithUpcomingEpisodes,
  }) : _title = title,
       super(title: '');

  @override
  _ShowsListContentState createState() => _ShowsListContentState();

  @override
  bool shouldIncludeShow(Map<String, dynamic> showData) {
    final status = (showData['status'] ?? '').toString();

    if (type == ShowsListType.ended) {
      return ShowStatus.isEnded(status);
    } else {
      // For waiting shows, only include active shows that don't have upcoming episodes
      final showId = showData['ids']?['trakt']?.toString();
      return ShowStatus.isActive(status) &&
          showId != null &&
          !showsWithUpcomingEpisodes.contains(int.tryParse(showId));
    }
  }
}

class _ShowsListContentState extends BaseShowsListState<_ShowsListContent> {
  @override
  Widget build(BuildContext context) {
    // Use the custom title if provided, otherwise use the default based on type
    final title =
        widget._title ??
        (widget.type == ShowsListType.ended
            ? context.l10n.endedShows
            : context.l10n.upcomingShows);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            '$title (${_cachedShows.length})',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        _buildShowGrid(),
      ],
    );
  }

  Widget _buildShowGrid() {
    final state = ref.watch(myShowsWithStatusProvider);
    processShows(state);

    if (state.error != null) {
      return Center(child: Text(context.l10n.errorLoadingShows));
    }

    if (_cachedShows.isEmpty && !state.isLoading) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        const crossAxisCount = 3;
        const spacing = 8.0;
        final itemWidth =
            (width - (spacing * (crossAxisCount - 1)) - 16.0) / crossAxisCount;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.6,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            mainAxisExtent: itemWidth * 1.67,
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
        );
      },
    );
  }
}
