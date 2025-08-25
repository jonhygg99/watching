import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:watching/api/trakt/trakt_api_provider.dart';

part 'season_detail_provider.g.dart';

typedef SeasonDetails = ({
  List<Map<String, dynamic>> episodes,
  Map<String, dynamic> progress,
});

@riverpod
class SeasonDetail extends _$SeasonDetail {
  @override
  Future<SeasonDetails> build({
    required String showId,
    required int seasonNumber,
    String? languageCode,
  }) async {
    final traktApi = ref.watch(traktApiProvider);

    final results = await Future.wait([
      traktApi.getSeasonEpisodes(
        id: showId,
        season: seasonNumber,
        translations: languageCode,
      ),
      traktApi.getShowWatchedProgress(id: showId),
    ]);

    final episodes = List<Map<String, dynamic>>.from(results[0] as List);
    final progress = Map<String, dynamic>.from(results[1] as Map);

    return (episodes: episodes, progress: progress);
  }

  Future<void> toggleEpisodeWatched(
    bool watched,
    int epNumber,
  ) async {
    final traktApi = ref.read(traktApiProvider);
    final action = watched ? traktApi.addToWatchHistory : traktApi.removeFromHistory;

    final payload = {
      'shows': [
        {
          'ids': {'trakt': int.parse(showId)},
          'seasons': [
            {
              'number': seasonNumber,
              'episodes': [
                {'number': epNumber}
              ]
            }
          ]
        }
      ]
    };

    await action(shows: payload['shows']);
    ref.invalidateSelf();
  }

  Future<void> toggleSeasonWatched(
    bool watched,
    List<Map<String, dynamic>> episodes,
  ) async {
    final traktApi = ref.read(traktApiProvider);
    final action = watched ? traktApi.addToWatchHistory : traktApi.removeFromHistory;

    final episodePayload = episodes.map((ep) => {'number': ep['number']}).toList();

    final payload = {
      'shows': [
        {
          'ids': {'trakt': int.parse(showId)},
          'seasons': [
            {'number': seasonNumber, 'episodes': episodePayload}
          ]
        }
      ]
    };

    await action(shows: payload['shows']);
    ref.invalidateSelf();
  }
}
