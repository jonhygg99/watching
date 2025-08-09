import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'mocks/test_shows_lists_api.dart';
import 'mocks/favorited_shows_mock_response.dart';

void main() {
  late TestShowsListsApi showsListsApi;
  late MockTraktApiBase mockTraktApiBase;

  setUp(() {
    mockTraktApiBase = MockTraktApiBase();
    showsListsApi = TestShowsListsApi(mockTraktApiBase);
  });

  group('getMostFavoritedShows', () {
    test(
      'should return a list of most favorited shows when the call is successful',
      () async {
        // Arrange
        when(
          mockTraktApiBase.getJsonList('/shows/favorited/monthly?extended=images&page=1&limit=10'),
        ).thenAnswer((_) async => mostFavoritedShowsResponse);

        // Act
        final result = await showsListsApi.getMostFavoritedShows(
          period: 'monthly',
          page: 1,
          limit: 10,
        );

        // Assert
        expect(result, isA<List<dynamic>>());
        expect(result.length, 3);
        expect(result[0]['show']['title'], 'The Big Bang Theory');
        expect(result[0]['user_count'], 155291);
        verify(
          mockTraktApiBase.getJsonList('/shows/favorited/monthly?extended=images&page=1&limit=10'),
        ).called(1);
      },
    );

    test('should call the correct endpoint with pagination', () async {
      // Arrange
      when(
        mockTraktApiBase.getJsonList('/shows/favorited/weekly?extended=images&page=2&limit=20'),
      ).thenAnswer((_) async => []);

      // Act
      await showsListsApi.getMostFavoritedShows(
        period: 'weekly',
        page: 2,
        limit: 20,
      );

      // Assert
      verify(mockTraktApiBase.getJsonList('/shows/favorited/weekly?extended=images&page=2&limit=20'));
    });

    test('should include period parameter when specified', () async {
      // Arrange
      const testPeriod = 'weekly';
      when(
        mockTraktApiBase.getJsonList('/shows/favorited/$testPeriod?extended=images&page=1&limit=10'),
      ).thenAnswer((_) async => []);

      // Act
      await showsListsApi.getMostFavoritedShows(period: testPeriod);

      // Assert
      verify(mockTraktApiBase.getJsonList('/shows/favorited/$testPeriod?extended=images&page=1&limit=10'));
    });
  });
}
