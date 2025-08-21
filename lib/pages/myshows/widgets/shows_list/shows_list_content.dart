import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:watching/l10n/app_localizations.dart';
import 'package:watching/pages/myshows/widgets/shows_list/show_grid.dart';
import 'package:watching/pages/myshows/providers/my_shows_provider.dart';
import 'package:watching/pages/myshows/providers/upcoming_episodes_provider.dart';
import 'package:watching/pages/myshows/widgets/shows_list/base_shows_list.dart';
import 'package:watching/shared/constants/show_status.dart';

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
            (error, stack) => Center(
              child: Text(
                AppLocalizations.of(context)!.errorLoadingUpcomingEpisodes,
              ),
            ),
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
    final state = ref.watch(myShowsWithStatusProvider);
    processShows(state);

    if (state.error != null) {
      return Center(
        child: Text(AppLocalizations.of(context)!.errorLoadingShows),
      );
    }

    if (cachedShows.isEmpty && !state.isLoading) {
      return const SizedBox.shrink();
    }

    // Use the custom title if provided, otherwise use the default based on type
    final title =
        widget._title ??
        (widget.type == ShowsListType.ended
            ? AppLocalizations.of(context)!.endedShows
            : AppLocalizations.of(context)!.upcomingShows);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            '$title (${cachedShows.length})',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        ShowGrid(shows: cachedShows),
      ],
    );
  }
}
