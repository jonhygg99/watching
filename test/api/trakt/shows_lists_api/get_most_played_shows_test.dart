import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'mocks/test_shows_lists_api.dart';
import 'mocks/played_shows_mock_response.dart';

void main() {
  late TestShowsListsApi showsListsApi;
  late MockTraktApiBase mockTraktApiBase;

  setUp(() {
    mockTraktApiBase = MockTraktApiBase();
    showsListsApi = TestShowsListsApi(mockTraktApiBase);
  });

  group('getMostPlayedShows', () {
    test(
      'should return a list of most played shows when the call is successful',
      () async {
        // Arrange
        when(
          mockTraktApiBase.getJsonList('/shows/played/monthly?extended=images&page=1&limit=10'),
        ).thenAnswer((_) async => mostPlayedShowsResponse);

        // Act
        final result = await showsListsApi.getMostPlayedShows(
          page: 1,
          limit: 10,
        );

        // Assert
        expect(result, isA<List<dynamic>>());
        expect(result.length, 10);
        expect(result[0]['show']['title'], 'The Big Bang Theory');
        expect(result[0]['play_count'], 23542030);
        verify(
          mockTraktApiBase.getJsonList('/shows/played/monthly?extended=images&page=1&limit=10'),
        ).called(1);
      },
    );

    test('should include correct period and pagination parameters in API call', () async {
      // Arrange
      const testPeriod = 'weekly';
      when(
        mockTraktApiBase.getJsonList('/shows/played/$testPeriod?extended=images&page=2&limit=20'),
      ).thenAnswer((_) async => []);

      // Act
      await showsListsApi.getMostPlayedShows(
        period: testPeriod,
        page: 2,
        limit: 20,
      );

      // Assert
      verify(
        mockTraktApiBase.getJsonList('/shows/played/$testPeriod?extended=images&page=2&limit=20'),
      ).called(1);
    });

    test('should throw an exception when the API call fails', () async {
      // Arrange
      when(
        mockTraktApiBase.getJsonList('/shows/played/monthly?extended=images&page=1&limit=10'),
      ).thenThrow(Exception('API Error'));

      // Act & Assert
      expect(
        showsListsApi.getMostPlayedShows,
        throwsA(isA<Exception>()),
      );
    });
  });
}
