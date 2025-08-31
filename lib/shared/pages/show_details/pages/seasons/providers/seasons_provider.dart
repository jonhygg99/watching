import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:watching/api/trakt/trakt_api_provider.dart';

part 'seasons_provider.g.dart';

@riverpod
Future<List<Map<String, dynamic>>> seasons(
  Ref ref, {
  required String showId,
}) async {
  final traktApi = ref.watch(traktApiProvider);
  final seasons = await traktApi.getSeasons(showId);

  // Filter out season 0 (specials) if it has 0 episodes
  final filteredSeasons = List<Map<String, dynamic>>.from(seasons)
    ..removeWhere((season) {
      final number = season['number'];
      final episodeCount = season['episode_count'] ?? 0;
      return number == 0 && episodeCount == 0;
    });

  return filteredSeasons;
}
