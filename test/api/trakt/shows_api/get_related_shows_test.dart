import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'mocks/test_shows_api.dart';
import 'mocks/mock_get_related_shows.dart';
import 'mocks/mock_trakt_api_base.dart';

void main() {
  late TestShowsApi showsApi;
  late MockTraktApiBase mockTraktApiBase;

  setUp(() {
    mockTraktApiBase = MockTraktApiBase();
    showsApi = TestShowsApi(mockTraktApiBase);
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
}
