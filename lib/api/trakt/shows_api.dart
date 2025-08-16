import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'trakt_api.dart';

/// Mixin for show and season-related endpoints.
mixin ShowsApi on TraktApiBase {
  /// Gets detailed info for a show by ID.
  ///
  /// [id]: The Trakt ID, Trakt slug, or IMDB ID of the show
  /// [extended]: If true, includes full extended info (images, full, etc.)
  Future<Map<String, dynamic>> getShowById({
    required String id,
    bool extended = true,
  }) async {
    final endpoint = '/shows/$id${extended ? '?extended=full,images' : ''}';
    return await getJsonMap(endpoint);
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

  /// Gets all episodes for a single season of a show.
  ///
  /// [id]: Trakt ID, slug, or IMDB ID of the show
  /// [season]: Season number (e.g., 1)
  /// [translations]: Optional 2-letter language code (e.g., 'es'), or 'all' for all translations
  /// Returns a List of episode objects for the season.
  Future<List<dynamic>> getSeasonEpisodes({
    required String id,
    required int season,
    String? translations,
  }) async {
    await ensureValidToken();
    final translationParam =
        translations != null ? '&translations=$translations' : '';
    final url = Uri.parse(
      '$baseUrl/shows/$id/seasons/$season?extended=images$translationParam',
    );
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final episodes = jsonDecode(response.body) as List<dynamic>;

      // If translations were requested, extract the translated episode data
      if (translations != null && translations != 'all') {
        return episodes.map((episode) {
          if (episode is Map<String, dynamic> &&
              episode.containsKey('translations') &&
              episode['translations'] is List) {
            final translations = List<Map<String, dynamic>>.from(
              episode['translations'],
            );
            if (translations.isNotEmpty) {
              // Create a new map with the original episode data and override with translation
              return {
                ...episode,
                'title': translations.first['title'] ?? episode['title'],
                'overview':
                    translations.first['overview'] ?? episode['overview'],
              };
            }
          }
          return episode;
        }).toList();
      }

      return episodes;
    } else {
      throw Exception(
        'Error GET /shows/$id/seasons/$season: ${response.statusCode}\n${response.body}',
      );
    }
  }

  /// Gets detailed info for a show by ID.
  Future<Map<String, dynamic>> getEpisodeInfo({
    required String id,
    required int season,
    required int episode,
    String? language,
  }) async {
    await ensureValidToken();

    // First get the episode details with full info and images
    final url = Uri.parse(
      '$baseUrl/shows/$id/seasons/$season/episodes/$episode?extended=full,images',
    );
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final episodeData = jsonDecode(response.body) as Map<String, dynamic>;

      // If a specific language is requested and available in translations, fetch the translation
      if (language != null && language.isNotEmpty) {
        final availableTranslations =
            episodeData['available_translations'] as List<dynamic>?;

        if (availableTranslations != null &&
            availableTranslations.contains(language)) {
          final urlTranslation = Uri.parse(
            '$baseUrl/shows/$id/seasons/$season/episodes/$episode/translations/$language',
          );
          final responseTranslation = await http.get(
            urlTranslation,
            headers: headers,
          );

          if (responseTranslation.statusCode == 200) {
            final translationResponse = jsonDecode(responseTranslation.body);

            // Handle both cases: when the response is a List or a Map
            if (translationResponse is List && translationResponse.isNotEmpty) {
              // If it's a list, take the first item (should be the requested language)
              final translationData =
                  translationResponse[0] as Map<String, dynamic>;

              // Merge the translation data into the main episode data
              episodeData.addAll({
                'title': translationData['title'],
                'overview': translationData['overview'],
                'language': language,
              });
            } else if (translationResponse is Map<String, dynamic>) {
              // If it's already a map, use it directly
              episodeData.addAll({
                'title': translationResponse['title'],
                'overview': translationResponse['overview'],
                'language': language,
              });
            }
          }
        }
      }

      return episodeData;
    } else {
      throw Exception(
        'Error GET /shows/$id/seasons/$season/episodes/$episode: ${response.statusCode}\n${response.body}',
      );
    }
  }

  /// Gets all top level comments for an episode with pagination support.
  ///
  /// [id]: Trakt ID, slug, or IMDB ID of the show
  /// [season]: Season number
  /// [episode]: Episode number
  /// [sort]: How to sort the comments. Options: newest, oldest, likes, replies, highest, lowest, plays
  /// [page]: Page number to fetch (1-based)
  /// [limit]: Number of items per page (1-1000, default 10)
  /// Returns a list of comment objects for the episode.
  Future<List<dynamic>> getEpisodeComments({
    required String id,
    required int season,
    required int episode,
    String sort = 'likes',
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final uri = Uri.https(
        'api.trakt.tv',
        '/shows/$id/seasons/$season/episodes/$episode/comments/$sort',
        {
          'page': page.toString(),
          'limit': limit.toString(),
          // Ensure no caching
          '_t': DateTime.now().millisecondsSinceEpoch.toString(),
        },
      );

      // Headers required by Trakt API
      final requestHeaders = Map<String, String>.from(headers)..addAll({
        'Content-Type': 'application/json',
        'trakt-api-version': '2',
        'trakt-api-key': headers['trakt-api-key'] ?? '',
      });

      final response = await http.get(uri, headers: requestHeaders);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Gets comments for a show by ID with pagination support.
  ///
  /// [id]: The Trakt ID, Trakt slug, or IMDB ID of the show
  /// [sort]: Sort order for comments (newest, oldest, likes, replies)
  /// [page]: Page number to fetch (1-based)
  /// [limit]: Number of items per page (1-1000, default 10)
  Future<List<dynamic>> getShowComments({
    required String id,
    String sort = 'newest',
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final uri = Uri.https('api.trakt.tv', '/shows/$id/comments/$sort', {
        'page': page.toString(),
        'limit': limit.toString(),
        // Asegurar que no haya caché
        '_t': DateTime.now().millisecondsSinceEpoch.toString(),
      });

      // Headers requeridos por la API de Trakt
      final requestHeaders = Map<String, String>.from(headers)..addAll({
        'Content-Type': 'application/json',
        'trakt-api-version': '2',
        'trakt-api-key': headers['trakt-api-key'] ?? '',
      });

      final response = await http.get(uri, headers: requestHeaders);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Gets ratings for a show by ID.
  Future<Map<String, dynamic>> getShowRatings({required String id}) async {
    return await getJsonMap('/shows/$id/ratings');
  }

  /// Gets watched progress for a show.
  Future<Map<String, dynamic>> getShowWatchedProgress({
    required String id,
  }) async {
    return await getJsonMap('/shows/$id/progress/watched');
  }

  /// Gets people for a show.
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
    required String language,
  }) async {
    return await getJsonList('/shows/$id/translations/$language');
  }

  /// Gets videos (trailers, teasers) for a show.
  /// Returns an empty list if there's an error or no videos are available.
  Future<List<dynamic>> getShowVideos({required String id}) async {
    try {
      await ensureValidToken();

      // Make the request with a timeout
      final response = await http
          .get(Uri.parse('$baseUrl/shows/$id/videos'), headers: headers)
          .timeout(const Duration(seconds: 10));

      // Handle different status codes
      if (response.statusCode == 200) {
        final videos = jsonDecode(response.body) as List<dynamic>;
        return videos
            .where(
              (v) =>
                  v is Map<String, dynamic> &&
                  v['site'] == 'youtube' &&
                  v['type'] == 'trailer',
            )
            .toList();
      } else if (response.statusCode == 401) {
        if (kDebugMode) {
          debugPrint('Unauthorized access to videos - token may be invalid');
        }
        return [];
      } else if (response.statusCode == 404) {
        if (kDebugMode) {
          debugPrint('No videos found for show $id');
        }
        return [];
      } else {
        if (kDebugMode) {
          debugPrint(
            'Error ${response.statusCode} fetching videos for show $id',
          );
        }
        return [];
      }
    } on http.ClientException catch (e) {
      if (kDebugMode) {
        debugPrint('Network error fetching videos: $e');
      }
      return [];
    } on TimeoutException catch (_) {
      if (kDebugMode) {
        debugPrint('Timeout while fetching videos');
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Unexpected error fetching videos: $e');
      }
      return [];
    }
  }

  /// Gets related shows for a show with pagination support.
  ///
  /// Returns a map containing:
  /// - 'shows': List of show objects
  /// - 'totalPages': Total number of pages available
  /// - 'totalItems': Total number of items available
  /// - 'currentPage': Current page number
  Future<Map<String, dynamic>> getRelatedShows({
    required String id,
    int page = 1,
  }) async {
    int limit = 10;

    try {
      final uri = Uri.https('api.trakt.tv', '/shows/$id/related', {
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
        final shows = jsonDecode(response.body) as List;

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
          'shows': shows,
          'totalPages': totalPages,
          'totalItems': totalItems,
          'currentPage': currentPage,
        };
      } else {
        throw Exception('Failed to load related shows: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in getRelatedShows: $e');
      }
      rethrow;
    }
  }
}
