import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import 'trakt_api.dart';

/// Mixin for search-related endpoints.
mixin SearchApi on TraktApiBase {
  /// Searches for movies and shows by query with pagination support.
  ///
  /// [query] The search query string
  /// [type] Type of items to search for. Can be 'movie', 'show', 'episode', 'person', or 'list'
  /// [page] Page number to return (1-based)
  /// [limit] Number of items per page (default: 10, max: 100)
  ///
  /// Returns a map containing:
  /// - 'items': List of search result items
  /// - 'totalPages': Total number of pages available
  /// - 'totalItems': Total number of items available
  /// - 'currentPage': Current page number
  Future<Map<String, dynamic>> searchMoviesAndShows({
    required String query,
    String type = 'show',
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final encodedQuery = Uri.encodeComponent(query);
      final uri = Uri.https('api.trakt.tv', '/search/$type', {
        'query': encodedQuery,
        'extended': 'images',
        'page': page.toString(),
        'limit': limit.toString(),
      });

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'trakt-api-version': '2',
          'trakt-api-key': headers['trakt-api-key'] ?? '',
        },
      );

      if (response.statusCode == 200) {
        final items = jsonDecode(response.body) as List;

        // Extract pagination info from headers
        final totalPages =
            int.tryParse(response.headers['x-pagination-page-count'] ?? '1') ??
            1;
        final totalItems =
            int.tryParse(response.headers['x-pagination-item-count'] ?? '0') ??
            0;
        final currentPage =
            int.tryParse(response.headers['x-pagination-page'] ?? '1') ?? 1;

        return {
          'items': items,
          'totalPages': totalPages,
          'totalItems': totalItems,
          'currentPage': currentPage,
        };
      } else {
        throw Exception(
          'Failed to load search results: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        log('Error in searchMoviesAndShows: $e');
      }
      rethrow;
    }
  }
}
