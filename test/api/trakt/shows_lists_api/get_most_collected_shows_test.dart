import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'mocks/test_shows_lists_api.dart';
import 'mocks/collected_shows_mock_response.dart';

void main() {
  late TestShowsListsApi showsListsApi;
  late MockTraktApiBase mockTraktApiBase;

  setUp(() {
    mockTraktApiBase = MockTraktApiBase();
    showsListsApi = TestShowsListsApi(mockTraktApiBase);
  });

  group('getMostCollectedShows', () {
    test(
      'should return a list of most collected shows when the call is successful',
      () async {
        // Arrange
        when(
          mockTraktApiBase.getJsonList(
            '/shows/collected/monthly?extended=images&page=1&limit=10',
          ),
        ).thenAnswer((_) async => mostCollectedShowsResponse);

        // Act
        final result = await showsListsApi.getMostCollectedShows(
          page: 1,
          limit: 10,
        );

        // Assert
        expect(result, isA<List<dynamic>>());
        expect(result.length, 10);
        expect(result[0]['show']['title'], 'The Simpsons');
        expect(result[0]['collected_count'], 7427018);
        verify(
          mockTraktApiBase.getJsonList(
            '/shows/collected/monthly?extended=images&page=1&limit=10',
          ),
        ).called(1);
      },
    );

    test('should include correct period and pagination parameters in API call', () async {
      // Arrange
      const testPeriod = 'yearly';
      when(
        mockTraktApiBase.getJsonList(
          '/shows/collected/$testPeriod?extended=images&page=2&limit=20',
        ),
      ).thenAnswer((_) async => []);

      // Act
      await showsListsApi.getMostCollectedShows(
        period: testPeriod,
        page: 2,
        limit: 20,
      );

      // Assert
      verify(
        mockTraktApiBase.getJsonList(
          '/shows/collected/$testPeriod?extended=images&page=2&limit=20',
        ),
      ).called(1);
    });

    test('should throw an exception when the API call fails', () async {
      // Arrange
      when(
        mockTraktApiBase.getJsonList('/shows/collected/monthly?extended=images&page=1&limit=10'),
      ).thenThrow(Exception('API Error'));

      // Act & Assert
      expect(
        () => showsListsApi.getMostCollectedShows(),
        throwsA(isA<Exception>()),
      );
    });
  });
}
