import 'package:flutter/material.dart';
import 'package:watching/api/trakt/trakt_api.dart';
import 'package:watching/pages/watchlist/enums/time_period.dart';
import 'package:watching/shared/models/movie_models.dart';

/// Mixin for movie list endpoints (trending, popular, etc.).
mixin MoviesListsApi on TraktApiBase {
  /// Gets trending movies.
  ///
  /// [page] - Page number to return (default: 1)
  /// [limit] - Number of items per page (default: 10, max: 100)
  Future<List<TraktMovie>> getTrendingMovies({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await getJsonList(
        '/movies/trending?extended=full,images&page=$page&limit=$limit',
      );

      return response
          .whereType<Map<String, dynamic>>()
          .map((item) =>
              TraktMovie.fromJson(item['movie'] as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error in getTrendingMovies: $e');
      rethrow;
    }
  }

  /// Gets popular movies.
  ///
  /// [page] - Page number to return (default: 1)
  /// [limit] - Number of items per page (default: 10, max: 100)
  Future<List<TraktMovie>> getPopularMovies({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await getJsonList(
        '/movies/popular?extended=full,images&page=$page&limit=$limit',
      );

      return response
          .whereType<Map<String, dynamic>>()
          .map((item) => TraktMovie.fromJson(item))
          .toList();
    } catch (e) {
      debugPrint('Error in getPopularMovies: $e');
      rethrow;
    }
  }

  /// Gets the most favorited movies.
  ///
  /// [period] - Time period to get results for (default: weekly)
  /// [page] - Page number to return (default: 1)
  /// [limit] - Number of items per page (default: 10, max: 100)
  Future<List<TraktMovie>> getFavoritedMovies({
    TimePeriod period = TimePeriod.weekly,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await getJsonList(
        '/movies/favorited/${period.name}?extended=full,images&page=$page&limit=$limit',
      );

      return response
          .whereType<Map<String, dynamic>>()
          .map((item) =>
              TraktMovie.fromJson(item['movie'] as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error in getFavoritedMovies: $e');
      rethrow;
    }
  }

  /// Gets the most played movies.
  ///
  /// [period] - Time period to get results for (default: weekly)
  /// [page] - Page number to return (default: 1)
  /// [limit] - Number of items per page (default: 10, max: 100)
  Future<List<TraktMovie>> getPlayedMovies({
    TimePeriod period = TimePeriod.weekly,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await getJsonList(
        '/movies/played/${period.name}?extended=full,images&page=$page&limit=$limit',
      );

      return response
          .whereType<Map<String, dynamic>>()
          .map((item) =>
              TraktMovie.fromJson(item['movie'] as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error in getPlayedMovies: $e');
      rethrow;
    }
  }

  /// Gets the most watched movies.
  ///
  /// [period] - Time period to get results for (default: weekly)
  /// [page] - Page number to return (default: 1)
  /// [limit] - Number of items per page (default: 10, max: 100)
  Future<List<TraktMovie>> getWatchedMovies({
    TimePeriod period = TimePeriod.weekly,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await getJsonList(
        '/movies/watched/${period.name}?extended=full,images&page=$page&limit=$limit',
      );

      return response
          .whereType<Map<String, dynamic>>()
          .map((item) =>
              TraktMovie.fromJson(item['movie'] as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error in getWatchedMovies: $e');
      rethrow;
    }
  }
}
