import 'dart:convert';
import 'package:http/http.dart' as http;
import 'trakt_api.dart';

/// Mixin for user-related endpoints.
mixin UserApi on TraktApiBase {
  /// Gets the user's watchlist.
  ///
  /// [type]: Type of items to return (e.g., 'shows', 'movies').
  /// [sort]: How to sort the items.
  Future<List<dynamic>> getWatchlist({
    String type = 'shows',
    String sort = 'rank',
  }) async {
    return await getJsonList('/users/me/watchlist/$type/$sort');
  }

  /// Gets the user's watched items.
  ///
  /// [type]: Type of items to return (e.g., 'shows', 'movies').
  Future<List<dynamic>> getWatched({String type = 'shows'}) async {
    return await getJsonList('/users/me/watched/$type');
  }
  /// Gets the current user's profile.
  Future<Map<String, dynamic>> getCurrentUserProfile() async {
    await ensureValidToken();
    final url = Uri.parse('$baseUrl/users/me?extended=full');
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
        'Error GET /users/me: ${response.statusCode}\n${response.body}',
      );
    }
  }
}
