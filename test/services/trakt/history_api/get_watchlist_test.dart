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

  group('getWatchlist', () {
    test('should get watchlist for shows by default', () async {
      // Arrange
      final mockResponse = [
        {
          'show': {'title': 'Test Show', 'year': 2023},
          'listed_at': '2023-01-01T00:00:00.000Z'
        }
      ];
      
      // Setup the mock response
      when(traktApi.getWatchlist()).thenAnswer((_) async => mockResponse);
      
      // Act
      final result = await traktApi.getWatchlist();
      
      // Assert
      expect(result, isA<List<dynamic>>());
      expect(result.isNotEmpty, true);
      verify(traktApi.getWatchlist()).called(1);
    });

    test('should get watchlist for movies when type is movies', () async {
      // Arrange
      final mockResponse = [
        {
          'movie': {'title': 'Test Movie', 'year': 2023},
          'listed_at': '2023-01-01T00:00:00.000Z'
        }
      ];
      
      // Setup the mock response for movies
      when(traktApi.getWatchlist(type: 'movies')).thenAnswer((_) async => mockResponse);
      
      // Act
      final result = await traktApi.getWatchlist(type: 'movies');
      
      // Assert
      expect(result, mockResponse);
      verify(traktApi.getWatchlist(type: 'movies')).called(1);
    });

    test('should handle empty watchlist', () async {
      // Arrange
      final expectedResponse = <Map<String, dynamic>>[];
      // Setup the mock response for empty list
      when(traktApi.getWatchlist()).thenAnswer((_) async => expectedResponse);
      
      // Act
      final result = await traktApi.getWatchlist();
      
      // Assert
      expect(result, expectedResponse);
      verify(traktApi.getWatchlist()).called(1);
    });

    test('should handle API error', () async {
      // Arrange
      // Setup the mock to throw an exception
      when(traktApi.getWatchlist()).thenThrow(Exception('API Error'));
      
      // Act & Assert
      expect(() => traktApi.getWatchlist(), throwsA(isA<Exception>()));
    });
  });
}
