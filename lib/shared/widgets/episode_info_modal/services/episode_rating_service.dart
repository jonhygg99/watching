import 'package:watching/api/trakt/trakt_api.dart';

class EpisodeRatingService {
  final TraktApi _traktApi;

  EpisodeRatingService(this._traktApi);

  Future<void> addRating({
    required Map<String, dynamic> showData,
    required int seasonNumber,
    required int episodeNumber,
    required double rating,
  }) async {
    // Convert 0-5 rating to 1-10 scale
    final traktRating = (rating * 2).round().clamp(1, 10);

    // Get the show data from the widget
    final showIds = showData['ids'] as Map<String, dynamic>? ?? {};
    final showTraktId = showIds['trakt'] ?? 0;

    if (showTraktId == 0) {
      throw Exception('Invalid show Trakt ID');
    }

    // Build the request payload
    final showPayload = {
      'ids': {
        'trakt': showTraktId,
        'slug': showIds['slug'],
        'imdb': showIds['imdb'],
        'tmdb': showIds['tmdb'],
        'tvdb': showIds['tvdb'],
      },
      'title': showData['title'] ?? 'Unknown',
      'year': showData['year'],
      'seasons': [
        {
          'number': seasonNumber,
          'episodes': [
            {'number': episodeNumber, 'rating': traktRating},
          ],
        },
      ],
    };

    await _traktApi.addRatings(shows: [showPayload]);
  }

  Future<void> removeRating({
    required Map<String, dynamic> showData,
    required int seasonNumber,
    required int episodeNumber,
  }) async {
    const maxRetries = 3;
    int attempt = 0;

    while (attempt < maxRetries) {
      try {
        // Get the show data
        final showIds = showData['ids'] as Map<String, dynamic>? ?? {};
        final showTraktId = showIds['trakt'] ?? 0;

        if (showTraktId == 0) return;

        // Build the request payload
        final showPayload = {
          'ids': {
            'trakt': showTraktId,
            'slug': showIds['slug'],
            'imdb': showIds['imdb'],
            'tmdb': showIds['tmdb'],
            'tvdb': showIds['tvdb'],
          },
          'title': showData['title'] ?? 'Unknown',
          'year': showData['year'],
          'seasons': [
            {
              'number': seasonNumber,
              'episodes': [
                {'number': episodeNumber},
              ],
            },
          ],
        };

        await _traktApi.removeRatings(shows: [showPayload]);
        return;
      } catch (e) {
        attempt++;

        // Check if this is a rate limit error
        if (e.toString().contains('429') && attempt < maxRetries) {
          int waitTime = 1;
          final match = RegExp(r'wait (\d+) seconds').firstMatch(e.toString());
          if (match != null) {
            waitTime = int.tryParse(match.group(1) ?? '1') ?? 1;
          }

          // Add some jitter and exponential backoff
          final backoffTime = Duration(
            seconds: (waitTime * (1 << (attempt - 1))).clamp(1, 30),
          );
          await Future.delayed(backoffTime);
        } else if (attempt >= maxRetries) {
          rethrow;
        }
      }
    }
  }
}
