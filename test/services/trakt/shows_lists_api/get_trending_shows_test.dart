import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'mocks/test_shows_lists_api.dart';
import 'mocks/trending_shows_mock_response.dart';

void main() {
  late TestShowsListsApi showsListsApi;
  late MockTraktApiBase mockTraktApiBase;

  setUp(() {
    mockTraktApiBase = MockTraktApiBase();
    showsListsApi = TestShowsListsApi(mockTraktApiBase);
  });

  group('getTrendingShows', () {
    test(
      'should return a list of trending shows when the call is successful',
      () async {
        // Arrange
        when(
          mockTraktApiBase.getJsonList('/shows/trending?extended=images'),
        ).thenAnswer((_) async => trendingShowsResponse);

        // Act
        final result = await showsListsApi.getTrendingShows();

        // Assert
        expect(result, isA<List<dynamic>>());
        expect(result.length, 2);
        expect(result[0]['show']['title'], 'Breaking Bad');
        expect(result[1]['show']['title'], 'The Walking Dead');
        verify(
          mockTraktApiBase.getJsonList('/shows/trending?extended=images'),
        ).called(1);
      },
    );

    test(
      'should throw an exception when the API call fails',
      () async {
        // Arrange
        when(
          mockTraktApiBase.getJsonList('/shows/trending?extended=images'),
        ).thenThrow(Exception('Failed to fetch trending shows'));

        // Act & Assert
        expect(
          showsListsApi.getTrendingShows,
          throwsA(isA<Exception>()),
        );
      },
    );
  });
}
