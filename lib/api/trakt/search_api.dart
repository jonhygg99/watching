import 'trakt_api.dart';

/// Mixin for search-related endpoints.
mixin SearchApi on TraktApiBase {
  /// Searches for movies and shows by query.
  ///
  /// [type] can be 'movie', 'show', or  episode ,person, list
  Future<List<dynamic>> searchMoviesAndShows({
    required String query,
    String type = 'show',
  }) async {
    final encodedQuery = Uri.encodeComponent(query);
    return await getJsonList(
      '/search/$type?query=$encodedQuery&extended=images',
    );
  }
}
