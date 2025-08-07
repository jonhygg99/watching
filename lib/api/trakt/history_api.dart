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

  /// Removes movies, shows, seasons, episodes, or history ids from the user's watch history.
  ///
  /// You can remove entire shows, specific seasons, episodes, or by history ids.
  /// Example usage:
  ///   await removeFromHistory(shows: [...], seasons: [...], episodes: [...], ids: [...]);
  ///
  /// Throws an [Exception] if the API call fails.
  Future<Map<String, dynamic>> removeFromHistory({
    List<Map<String, dynamic>>? movies,
    List<Map<String, dynamic>>? shows,
    List<Map<String, dynamic>>? seasons,
    List<Map<String, dynamic>>? episodes,
    List<int>? ids,
  }) async {
    await ensureValidToken();
    final Map<String, dynamic> payload = {};
    if (movies != null && movies.isNotEmpty) payload['movies'] = movies;
    if (shows != null && shows.isNotEmpty) payload['shows'] = shows;
    if (seasons != null && seasons.isNotEmpty) payload['seasons'] = seasons;
    if (episodes != null && episodes.isNotEmpty) payload['episodes'] = episodes;
    if (ids != null && ids.isNotEmpty) payload['ids'] = ids;
    final url = Uri.parse('$baseUrl/sync/history/remove');
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(payload),
    );
    if (response.statusCode != 200) {
      throw Exception(
        'Error POST /sync/history/remove: ${response.statusCode}\n${response.body}',
      );
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
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

  Future<List<dynamic>> getWatchlist({
    String type = 'shows',
    String sort = 'watched',
  }) async {
    try {
      final response = await getJsonList('/users/me/watchlist/$type/$sort');
      return response;
    } catch (e) {
      throw Exception('Error GET /users/me/watchlist/$type/$sort: $e');
    }
  }

  /// Adds ratings for movies, shows, seasons, or episodes.
  ///
  /// Example usage:
  /// ```dart
  /// await addRatings(
  ///   movies: [
  ///     {
  ///       'rating': 5,
  ///       'ids': {'trakt': 123}
  ///     }
  ///   ],
  ///   shows: [
  ///     {
  ///       'rating': 10,
  ///       'ids': {'trakt': 456},
  ///       'seasons': [
  ///         {'number': 1, 'episodes': [
  ///           {'number': 1, 'rating': 9}
  ///         ]}
  ///       ]
  ///     }
  ///   ]
  /// );
  /// ```
  ///
  /// Returns a map with the count of added ratings and any not found items.
  /// Throws an [Exception] if the API call fails.
  Future<Map<String, dynamic>> addRatings({
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

    final url = Uri.parse('$baseUrl/sync/ratings');
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(payload),
    );

    if (response.statusCode != 201) {
      throw Exception(
        'Error POST /sync/ratings: ${response.statusCode}\n${response.body}',
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Removes ratings for movies, shows, seasons, or episodes.
  ///
  /// Example usage:
  /// ```dart
  /// await removeRatings(
  ///   movies: [
  ///     {'ids': {'trakt': 123}}
  ///   ],
  ///   shows: [
  ///     {
  ///       'ids': {'trakt': 456},
  ///       'seasons': [
  ///         {'number': 1, 'episodes': [
  ///           {'number': 1}
  ///         ]}
  ///       ]
  ///     }
  ///   ]
  /// );
  /// ```
  ///
  /// Returns a map with the count of removed ratings and any not found items.
  /// Throws an [Exception] if the API call fails.
  Future<Map<String, dynamic>> removeRatings({
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

    final url = Uri.parse('$baseUrl/sync/ratings/remove');
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Error POST /sync/ratings/remove: ${response.statusCode}\n${response.body}',
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
