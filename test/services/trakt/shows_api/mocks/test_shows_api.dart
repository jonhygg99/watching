import 'package:watching/services/trakt/shows_api.dart';
import 'mock_trakt_api_base.dart';

class TestShowsApi implements ShowsApi {
  final MockTraktApiBase _api;

  TestShowsApi(this._api);

  @override
  Future<void> ensureValidToken() => _api.ensureValidToken();

  @override
  Future<Map<String, dynamic>> getJsonMap(String endpoint) {
    return _api.getJsonMap(endpoint);
  }

  @override
  Future<List<dynamic>> getJsonList(String endpoint) {
    return _api.getJsonList(endpoint);
  }

  @override
  String get baseUrl => _api.baseUrl;

  @override
  Map<String, String> get headers => _api.headers;

  @override
  Future<Map<String, dynamic>> getShowById({
    required String id,
    bool extended = false,
  }) async {
    final endpoint = '/shows/$id${extended ? '?extended=full,images' : ''}';
    return await getJsonMap(endpoint);
  }

  @override
  Future<List<dynamic>> getSeasons(String showId) async {
    return await getJsonList('/shows/$showId/seasons?extended=images');
  }

  @override
  Future<List<dynamic>> getSeasonEpisodes({
    required String id,
    required int season,
    String? translations,
  }) async {
    final translationParam =
        translations != null ? '?translations=$translations' : '';
    return await getJsonList(
      '/shows/$id/seasons/$season/episodes$translationParam',
    );
  }

  @override
  Future<Map<String, dynamic>> getEpisodeInfo({
    required String id,
    required int season,
    required int episode,
    String? language,
  }) async {
    final languageParam = language != null ? '?language=$language' : '';
    return await getJsonMap(
      '/shows/$id/seasons/$season/episodes/$episode$languageParam',
    );
  }

  @override
  Future<List<dynamic>> getRelatedShows({required String id}) async {
    return await getJsonList('/shows/$id/related');
  }

  @override
  Future<List<dynamic>> getShowComments({
    required String id,
    String sort = 'newest',
    int page = 1,
    int limit = 10,
  }) async {
    return await getJsonList('/shows/$id/comments/$sort?page=$page&limit=$limit');
  }

  @override
  Future<Map<String, dynamic>> getShowRatings({required String id}) async {
    return await getJsonMap('/shows/$id/ratings');
  }

  Future<Map<String, dynamic>> getShowWatchedProgress({
    required String id,
  }) async {
    return await getJsonMap('/shows/$id/progress/watched');
  }

  Future<Map<String, dynamic>> getShowWatchingUsers({
    required String id,
  }) async {
    return await getJsonMap('/shows/$id/watching');
  }

  Future<List<dynamic>> getShowLists({required String id}) async {
    return await getJsonList('/shows/$id/lists');
  }

  Future<List<dynamic>> getShowVideos({required String id}) async {
    return [];
  }

  @override
  Future<Map<String, dynamic>> getShowPeople({
    required String id,
    bool extended = false,
  }) async {
    final endpoint =
        '/shows/$id/people${extended ? '?extended=guest_stars' : ''}';
    return await getJsonMap(endpoint);
  }

  @override
  Future<List<dynamic>> getShowTranslations({
    required String id,
    required String language,
  }) async {
    return await getJsonList('/shows/$id/translations/$language');
  }

  @override
  Future<List<dynamic>> getEpisodeComments({
    required String id,
    required int season,
    required int episode,
    String sort = 'likes',
  }) async {
    return await getJsonList(
      '/shows/$id/seasons/$season/episodes/$episode/comments/$sort',
    );
  }
}
