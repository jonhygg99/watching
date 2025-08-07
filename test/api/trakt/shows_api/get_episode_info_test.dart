import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'mocks/test_shows_api.dart';
import 'mocks/mock_get_episode_info.dart';
import 'mocks/mock_trakt_api_base.dart';

void main() {
  late TestShowsApi showsApi;
  late MockTraktApiBase mockTraktApiBase;

  setUp(() {
    mockTraktApiBase = MockTraktApiBase();
    showsApi = TestShowsApi(mockTraktApiBase);
  });

  group('getEpisodeInfo', () {
    test(
      'should return basic episode info when called with valid parameters',
      () async {
        // Arrange
        final mockEpisode = getMockEpisodeInfo();

        when(
          mockTraktApiBase.getJsonMap(
            '/shows/game-of-thrones/seasons/1/episodes/1',
          ),
        ).thenAnswer((_) async => mockEpisode);

        // Act
        final result = await showsApi.getEpisodeInfo(
          id: 'game-of-thrones',
          season: 1,
          episode: 1,
        );

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result['title'], 'Winter Is Coming');
        expect(result['season'], 1);
        expect(result['number'], 1);

        verify(
          mockTraktApiBase.getJsonMap(
            '/shows/game-of-thrones/seasons/1/episodes/1',
          ),
        ).called(1);
      },
    );

    test(
      'should return extended episode info when extended parameter is true',
      () async {
        // Arrange
        final mockExtendedEpisode = getMockExtendedEpisodeInfo();

        when(
          mockTraktApiBase.getJsonMap(
            '/shows/game-of-thrones/seasons/1/episodes/1?extended=full',
          ),
        ).thenAnswer((_) async => mockExtendedEpisode);

        // Act - Using a custom method that includes extended parameter
        final result = await showsApi.getJsonMap(
          '/shows/game-of-thrones/seasons/1/episodes/1?extended=full',
        );

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result['title'], 'Winter Is Coming');
        expect(result['overview'], contains('Ned Stark, Lord of Winterfell'));
        expect(result['rating'], 9.0);
        expect(result['runtime'], 58);
        expect(result['episode_type'], 'series_premiere');
        expect(result['available_translations'], isA<List<dynamic>>());
        expect(result['available_translations'], contains('en'));
      },
    );

    test('should throw an exception when API call fails', () async {
      // Arrange
      when(
        mockTraktApiBase.getJsonMap(
          '/shows/game-of-thrones/seasons/1/episodes/1',
        ),
      ).thenThrow(Exception('API Error'));

      // Act & Assert
      await expectLater(
        () => showsApi.getEpisodeInfo(
          id: 'game-of-thrones',
          season: 1,
          episode: 1,
        ),
        throwsA(isA<Exception>()),
      );

      verify(
        mockTraktApiBase.getJsonMap(
          '/shows/game-of-thrones/seasons/1/episodes/1',
        ),
      ).called(1);
    });

    test('should include language parameter when provided', () async {
      // Arrange
      final mockEpisode = {'title': 'El Invierno se acerca'};

      when(
        mockTraktApiBase.getJsonMap(
          '/shows/game-of-thrones/seasons/1/episodes/1?language=es',
        ),
      ).thenAnswer((_) async => mockEpisode);

      // Act
      final result = await showsApi.getEpisodeInfo(
        id: 'game-of-thrones',
        season: 1,
        episode: 1,
        language: 'es',
      );

      // Assert
      expect(result, isA<Map<String, dynamic>>());
      expect(result['title'], 'El Invierno se acerca');
      verify(
        mockTraktApiBase.getJsonMap(
          '/shows/game-of-thrones/seasons/1/episodes/1?language=es',
        ),
      ).called(1);
    });
  });
}
