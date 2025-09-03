import 'package:flutter/foundation.dart';
import 'package:watching/api/trakt/trakt_api.dart';

/// Mixin for episode-related endpoints.
mixin EpisodesApi on TraktApiBase {
  /// Gets detailed info for an episode by show ID, season, and episode number.
  Future<Map<String, dynamic>> getEpisodeInfo({
    required String id,
    required int season,
    required int episode,
    String? language,
  }) async {
    await ensureValidToken();

    // First get the episode details with full info and images
    final endpoint =
        '/shows/$id/seasons/$season/episodes/$episode?extended=full,images';
    final episodeData = await getJsonMap(endpoint);

    // If a specific language is requested and available in translations, fetch the translation
    if (language != null && language.isNotEmpty) {
      final availableTranslations =
          episodeData['available_translations'] as List<dynamic>?;

      if (availableTranslations != null &&
          availableTranslations.contains(language)) {
        try {
          final translationResponse = await getJsonList(
            '/shows/$id/seasons/$season/episodes/$episode/translations/$language',
          );

          if (translationResponse.isNotEmpty &&
              translationResponse[0] is Map<String, dynamic>) {
            final translationData =
                translationResponse[0] as Map<String, dynamic>;

            // Merge the translation data into the main episode data
            episodeData.addAll({
              'title': translationData['title'] ?? episodeData['title'],
              'overview':
                  translationData['overview'] ?? episodeData['overview'],
              'language': language,
            });
          }
        } catch (e) {
          // If translation fails, continue with the original data
          if (kDebugMode) {
            debugPrint('Error getting translation: $e');
          }
        }
      }
    }

    return episodeData;
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
    final endpoint =
        '/shows/$id/seasons/$season/episodes/$episode/comments/$sort';
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };

    return await getJsonList(
      '$endpoint?${Uri(queryParameters: queryParams).query}',
    );
  }
}
