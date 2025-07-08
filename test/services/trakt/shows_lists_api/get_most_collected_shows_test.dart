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
            '/shows/collected/monthly?extended=images',
          ),
        ).thenAnswer((_) async => mostCollectedShowsResponse);

        // Act
        final result = await showsListsApi.getMostCollectedShows();

        // Assert
        expect(result, isA<List<dynamic>>());
        expect(result.length, 10);
        expect(result[0]['show']['title'], 'The Simpsons');
        expect(result[0]['collected_count'], 7427018);
        verify(
          mockTraktApiBase.getJsonList(
            '/shows/collected/monthly?extended=images',
          ),
        ).called(1);
      },
    );

    test('should include correct period parameter in API call', () async {
      // Arrange
      const testPeriod = 'yearly';
      when(
        mockTraktApiBase.getJsonList(
          '/shows/collected/$testPeriod?extended=images',
        ),
      ).thenAnswer((_) async => []);

      // Act
      await showsListsApi.getMostCollectedShows(period: testPeriod);

      // Assert
      verify(
        mockTraktApiBase.getJsonList(
          '/shows/collected/$testPeriod?extended=images',
        ),
      );
    });

    test('should throw an exception when the API call fails', () async {
      // Arrange
      when(
        mockTraktApiBase.getJsonList(
          '/shows/collected/monthly?extended=images',
        ),
      ).thenThrow(Exception('API Error'));

      // Act & Assert
      expect(showsListsApi.getMostCollectedShows, throwsA(isA<Exception>()));
    });
  });
}
