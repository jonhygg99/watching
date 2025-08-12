import 'package:flutter_riverpod/flutter_riverpod.dart';

final upcomingEpisodesProvider = StateNotifierProvider<UpcomingEpisodesNotifier, AsyncValue<Set<int>>>(
  (ref) => UpcomingEpisodesNotifier(),
);

class UpcomingEpisodesNotifier extends StateNotifier<AsyncValue<Set<int>>> {
  UpcomingEpisodesNotifier() : super(const AsyncValue.loading());
  
  void setShowsWithUpcomingEpisodes(Set<int> showIds) {
    state = AsyncValue.data(showIds);
  }
  
  void startLoading() {
    state = const AsyncValue.loading();
  }
  
  void setError(String error) {
    state = AsyncValue.error(error, StackTrace.current);
  }
}
