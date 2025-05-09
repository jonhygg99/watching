import 'dart:convert';
import 'package:http/http.dart' as http;
import 'trakt_api.dart';

/// Mixin for show and season-related endpoints.
mixin ShowsApi on TraktApiBase {
  /// Gets detailed info for a show by ID.
  Future<Map<String, dynamic>> getEpisodeInfo({
    required String id,
    required int season,
    required int episode,
  }) async {
    await ensureValidToken();
    final url = Uri.parse(
      '$baseUrl/shows/$id/seasons/$season/episodes/$episode?extended=full,images',
    );
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
        'Error GET /shows/$id/seasons/$season/episodes/$episode: ${response.statusCode}\n${response.body}',
      );
    }
  }

  /// Gets all seasons for a show.
  Future<List<dynamic>> getSeasons(String showId) async {
    await ensureValidToken();
    final url = Uri.parse('$baseUrl/shows/$showId/seasons?extended=images');
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception(
        'Error GET /shows/$showId/seasons:\n${response.statusCode}\n${response.body}',
      );
    }
  }

  /// Gets detailed info for a show by ID.
  Future<Map<String, dynamic>> getShowById({required String id}) async {
    return await getJsonMap('/shows/$id?extended=full,images,');
  }

  /// Gets comments for a show by ID.
  Future<List<dynamic>> getShowComments({
    required String id,
    String sort = 'newest',
  }) async {
    return await getJsonList('/shows/$id/comments?sort=$sort');
  }

  /// Gets ratings for a show by ID.
  Future<Map<String, dynamic>> getShowRatings({required String id}) async {
    return await getJsonMap('/shows/$id/ratings');
  }

  /// Gets watched progress for a show.
  Future<Map<String, dynamic>> getShowWatchedProgress({
    required String id,
  }) async {
    return await getJsonMap(
      '/shows/$id/progress/watched?hidden=false&specials=false&count_specials=false',
    );
  }

  /// Gets people (cast/crew) for a show.
  Future<Map<String, dynamic>> getShowPeople({
    required String id,
    bool extended = false,
  }) async {
    if (extended) {
      return await getJsonMap('/shows/$id/people?extended=guest_stars');
    }
    return await getJsonMap('/shows/$id/people');
  }

  /// Gets translations for a show.
  Future<List<dynamic>> getShowTranslations({
    required String id,
    String language = 'es',
  }) async {
    return await getJsonList('/shows/$id/translations?language=$language');
  }

  /// Gets videos (trailers, teasers) for a show.
  Future<List<dynamic>> getShowVideos({required String id}) async {
    return await getJsonList('/shows/$id/videos');
  }

  /// Gets related shows for a show.
  Future<List<dynamic>> getRelatedShows({required String id}) async {
    return await getJsonList('/shows/$id/related?extended=images');
  }

  /// Gets trending shows.
  Future<List<dynamic>> getTrendingShows() async {
    return await getJsonList('/shows/trending?extended=images');
  }

  /// Gets popular shows.
  Future<List<dynamic>> getPopularShows() async {
    return await getJsonList('/shows/popular?extended=images');
  }

  /// Gets most favorited shows.
  Future<List<dynamic>> getMostFavoritedShows({
    String period = 'monthly',
  }) async {
    return await getJsonList('/shows/favorited?extended=images');
  }

  /// Gets most collected shows.
  Future<List<dynamic>> getMostCollectedShows({
    String period = 'monthly',
  }) async {
    return await getJsonList('/shows/collected/$period?extended=images');
  }

  /// Gets most played shows.
  Future<List<dynamic>> getMostPlayedShows({String period = 'monthly'}) async {
    return await getJsonList('/shows/played/$period?extended=images');
  }

  /// Gets most watched shows.
  Future<List<dynamic>> getMostWatchedShows({String period = 'monthly'}) async {
    return await getJsonList('/shows/watched/$period?extended=images');
  }

  /// Gets most anticipated shows.
  Future<List<dynamic>> getMostAnticipatedShows() async {
    return await getJsonList('/shows/anticipated?extended=images');
  }

  /// Searches for movies and shows by query.
  Future<List<dynamic>> searchMoviesAndShows({
    required String query,
    String type = '',
  }) async {
    final encodedQuery = Uri.encodeComponent(query);
    return await getJsonList('/search/multi?query=$encodedQuery&type=$type');
  }
}
