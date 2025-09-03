import 'package:watching/api/trakt/trakt_api.dart';
import 'package:watching/shared/models/show_models.dart';

/// Mixin for show list endpoints (trending, popular, favorited, etc.).
mixin ShowsListsApi on TraktApiBase {
  /// Gets trending shows.
  ///
  /// [page] - Page number to return (default: 1)
  /// [limit] - Number of items per page (default: 10, max: 100)
  /// Gets trending shows.
  ///
  /// [page] - Page number to return (default: 1)
  /// [limit] - Number of items per page (default: 10, max: 100)
  Future<List<TraktShow>> getTrendingShows({
    int page = 1,
    int limit = 10,
  }) async {
    final response = await getJsonList(
      '/shows/trending?extended=full,images&page=$page&limit=$limit',
    );
    return response
        .map<TraktShow>(
          (item) => TraktShow.fromNestedJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  /// Gets popular shows.
  ///
  /// [page] - Page number to return (default: 1)
  /// [limit] - Number of items per page (default: 10, max: 100)
  /// Gets popular shows.
  ///
  /// [page] - Page number to return (default: 1)
  /// [limit] - Number of items per page (default: 10, max: 100)
  Future<List<TraktShow>> getPopularShows({
    int page = 1,
    int limit = 10,
  }) async {
    final response = await getJsonList(
      '/shows/popular?extended=full,images&page=$page&limit=$limit',
    );
    return response
        .map<TraktShow>(
          (item) => TraktShow.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  /// Gets most favorited shows.
  ///
  /// [period] - Time period to filter by (daily, weekly, monthly, yearly, all)
  /// [page] - Page number to return (default: 1)
  /// [limit] - Number of items per page (default: 10, max: 100)
  /// Gets most favorited shows.
  ///
  /// [period] - Time period to filter by (daily, weekly, monthly, yearly, all)
  /// [page] - Page number to return (default: 1)
  /// [limit] - Number of items per page (default: 10, max: 100)
  Future<List<TraktShow>> getMostFavoritedShows({
    String period = 'monthly',
    int page = 1,
    int limit = 10,
  }) async {
    final response = await getJsonList(
      '/shows/favorited/$period?extended=full,images&page=$page&limit=$limit',
    );
    return response
        .map<TraktShow>(
          (item) => TraktShow.fromNestedJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  /// Gets most collected shows.
  ///
  /// [period] - Time period to filter by (daily, weekly, monthly, yearly, all)
  /// [page] - Page number to return (default: 1)
  /// [limit] - Number of items per page (default: 10, max: 100)
  /// Gets most collected shows.
  ///
  /// [period] - Time period to filter by (daily, weekly, monthly, yearly, all)
  /// [page] - Page number to return (default: 1)
  /// [limit] - Number of items per page (default: 10, max: 100)
  Future<List<TraktShow>> getMostCollectedShows({
    String period = 'monthly',
    int page = 1,
    int limit = 10,
  }) async {
    final response = await getJsonList(
      '/shows/collected/$period?extended=full,images&page=$page&limit=$limit',
    );
    return response
        .map<TraktShow>(
          (item) => TraktShow.fromNestedJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  /// Gets most played shows.
  ///
  /// [period] - Time period to filter by (daily, weekly, monthly, yearly, all)
  /// [page] - Page number to return (default: 1)
  /// [limit] - Number of items per page (default: 10, max: 100)
  /// Gets most played shows.
  ///
  /// [period] - Time period to filter by (daily, weekly, monthly, yearly, all)
  /// [page] - Page number to return (default: 1)
  /// [limit] - Number of items per page (default: 10, max: 100)
  Future<List<TraktShow>> getMostPlayedShows({
    String period = 'monthly',
    int page = 1,
    int limit = 10,
  }) async {
    final response = await getJsonList(
      '/shows/played/$period?extended=full,images&page=$page&limit=$limit',
    );
    return response
        .map<TraktShow>(
          (item) => TraktShow.fromNestedJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  /// Gets most watched shows.
  ///
  /// [period] - Time period to filter by (daily, weekly, monthly, yearly, all)
  /// [page] - Page number to return (default: 1)
  /// [limit] - Number of items per page (default: 10, max: 100)
  /// Gets most watched shows.
  ///
  /// [period] - Time period to filter by (daily, weekly, monthly, yearly, all)
  /// [page] - Page number to return (default: 1)
  /// [limit] - Number of items per page (default: 10, max: 100)
  Future<List<TraktShow>> getMostWatchedShows({
    String period = 'monthly',
    int page = 1,
    int limit = 10,
  }) async {
    final response = await getJsonList(
      '/shows/watched/$period?extended=full,images&page=$page&limit=$limit',
    );
    return response
        .map<TraktShow>(
          (item) => TraktShow.fromNestedJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  /// Gets most anticipated shows.
  ///
  /// [page] - Page number to return (default: 1)
  /// [limit] - Number of items per page (default: 10, max: 100)
  /// Gets most anticipated shows.
  ///
  /// [page] - Page number to return (default: 1)
  /// [limit] - Number of items per page (default: 10, max: 100)
  Future<List<TraktShow>> getMostAnticipatedShows({
    int page = 1,
    int limit = 10,
  }) async {
    final response = await getJsonList(
      '/shows/anticipated?extended=full,images&page=$page&limit=$limit',
    );
    return response
        .map<TraktShow>(
          (item) => TraktShow.fromNestedJson(item as Map<String, dynamic>),
        )
        .toList();
  }
}
