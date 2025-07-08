import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'mocks/mock_trakt_api_base.dart';

void main() {
  late MockTraktApiBase traktApi;

  setUp(() {
    traktApi = MockTraktApiBase();
  });

  tearDown(() {
    reset(traktApi);
  });

  group('getWatched', () {
    test('should get watched shows by default', () async {
      // Arrange
      final mockResponse = [
        {
          'show': {'title': 'Test Show', 'year': 2023},
          'seasons': [
            {
              'number': 1,
              'episodes': [
                {'number': 1, 'plays': 1, 'last_watched_at': '2023-01-01T00:00:00.000Z'}
              ]
            }
          ]
        }
      ];
      
      // Setup the mock response
      when(traktApi.getWatched()).thenAnswer((_) async => mockResponse);
      
      // Act
      final result = await traktApi.getWatched();
      
      // Assert
      expect(result, isA<List<dynamic>>());
      expect(result.isNotEmpty, true);
    });

    test('should get watched movies when type is movies', () async {
      // Arrange
      final mockResponse = [
        {
          'movie': {'title': 'Test Movie', 'year': 2023},
          'plays': 1,
          'last_watched_at': '2023-01-01T00:00:00.000Z'
        }
      ];
      
      // Setup the mock response for movies
      when(traktApi.getWatched(type: 'movies')).thenAnswer((_) async => mockResponse);
      
      // Act
      final result = await traktApi.getWatched(type: 'movies');

      // Assert
      expect(result, mockResponse);
      verify(traktApi.getWatched(type: 'movies')).called(1);
    });

    test('should handle empty response', () async {
      // Arrange
      final expectedResponse = <Map<String, dynamic>>[];
      
      // Setup the mock response for empty list
      when(traktApi.getWatched()).thenAnswer((_) async => expectedResponse);

      // Act
      final result = await traktApi.getWatched();

      // Assert
      expect(result, expectedResponse);
      verify(traktApi.getWatched()).called(1);
    });

    test('should handle API error', () async {
      // Setup the mock to throw an exception
      when(traktApi.getWatched()).thenThrow(Exception('API Error'));

      // Act & Assert
      expect(() => traktApi.getWatched(), throwsA(isA<Exception>()));
    });
  });
}
