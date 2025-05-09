import 'dart:convert';
import 'package:http/http.dart' as http;
import 'trakt_api.dart';

/// Mixin for watch history endpoints.
mixin HistoryApi on TraktApiBase {
  /// Adds movies, shows, seasons, or episodes to the user's watch history.
  Future<void> addToWatchHistory({
    List<Map<String, dynamic>>? movies,
    List<Map<String, dynamic>>? shows,
    List<Map<String, dynamic>>? seasons,
    List<Map<String, dynamic>>? episodes,
  }) async {
    await ensureValidToken();
    final Map<String, dynamic> payload = {};
    if (movies != null && movies.isNotEmpty) payload['movies'] = movies;
    if (shows != null && shows.isNotEmpty) payload['shows'] = shows;
    if (seasons != null && seasons.isNotEmpty) payload['seasons'] = seasons;
    if (episodes != null && episodes.isNotEmpty) payload['episodes'] = episodes;
    final url = Uri.parse('$baseUrl/sync/history');
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(payload),
    );
    if (response.statusCode != 201) {
      throw Exception(
        'Error POST /sync/history: ${response.statusCode}\n${response.body}',
      );
    }
  }

  /// Gets the watched history for shows or movies.
  /// [type]: 'shows' or 'movies' (default: 'shows')
  Future<List<dynamic>> getWatched({String type = 'shows'}) async {
    await ensureValidToken();
    final allowedTypes = ['shows', 'movies'];
    final safeType = allowedTypes.contains(type) ? type : 'shows';
    final url = Uri.parse(
      '$baseUrl/sync/watched/$safeType?extended=images,noseasons',
    );
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception(
        'Error GET /sync/watched/$safeType: \n${response.statusCode}\n${response.body}',
      );
    }
  }
}
