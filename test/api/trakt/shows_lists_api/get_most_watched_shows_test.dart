import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'mocks/test_shows_lists_api.dart';
import 'mocks/watched_shows_mock_response.dart';

void main() {
  late TestShowsListsApi showsListsApi;
  late MockTraktApiBase mockTraktApiBase;

  setUp(() {
    mockTraktApiBase = MockTraktApiBase();
    showsListsApi = TestShowsListsApi(mockTraktApiBase);
  });

  group('getMostWatchedShows', () {
    test(
      'should return a list of most watched shows when the call is successful',
      () async {
        // Arrange
        when(
          mockTraktApiBase.getJsonList(
            '/shows/watched/monthly?extended=images&page=1&limit=10',
          ),
        ).thenAnswer((_) async => mostWatchedShowsResponse);

        // Act
        final result = await showsListsApi.getMostWatchedShows(
          page: 1,
          limit: 10,
        );

        // Assert
        expect(result, isA<List<dynamic>>());
        expect(result.length, 10);
        expect(result[0]['show']['title'], 'Game of Thrones');
        expect(result[0]['watcher_count'], 203742);
        verify(
          mockTraktApiBase.getJsonList(
            '/shows/watched/monthly?extended=images&page=1&limit=10',
          ),
        ).called(1);
      },
    );

    test('should include correct period and pagination parameters in API call', () async {
      // Arrange
      const testPeriod = 'yearly';
      when(
        mockTraktApiBase.getJsonList(
          '/shows/watched/$testPeriod?extended=images&page=2&limit=20',
        ),
      ).thenAnswer((_) async => []);

      // Act
      await showsListsApi.getMostWatchedShows(
        period: testPeriod,
        page: 2,
        limit: 20,
      );

      // Assert
      verify(
        mockTraktApiBase.getJsonList(
          '/shows/watched/$testPeriod?extended=images&page=2&limit=20',
        ),
      ).called(1);
    });

    test('should throw an exception when the API call fails', () async {
      // Arrange
      when(
        mockTraktApiBase.getJsonList('/shows/watched/monthly?extended=images&page=1&limit=10'),
      ).thenThrow(Exception('API Error'));

      // Act & Assert
      expect(
        () => showsListsApi.getMostWatchedShows(),
        throwsA(isA<Exception>()),
      );
    });
  });
}
