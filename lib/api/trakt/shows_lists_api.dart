import 'trakt_api.dart';

/// Mixin for show list endpoints (trending, popular, favorited, etc.).
mixin ShowsListsApi on TraktApiBase {
  /// Gets trending shows.
  ///
  /// [page] - Page number to return (default: 1)
  /// [limit] - Number of items per page (default: 10, max: 100)
  Future<List<dynamic>> getTrendingShows({
    int page = 1,
    int limit = 10,
  }) async {
    return await getJsonList(
      '/shows/trending?extended=images&page=$page&limit=$limit',
    );
  }

  /// Gets popular shows.
  ///
  /// [page] - Page number to return (default: 1)
  /// [limit] - Number of items per page (default: 10, max: 100)
  Future<List<dynamic>> getPopularShows({
    int page = 1,
    int limit = 10,
  }) async {
    return await getJsonList(
      '/shows/popular?extended=images&page=$page&limit=$limit',
    );
  }

  /// Gets most favorited shows.
  ///
  /// [period] - Time period to filter by (daily, weekly, monthly, yearly, all)
  /// [page] - Page number to return (default: 1)
  /// [limit] - Number of items per page (default: 10, max: 100)
  Future<List<dynamic>> getMostFavoritedShows({
    String period = 'monthly',
    int page = 1,
    int limit = 10,
  }) async {
    return await getJsonList(
      '/shows/favorited/$period?extended=images&page=$page&limit=$limit',
    );
  }

  /// Gets most collected shows.
  ///
  /// [period] - Time period to filter by (daily, weekly, monthly, yearly, all)
  /// [page] - Page number to return (default: 1)
  /// [limit] - Number of items per page (default: 10, max: 100)
  Future<List<dynamic>> getMostCollectedShows({
    String period = 'monthly',
    int page = 1,
    int limit = 10,
  }) async {
    return await getJsonList(
      '/shows/collected/$period?extended=images&page=$page&limit=$limit',
    );
  }

  /// Gets most played shows.
  ///
  /// [period] - Time period to filter by (daily, weekly, monthly, yearly, all)
  /// [page] - Page number to return (default: 1)
  /// [limit] - Number of items per page (default: 10, max: 100)
  Future<List<dynamic>> getMostPlayedShows({
    String period = 'monthly',
    int page = 1,
    int limit = 10,
  }) async {
    return await getJsonList(
      '/shows/played/$period?extended=images&page=$page&limit=$limit',
    );
  }

  /// Gets most watched shows.
  ///
  /// [period] - Time period to filter by (daily, weekly, monthly, yearly, all)
  /// [page] - Page number to return (default: 1)
  /// [limit] - Number of items per page (default: 10, max: 100)
  Future<List<dynamic>> getMostWatchedShows({
    String period = 'monthly',
    int page = 1,
    int limit = 10,
  }) async {
    return await getJsonList(
      '/shows/watched/$period?extended=images&page=$page&limit=$limit',
    );
  }

  /// Gets most anticipated shows.
  ///
  /// [page] - Page number to return (default: 1)
  /// [limit] - Number of items per page (default: 10, max: 100)
  Future<List<dynamic>> getMostAnticipatedShows({
    int page = 1,
    int limit = 10,
  }) async {
    return await getJsonList(
      '/shows/anticipated?extended=images&page=$page&limit=$limit',
    );
  }
}
