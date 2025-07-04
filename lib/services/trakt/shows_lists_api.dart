import 'trakt_api.dart';

/// Mixin for show list endpoints (trending, popular, favorited, etc.).
mixin ShowsListsApi on TraktApiBase {
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
}
