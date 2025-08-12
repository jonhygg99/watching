import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:watching/features/myshows/providers/upcoming_episodes_provider.dart';
import 'package:watching/myshows/base_shows_list.dart';
import 'package:watching/shared/constants/show_status.dart';

class WaitingShows extends ConsumerWidget {
  const WaitingShows({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcomingEpisodesAsync = ref.watch(upcomingEpisodesProvider);

    return upcomingEpisodesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading upcoming episodes: $error'),
      ),
      data: (showsWithUpcomingEpisodes) {
        return _WaitingShowsContent(
          showsWithUpcomingEpisodes: showsWithUpcomingEpisodes,
        );
      },
    );
  }
}

class _WaitingShowsContent extends BaseShowsList {
  final Set<int> showsWithUpcomingEpisodes;

  const _WaitingShowsContent({
    required this.showsWithUpcomingEpisodes,
  }) : super(title: 'Upcoming Shows');

  @override
  ConsumerState<BaseShowsList> createState() => _WaitingShowsState();

  @override
  bool shouldIncludeShow(Map<String, dynamic> showData) {
    final status = (showData['status'] ?? '').toString();
    final traktId = (showData['ids']?['trakt'] ?? 0) as int;
    
    // Include shows that are active (not ended/canceled) and don't have upcoming episodes
    return ShowStatus.isActive(status) && 
           !ShowStatus.isEnded(status) &&
           !showsWithUpcomingEpisodes.contains(traktId);
  }
}

class _WaitingShowsState extends BaseShowsListState<_WaitingShowsContent> {}
