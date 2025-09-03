import 'package:watching/api/trakt/trakt_api.dart';

/// Mixin for season-related endpoints.
mixin SeasonsApi on TraktApiBase {
  /// Gets all seasons for a show.
  ///
  /// [showId]: The Trakt ID, Trakt slug, or IMDB ID of the show
  Future<List<dynamic>> getSeasons(String showId) async {
    await ensureValidToken();
    return await getJsonList('/shows/$showId/seasons?extended=images,episodes');
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
    final endpoint =
        '/shows/$id/seasons/$season?extended=images,episodes$translationParam';

    if (translations == null || translations == 'all') {
      return await getJsonList(endpoint);
    }

    // If a specific translation is requested, we need to process the response
    final episodes = await getJsonList(endpoint);

    return episodes.map((episode) {
      if (episode is Map<String, dynamic> &&
          episode.containsKey('translations') &&
          episode['translations'] is List) {
        final translationList =
            List<Map<String, dynamic>>.from(episode['translations']);
        if (translationList.isNotEmpty) {
          // Find the requested translation
          final translation = translationList.firstWhere(
            (t) => t['language'] == translations,
            orElse: () => {},
          );

          // Only apply translation if we found a matching language
          if (translation.isNotEmpty) {
            return {
              ...episode,
              'title': translation['title'] ?? episode['title'],
              'overview': translation['overview'] ?? episode['overview'],
            };
          }
        }
      }
      return episode;
    }).toList();
  }
}
