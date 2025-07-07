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

  group('removeFromHistory', () {
    test('should remove movie from history', () async {
      // Arrange
      final movie = {'ids': {'trakt': 123}};
      
      // Arrange
      final expectedResponse = {
        'deleted': {'movies': 1, 'shows': 0, 'seasons': 0, 'episodes': 0},
        'not_found': {'movies': [], 'shows': [], 'seasons': [], 'episodes': []}
      };
      
      // Setup the mock response
      when(traktApi.removeFromHistory(movies: [movie], ids: null))
          .thenAnswer((_) async => expectedResponse);
      
      // Act
      final result = await traktApi.removeFromHistory(
        movies: [movie],
        ids: null,
      );
      
      // Assert
      expect(result, isA<Map<String, dynamic>>());
      expect(result['deleted'], isNotNull);
      verify(traktApi.removeFromHistory(movies: [movie], ids: null)).called(1);
    });

    test('should remove show from history', () async {
      // Arrange
      final show = {'ids': {'trakt': 456}};
      
      // Arrange
      final expectedResponse = {
        'deleted': {'movies': 0, 'shows': 1, 'seasons': 0, 'episodes': 0},
        'not_found': {'movies': [], 'shows': [], 'seasons': [], 'episodes': []}
      };
      
      // Setup the mock response
      when(traktApi.removeFromHistory(shows: [show], ids: null))
          .thenAnswer((_) async => expectedResponse);
      
      // Act
      final result = await traktApi.removeFromHistory(
        shows: [show],
        ids: null,
      );
      
      // Assert
      expect(result, isA<Map<String, dynamic>>());
      verify(traktApi.removeFromHistory(shows: [show], ids: null)).called(1);
    });

    test('should remove items by history ids', () async {
      // Arrange
      final historyIds = [123, 456];
      final expectedResponse = {
        'deleted': {'movies': 1, 'shows': 0, 'seasons': 0, 'episodes': 1},
        'not_found': {'movies': [], 'shows': [], 'seasons': [], 'episodes': []}
      };
      // Setup the mock response
      when(traktApi.removeFromHistory(ids: historyIds))
          .thenAnswer((_) async => expectedResponse);

      // Act
      final result = await traktApi.removeFromHistory(ids: historyIds);

      // Assert
      expect(result, expectedResponse);
      verify(traktApi.removeFromHistory(ids: historyIds)).called(1);
    });

    test('should throw exception on API error', () async {
      // Arrange
      // Setup the mock to throw an exception
      when(traktApi.removeFromHistory(
        movies: [{'ids': {'trakt': 123}}],
        ids: null,
      )).thenThrow(Exception('API Error'));
      
      // Act & Assert
      expect(
        () => traktApi.removeFromHistory(
          movies: [{'ids': {'trakt': 123}}],
          ids: null,
        ),
        throwsA(isA<Exception>()),
      );
      
      // Verify the method was called
      verify(traktApi.removeFromHistory(
        movies: [{'ids': {'trakt': 123}}],
        ids: null,
      )).called(1);
    });
  });
}
