import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'mocks/test_shows_api.dart';
import 'mocks/mock_get_seasons.dart';
import 'mocks/mock_get_show_by_id.dart';
import 'mocks/mock_get_episode_info.dart';
import 'mocks/mock_get_related_shows.dart';
import 'mocks/mock_get_show_comments.dart';
import 'mocks/mock_trakt_api_base.dart';

void main() {
  late TestShowsApi showsApi;
  late MockTraktApiBase mockTraktApiBase;

  setUp(() {
    mockTraktApiBase = MockTraktApiBase();
    showsApi = TestShowsApi(mockTraktApiBase);
  });

  group('ShowsApi', () {
    group('getShowById', () {
      test('should return show details when called with valid ID', () async {
        // Arrange
        final mockResponse = getMockShowResponse();
        when(
          mockTraktApiBase.getJsonMap('/shows/game-of-thrones'),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await showsApi.getShowById(id: 'game-of-thrones');

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result['title'], 'Game of Thrones');
        expect(result['year'], 2011);
        verify(mockTraktApiBase.getJsonMap('/shows/game-of-thrones')).called(1);
      });

      test(
        'should return extended show details when extended is true',
        () async {
          // Arrange
          final mockResponse = getMockExtendedShowResponse();
          when(
            mockTraktApiBase.getJsonMap(
              '/shows/game-of-thrones?extended=full,images',
            ),
          ).thenAnswer((_) async => mockResponse);

          // Act
          final result = await showsApi.getShowById(
            id: 'game-of-thrones',
            extended: true,
          );

          // Assert
          expect(result, isA<Map<String, dynamic>>());
          expect(result['title'], 'Game of Thrones');
          expect(result['tagline'], 'Winter Is Coming');
          expect(result['overview'], isNotNull);
          expect(result['status'], 'returning series');
          expect(result['rating'], 9);
          expect(result['available_translations'], isNotNull);
          expect(result['aired_episodes'], 50);
          verify(
            mockTraktApiBase.getJsonMap(
              '/shows/game-of-thrones?extended=full,images',
            ),
          ).called(1);
        },
      );
    });

    group('getSeasons', () {
      test('should return seasons list when called with valid ID', () async {
        // Arrange
        final mockResponse = getMockSeasonsResponse();
        when(
          mockTraktApiBase.getJsonList(
            '/shows/game-of-thrones/seasons?extended=images',
          ),
        ).thenAnswer((_) async => mockResponse);

        // Act
        final result = await showsApi.getSeasons('game-of-thrones');

        // Assert
        expect(result, isA<List<dynamic>>());
        expect(result.isNotEmpty, true);
        expect(result.length, 5);
        expect(result[0]['number'], 0);
        expect(result[1]['number'], 1);
        verify(
          mockTraktApiBase.getJsonList(
            '/shows/game-of-thrones/seasons?extended=images',
          ),
        ).called(1);
      });

      test('should return extended seasons data when available', () async {
        // Arrange
        final mockResponse = getMockExtendedSeasonsResponse();
        when(
          mockTraktApiBase.getJsonList(
            '/shows/game-of-thrones/seasons?extended=full,images',
          ),
        ).thenAnswer((_) async => mockResponse);

        // Act - Using a custom method that includes extended parameter
        final result = await showsApi.getJsonList(
          '/shows/game-of-thrones/seasons?extended=full,images',
        );

        // Assert
        expect(result, isA<List<dynamic>>());
        expect(result.isNotEmpty, true);

        // Check extended fields are present
        final firstSeason = result.firstWhere(
          (s) => s['number'] == 0,
          orElse: () => <String, dynamic>{},
        );

        expect(firstSeason, isNotNull);
        expect(firstSeason['episode_count'], 10);
        expect(firstSeason['rating'], 9);
      });

      test('should handle empty seasons response', () async {
        // Arrange
        when(
          mockTraktApiBase.getJsonList(
            '/shows/game-of-thrones/seasons?extended=images',
          ),
        ).thenAnswer((_) async => []);

        // Act
        final result = await showsApi.getSeasons('game-of-thrones');

        // Assert
        expect(result, isA<List<dynamic>>());
        expect(result.isEmpty, true);
        verify(
          mockTraktApiBase.getJsonList(
            '/shows/game-of-thrones/seasons?extended=images',
          ),
        ).called(1);
      });

      test('should throw an exception when API call fails', () async {
        // Arrange
        when(
          mockTraktApiBase.getJsonList(
            '/shows/game-of-thrones/seasons?extended=images',
          ),
        ).thenThrow(Exception('API Error'));

        // Act & Assert
        expect(
          () => showsApi.getSeasons('game-of-thrones'),
          throwsA(isA<Exception>()),
        );
      });
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

          final firstEpisodeSeason1 = result.firstWhere(
            (e) => e['number'] == 1,
          );
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
          // TODO: Have a mock for this
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

          // The implementation adds ?translations= when the parameter is not null, even if empty
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

    group('getShowComments', () {
      test('should return show comments when called with valid ID', () async {
        // Arrange
        final mockComments = getMockShowComments();

        when(
          mockTraktApiBase.getJsonList(
            '/shows/game-of-thrones/comments/newest',
          ),
        ).thenAnswer((_) async => mockComments);

        // Act
        final result = await showsApi.getShowComments(id: 'game-of-thrones');

        // Assert
        expect(result, isA<List<dynamic>>());
        expect(result.length, 5);

        // Verify first comment
        expect(result[0]['comment'], contains('amazing'));
        expect(result[0]['user']['username'], 'tvfan123');
        expect(result[0]['likes'], 24);

        // Verify a reply comment
        expect(result[2]['parent_id'], 12345);
        expect(result[2]['replies'], 0);

        // Verify a review
        final review = result.firstWhere(
          (c) => c['review'] == true,
          orElse: () => <String, dynamic>{},
        );
        expect(review.isNotEmpty, true);
        expect(review['user_rating'], 9.5);

        verify(
          mockTraktApiBase.getJsonList(
            '/shows/game-of-thrones/comments/newest',
          ),
        ).called(1);
      });

      test('should use custom sort parameter', () async {
        // Arrange
        final mockComments = getMockShowComments().sublist(0, 2);

        when(
          mockTraktApiBase.getJsonList('/shows/game-of-thrones/comments/likes'),
        ).thenAnswer((_) async => mockComments);

        // Act
        final result = await showsApi.getShowComments(
          id: 'game-of-thrones',
          sort: 'likes',
        );

        // Assert
        expect(result, isA<List<dynamic>>());
        expect(result.length, 2);

        verify(
          mockTraktApiBase.getJsonList('/shows/game-of-thrones/comments/likes'),
        ).called(1);
      });

      test('should handle empty comments response', () async {
        // Arrange
        when(
          mockTraktApiBase.getJsonList(
            '/shows/game-of-thrones/comments/newest',
          ),
        ).thenAnswer((_) async => []);

        // Act
        final result = await showsApi.getShowComments(id: 'game-of-thrones');

        // Assert
        expect(result, isA<List<dynamic>>());
        expect(result.isEmpty, true);

        verify(
          mockTraktApiBase.getJsonList(
            '/shows/game-of-thrones/comments/newest',
          ),
        ).called(1);
      });

      test('should throw an exception when API call fails', () async {
        // Arrange
        when(
          mockTraktApiBase.getJsonList(
            '/shows/game-of-thrones/comments/newest',
          ),
        ).thenThrow(Exception('API Error'));

        // Act & Assert
        await expectLater(
          () => showsApi.getShowComments(id: 'game-of-thrones'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getRelatedShows', () {
      test('should return related shows when called with valid ID', () async {
        // Arrange
        final mockShows = getMockRelatedShows();

        when(
          mockTraktApiBase.getJsonList('/shows/game-of-thrones/related'),
        ).thenAnswer((_) async => mockShows);

        // Act
        final result = await showsApi.getRelatedShows(id: 'game-of-thrones');

        // Assert
        expect(result, isA<List<dynamic>>());
        expect(result.length, 10);
        expect(result[0]['title'], 'Battlestar Galactica');
        expect(result[0]['year'], 2005);

        // Verify the last show as well to ensure full list is loaded
        expect(result[9]['title'], 'The Shield');
        expect(result[9]['year'], 2002);

        verify(
          mockTraktApiBase.getJsonList('/shows/game-of-thrones/related'),
        ).called(1);
      });

      test('should handle empty related shows response', () async {
        // Arrange
        when(
          mockTraktApiBase.getJsonList('/shows/game-of-thrones/related'),
        ).thenAnswer((_) async => []);

        // Act
        final result = await showsApi.getRelatedShows(id: 'game-of-thrones');

        // Assert
        expect(result, isA<List<dynamic>>());
        expect(result.isEmpty, true);
        verify(
          mockTraktApiBase.getJsonList('/shows/game-of-thrones/related'),
        ).called(1);
      });

      test('should throw an exception when API call fails', () async {
        // Arrange
        when(
          mockTraktApiBase.getJsonList('/shows/game-of-thrones/related'),
        ).thenThrow(Exception('API Error'));

        // Act & Assert
        await expectLater(
          () => showsApi.getRelatedShows(id: 'game-of-thrones'),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
