import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'mocks/test_shows_lists_api.dart';
import 'mocks/anticipated_shows_mock_response.dart';

void main() {
  late TestShowsListsApi showsListsApi;
  late MockTraktApiBase mockTraktApiBase;

  setUp(() {
    mockTraktApiBase = MockTraktApiBase();
    showsListsApi = TestShowsListsApi(mockTraktApiBase);
  });

  group('getMostAnticipatedShows', () {
    test(
      'should return a list of most anticipated shows when the call is successful',
      () async {
        // Arrange
        when(
          mockTraktApiBase.getJsonList('/shows/anticipated?extended=images&page=1&limit=10'),
        ).thenAnswer((_) async => mostAnticipatedShowsResponse);

        // Act
        final result = await showsListsApi.getMostAnticipatedShows(
          page: 1,
          limit: 10,
        );

        // Assert
        expect(result, isA<List<dynamic>>());
        expect(result.length, 10);
        expect(result[0]['show']['title'], 'House of the Dragon');
        expect(result[0]['list_count'], 1524);
        verify(
          mockTraktApiBase.getJsonList('/shows/anticipated?extended=images&page=1&limit=10'),
        ).called(1);
      },
    );

    test('should call the correct endpoint', () async {
      // Arrange
      when(
        mockTraktApiBase.getJsonList('/shows/anticipated?extended=images&page=1&limit=10'),
      ).thenAnswer((_) async => []);

      // Act
      await showsListsApi.getMostAnticipatedShows();

      // Assert
      verify(
        mockTraktApiBase.getJsonList('/shows/anticipated?extended=images&page=1&limit=10'),
      );
    });

    test('should call the correct endpoint with pagination', () async {
      // Arrange
      when(
        mockTraktApiBase.getJsonList('/shows/anticipated?extended=images&page=2&limit=20'),
      ).thenAnswer((_) async => []);

      // Act
      await showsListsApi.getMostAnticipatedShows(
        page: 2,
        limit: 20,
      );

      // Assert
      verify(
        mockTraktApiBase.getJsonList('/shows/anticipated?extended=images&page=2&limit=20'),
      ).called(1);
    });

    test('should throw an exception when the API call fails', () async {
      // Arrange
      when(
        mockTraktApiBase.getJsonList('/shows/anticipated?extended=images&page=1&limit=10'),
      ).thenThrow(Exception('API Error'));

      // Act & Assert
      expect(
        () => showsListsApi.getMostAnticipatedShows(),
        throwsA(isA<Exception>()),
      );
    });
  });
}
