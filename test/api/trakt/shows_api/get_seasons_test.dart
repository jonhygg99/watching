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
}
