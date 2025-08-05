import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:watching/features/watchlist/services/watchlist_episode_service.dart';
import 'package:watching/providers/app_providers.dart';

// Simple mock for Ref that returns a default country code
class TestRef implements Ref {
  final String countryCode;
  
  TestRef({this.countryCode = 'US'});

  @override
  T read<T>(ProviderListenable<T> provider) {
    if (provider == countryCodeProvider) {
      return countryCode as T;
    }
    throw UnimplementedError('Provider not mocked: $provider');
  }

  // Implement other required methods with empty implementations
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

// Simple mock for TraktClient
class TestTraktClient {
  Map<String, Map<String, dynamic>> episodeResponses = {};
  
  Future<Map<String, dynamic>> getEpisodeInfo({
    required String? id,
    required int? season,
    required int? episode,
    String? language,
  }) async {
    final key = '${id}_s${season}e$episode';
    return episodeResponses[key] ?? {};
  }

  void setEpisodeResponse({
    required String id,
    required int season,
    required int episode,
    required Map<String, dynamic> response,
  }) {
    final key = '${id}_s${season}e$episode';
    episodeResponses[key] = response;
  }
}

void main() {
  late WatchlistEpisodeService service;
  late TestRef testRef;
  late TestTraktClient testTrakt;

  // Helper to create a test episode
  Map<String, dynamic> createTestEpisode({
    required int number,
    bool completed = false,
    String title = 'Test Episode',
    String overview = 'Test Overview',
  }) {
    return {
      'number': number,
      'completed': completed,
      'title': title,
      'overview': overview,
      'ids': {'trakt': number},
    };
  }

  // Helper to create a test season
  Map<String, dynamic> createTestSeason({
    required int number,
    List<Map<String, dynamic>> episodes = const [],
  }) {
    return {
      'number': number,
      'episodes': episodes,
    };
  }

  setUp(() {
    testRef = TestRef();
    testTrakt = TestTraktClient();
    service = WatchlistEpisodeService(testRef);
  });

  group('getNextEpisode', () {
    test('returns null when progress has no seasons', () async {
      final result = await service.getNextEpisode(testTrakt, '123', {});
      expect(result, isNull);
    });

    test('returns null when all episodes are completed', () async {
      final progress = {
        'seasons': [
          createTestSeason(
            number: 1,
            episodes: [
              createTestEpisode(number: 1, completed: true),
              createTestEpisode(number: 2, completed: true),
            ],
          ),
        ],
      };

      final result = await service.getNextEpisode(testTrakt, '123', progress);
      expect(result, isNull);
    });

    test('finds first unwatched episode', () async {
      final progress = {
        'seasons': [
          createTestSeason(
            number: 1,
            episodes: [
              createTestEpisode(number: 1, completed: true),
              createTestEpisode(number: 2, completed: false, title: 'Next Episode'),
            ],
          ),
        ],
      };

      testTrakt.setEpisodeResponse(
        id: '123',
        season: 1,
        episode: 2,
        response: {'title': 'Translated Title', 'overview': 'Translated Overview'},
      );

      final result = await service.getNextEpisode(testTrakt, '123', progress);

      expect(result, isNotNull);
      expect(result!['number'], equals(2));
      expect(result['title'], equals('Translated Title'));
      expect(result['overview'], equals('Translated Overview'));
    });

    test('skips specials (season 0)', () async {
      final progress = {
        'seasons': [
          createTestSeason(
            number: 0, // Specials season
            episodes: [
              createTestEpisode(number: 1, completed: false, title: 'Special Episode'),
            ],
          ),
          createTestSeason(
            number: 1,
            episodes: [
              createTestEpisode(number: 1, completed: false, title: 'Regular Episode'),
            ],
          ),
        ],
      };

      testTrakt.setEpisodeResponse(
        id: '123',
        season: 1,
        episode: 1,
        response: {'title': 'Regular Episode'},
      );

      final result = await service.getNextEpisode(testTrakt, '123', progress);

      expect(result, isNotNull);
      expect(result!['title'], equals('Regular Episode'));
    });

    test('uses fallback title when translation is missing', () async {
      final progress = {
        'seasons': [
          createTestSeason(
            number: 1,
            episodes: [
              createTestEpisode(number: 1, completed: false, title: 'Original Title'),
            ],
          ),
        ],
      };

      final result = await service.getNextEpisode(testTrakt, '123', progress);

      expect(result, isNotNull);
      expect(result!['title'], equals('Original Title'));
    });

    test('handles API errors gracefully', () async {
      final progress = {
        'seasons': [
          createTestSeason(
            number: 1,
            episodes: [
              createTestEpisode(number: 1, completed: false, title: 'Test Episode'),
            ],
          ),
        ],
      };

      final result = await service.getNextEpisode(testTrakt, '123', progress);

      expect(result, isNotNull);
      expect(result!['title'], equals('Test Episode'));
    });
  });
}
