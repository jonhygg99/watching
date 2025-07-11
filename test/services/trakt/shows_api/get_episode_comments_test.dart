import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'mocks/test_shows_api.dart';
import 'mocks/mock_get_episode_comments.dart';
import 'mocks/mock_trakt_api_base.dart';

void main() {
  late TestShowsApi showsApi;
  late MockTraktApiBase mockTraktApiBase;

  setUp(() {
    mockTraktApiBase = MockTraktApiBase();
    showsApi = TestShowsApi(mockTraktApiBase);
  });

  group('getEpisodeComments', () {
    test(
      'should return comments for an episode when called with valid parameters',
      () async {
        // Arrange
        final mockComments = getMockEpisodeComments();

        when(
          mockTraktApiBase.getJsonList(
            '/shows/game-of-thrones/seasons/1/episodes/1/comments/likes',
          ),
        ).thenAnswer((_) async => mockComments);

        // Act
        final result = await showsApi.getEpisodeComments(
          id: 'game-of-thrones',
          season: 1,
          episode: 1,
          sort: 'likes',
        );

        // Assert
        expect(result, isA<List<dynamic>>());
        expect(result.length, mockComments.length);

        final firstComment = result[0] as Map<String, dynamic>;
        expect(firstComment['id'], 8);
        expect(firstComment['comment'], 'Great episode!');
        expect(firstComment['user']['username'], 'sean');

        verify(
          mockTraktApiBase.getJsonList(
            '/shows/game-of-thrones/seasons/1/episodes/1/comments/likes',
          ),
        ).called(1);
      },
    );

    test(
      'should use default sort when sort parameter is not provided',
      () async {
        // Arrange
        final mockComments = getMockEpisodeComments();

        when(
          mockTraktApiBase.getJsonList(
            '/shows/game-of-thrones/seasons/1/episodes/1/comments/likes',
          ),
        ).thenAnswer((_) async => mockComments);

        // Act
        await showsApi.getEpisodeComments(
          id: 'game-of-thrones',
          season: 1,
          episode: 1,
        );

        // Assert
        verify(
          mockTraktApiBase.getJsonList(
            '/shows/game-of-thrones/seasons/1/episodes/1/comments/likes',
          ),
        ).called(1);
      },
    );

    test('should handle empty comments list', () async {
      // Arrange
      when(
        mockTraktApiBase.getJsonList(
          '/shows/game-of-thrones/seasons/1/episodes/1/comments/newest',
        ),
      ).thenAnswer((_) async => []);

      // Act
      final result = await showsApi.getEpisodeComments(
        id: 'game-of-thrones',
        season: 1,
        episode: 1,
        sort: 'newest',
      );

      // Assert
      expect(result, isEmpty);
    });
  });
}
