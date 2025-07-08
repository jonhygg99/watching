import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'mocks/test_shows_lists_api.dart';
import 'mocks/popular_shows_mock_response.dart';

void main() {
  late TestShowsListsApi showsListsApi;
  late MockTraktApiBase mockTraktApiBase;

  setUp(() {
    mockTraktApiBase = MockTraktApiBase();
    showsListsApi = TestShowsListsApi(mockTraktApiBase);
  });

  group('getPopularShows', () {
    test(
      'should return a list of popular shows when the call is successful',
      () async {
        // Arrange
        when(
          mockTraktApiBase.getJsonList('/shows/popular?extended=images'),
        ).thenAnswer((_) async => popularShowsResponse);

        // Act
        final result = await showsListsApi.getPopularShows();

        // Assert
        expect(result, isA<List<dynamic>>());
        expect(result.length, 10);
        expect(result[0]['title'], 'Community');
        expect(result[0]['year'], 2009);
        verify(
          mockTraktApiBase.getJsonList('/shows/popular?extended=images'),
        ).called(1);
      },
    );

    test('should call the correct endpoint', () async {
      // Arrange
      when(
        mockTraktApiBase.getJsonList('/shows/popular?extended=images'),
      ).thenAnswer((_) async => []);

      // Act
      await showsListsApi.getPopularShows();

      // Assert
      verify(mockTraktApiBase.getJsonList('/shows/popular?extended=images'));
    });

    test('should throw an exception when the API call fails', () async {
      // Arrange
      when(
        mockTraktApiBase.getJsonList('/shows/popular?extended=images'),
      ).thenThrow(Exception('API Error'));

      // Act & Assert
      expect(showsListsApi.getPopularShows, throwsA(isA<Exception>()));
    });
  });
}
