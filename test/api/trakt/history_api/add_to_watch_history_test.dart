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

  group('addToWatchHistory', () {
    test('should add movie to watch history', () async {
      // Arrange
      final movie = {'ids': {'trakt': 123}};
      
      // Setup the mock response
      when(traktApi.addToWatchHistory(movies: [movie]))
          .thenAnswer((_) async {});
      
      // Act & Assert
      await expectLater(
        traktApi.addToWatchHistory(movies: [movie]),
        completes,
      );
      
      // Verify the method was called
      verify(traktApi.addToWatchHistory(movies: [movie])).called(1);
    });

    test('should add show to watch history', () async {
      // Arrange
      final show = {'ids': {'trakt': 456}};
      
      // Setup the mock response
      when(traktApi.addToWatchHistory(shows: [show]))
          .thenAnswer((_) async {});
      
      // Act & Assert
      await expectLater(
        traktApi.addToWatchHistory(shows: [show]),
        completes,
      );
      
      // Verify the method was called
      verify(traktApi.addToWatchHistory(shows: [show])).called(1);
    });

    test('should add season to watch history', () async {
      // Arrange
      final season = {'ids': {'trakt': 789}, 'seasons': [{'number': 1}]};
      
      // Setup the mock response
      when(traktApi.addToWatchHistory(seasons: [season]))
          .thenAnswer((_) async {});
      
      // Act & Assert
      await expectLater(
        traktApi.addToWatchHistory(seasons: [season]),
        completes,
      );
      
      // Verify the method was called
      verify(traktApi.addToWatchHistory(seasons: [season])).called(1);
    });

    test('should add episode to watch history', () async {
      // Arrange
      final episode = {'ids': {'trakt': 101}, 'episodes': [{'number': 1, 'season': 1}]};
      
      // Setup the mock response
      when(traktApi.addToWatchHistory(episodes: [episode]))
          .thenAnswer((_) async {});

      // Act & Assert
      await expectLater(
        traktApi.addToWatchHistory(episodes: [episode]),
        completes,
      );

      // Verify the method was called
      verify(traktApi.addToWatchHistory(episodes: [episode])).called(1);
    });

    test('should throw exception on API error', () async {
      // Arrange
      final movie = {'ids': {'trakt': 123}};
      
      // Setup the mock to throw an exception
      when(traktApi.addToWatchHistory(movies: [movie]))
          .thenThrow(Exception('API Error'));
      
      // Act & Assert
      expect(
        () => traktApi.addToWatchHistory(movies: [movie]),
        throwsA(isA<Exception>()),
      );
      
      // Verify the method was called
      verify(traktApi.addToWatchHistory(movies: [movie])).called(1);
    });
  });
}
