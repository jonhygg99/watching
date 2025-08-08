import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'mocks/test_shows_api.dart';
import 'mocks/mock_get_seasons.dart';
import 'mocks/mock_trakt_api_base.dart';

void main() {
  late TestShowsApi showsApi;
  late MockTraktApiBase mockTraktApiBase;

  setUp(() {
    mockTraktApiBase = MockTraktApiBase();
    showsApi = TestShowsApi(mockTraktApiBase);
  });

  group('getSeasonEpisodes', () {
    test(
      'should return episodes for a season when called with valid ID and season number',
      () async {
        // Arrange
        final seasons = getMockSeasonsWithEpisodesResponse();
        final season1 = seasons.firstWhere((s) => s['number'] == 1);
        final episodes = List<Map<String, dynamic>>.from(
          season1['episodes'] as List,
        );

        when(
          mockTraktApiBase.getJsonList(
            '/shows/game-of-thrones/seasons/1/episodes',
          ),
        ).thenAnswer((_) async => episodes);

        // Act
        final result = await showsApi.getSeasonEpisodes(
          id: 'game-of-thrones',
          season: 1,
        );

        // Assert
        expect(result, isA<List<dynamic>>());

        final firstEpisodeSeason1 = result.firstWhere((e) => e['number'] == 1);
        expect(firstEpisodeSeason1["title"], "Winter Is Coming");
        expect(result.isNotEmpty, true);
        verify(
          mockTraktApiBase.getJsonList(
            '/shows/game-of-thrones/seasons/1/episodes',
          ),
        ).called(1);
      },
    );

    test(
      'should include translations when translations parameter is provided',
      () async {
        // Arrange
        final seasons = getMockSeasonsWithEpisodesResponse();
        final season1 = seasons.firstWhere((s) => s['number'] == 1);
        final episodes = List<Map<String, dynamic>>.from(
          season1['episodes'] as List,
        );

        when(
          mockTraktApiBase.getJsonList(
            '/shows/game-of-thrones/seasons/1/episodes?translations=es',
          ),
        ).thenAnswer((_) async => episodes);

        // Act
        final result = await showsApi.getSeasonEpisodes(
          id: 'game-of-thrones',
          season: 1,
          translations: 'es',
        );

        // Assert
        expect(result, isA<List<dynamic>>());
        expect(result.isNotEmpty, true);
        verify(
          mockTraktApiBase.getJsonList(
            '/shows/game-of-thrones/seasons/1/episodes?translations=es',
          ),
        ).called(1);
      },
    );

    test(
      'should not include translations parameter when translations is empty',
      () async {
        // Arrange
        final seasons = getMockSeasonsWithEpisodesResponse();
        final season1 = seasons.firstWhere((s) => s['number'] == 1);
        final episodes = List<Map<String, dynamic>>.from(
          season1['episodes'] as List,
        );

        when(
          mockTraktApiBase.getJsonList(
            '/shows/game-of-thrones/seasons/1/episodes?translations=',
          ),
        ).thenAnswer((_) async => episodes);

        // Act
        final result = await showsApi.getSeasonEpisodes(
          id: 'game-of-thrones',
          season: 1,
          translations: '',
        );

        // Assert
        expect(result, isA<List<dynamic>>());
        expect(result.isNotEmpty, true);
        verify(
          mockTraktApiBase.getJsonList(
            '/shows/game-of-thrones/seasons/1/episodes?translations=',
          ),
        ).called(1);
      },
    );

    test('should throw an exception when API call fails', () async {
      // Arrange
      when(
        mockTraktApiBase.getJsonList(
          '/shows/game-of-thrones/seasons/1/episodes',
        ),
      ).thenThrow(Exception('API Error'));

      // Act & Assert
      expect(
        () => showsApi.getSeasonEpisodes(id: 'game-of-thrones', season: 1),
        throwsA(isA<Exception>()),
      );
    });
  });
}
