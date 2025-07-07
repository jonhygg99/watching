import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'mocks/trending_shows_mock_response.dart';
import 'mocks/played_shows_mock_response.dart';
import 'mocks/collected_shows_mock_response.dart';
import 'mocks/watched_shows_mock_response.dart';
import 'mocks/anticipated_shows_mock_response.dart';
import 'mocks/popular_shows_mock_response.dart';
import 'mocks/favorited_shows_mock_response.dart';
import 'mocks/test_shows_lists_api.dart';



void main() {
  late MockTraktApiBase mockApi;
  late TestShowsListsApi showsListsApi;

  setUp(() {
    mockApi = MockTraktApiBase();
    showsListsApi = TestShowsListsApi(mockApi);
  });

  group('getTrendingShows', () {
    test('returns a list of trending shows when the call is successful',
        () async {
      // Arrange
      when(mockApi.getJsonList('/shows/trending?extended=images'))
          .thenAnswer((_) async => trendingShowsResponse);

      // Act
      final result = await showsListsApi.getTrendingShows();

      // Assert
      expect(result, isA<List<dynamic>>());
      expect(result.length, 2);
      expect(result[0]['show']['title'], 'Breaking Bad');
      expect(result[1]['show']['title'], 'The Walking Dead');
      verify(mockApi.getJsonList('/shows/trending?extended=images')).called(1);
    });

    test('throws an exception when the call fails', () async {
      // Arrange
      when(mockApi.getJsonList('/shows/trending?extended=images'))
          .thenThrow(Exception('Failed to load trending shows'));

      // Act & Assert
      expect(
        () => showsListsApi.getTrendingShows(),
        throwsA(isA<Exception>()),
      );
    });

    test('includes the correct number of watchers for each show', () async {
      // Arrange
      when(mockApi.getJsonList('/shows/trending?extended=images'))
          .thenAnswer((_) async => trendingShowsResponse);

      // Act
      final result = await showsListsApi.getTrendingShows();

      // Assert
      expect(result[0]['watchers'], 541);
      expect(result[1]['watchers'], 432);
    });

    test('includes correct show IDs for each show', () async {
      // Arrange
      when(mockApi.getJsonList('/shows/trending?extended=images'))
          .thenAnswer((_) async => trendingShowsResponse);

      // Act
      final result = await showsListsApi.getTrendingShows();

      // Assert
      final firstShow = result[0]['show'];
      final secondShow = result[1]['show'];

      expect(firstShow['ids']['trakt'], 1);
      expect(firstShow['ids']['imdb'], 'tt0903747');
      expect(firstShow['ids']['tmdb'], 1396);
      
      expect(secondShow['ids']['trakt'], 2);
      expect(secondShow['ids']['imdb'], 'tt1520211');
      expect(secondShow['ids']['tmdb'], 1402);
    });

    test('calls the correct endpoint with extended images', () async {
      // Arrange
      when(mockApi.getJsonList('/shows/trending?extended=images'))
          .thenAnswer((_) async => trendingShowsResponse);

      // Act
      await showsListsApi.getTrendingShows();

      // Assert
      verify(mockApi.getJsonList('/shows/trending?extended=images')).called(1);
    });
  });

  group('getMostPlayedShows', () {
    test('returns list of most played shows when API call is successful',
        () async {
      // Arrange
      when(mockApi.getJsonList('/shows/played/monthly?extended=images'))
          .thenAnswer((_) async => List<Map<String, dynamic>>.from(mostPlayedShowsResponse));

      // Act
      final result = await showsListsApi.getMostPlayedShows();

      // Assert
      expect(result, isA<List<dynamic>>());
      expect(result.length, 10);
      expect(result[0]['show']['title'], 'The Big Bang Theory');
      expect(result[0]['play_count'], 23542030);
      expect(result[0]['show']['ids']['trakt'], 1409);
    });

    test('includes correct period parameter in API call', () async {
      // Arrange
      const testPeriod = 'weekly';
      when(mockApi.getJsonList('/shows/played/$testPeriod?extended=images'))
          .thenAnswer((_) async => []);

      // Act
      await showsListsApi.getMostPlayedShows(period: testPeriod);

      // Assert
      verify(mockApi.getJsonList('/shows/played/$testPeriod?extended=images'));
    });

    test('throws exception when API call fails', () async {
      // Arrange
      when(mockApi.getJsonList('/shows/played/monthly?extended=images'))
          .thenThrow(Exception('API Error'));

      // Act & Assert
      expect(
        () => showsListsApi.getMostPlayedShows(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('getMostCollectedShows', () {
    test('returns list of most collected shows when API call is successful',
        () async {
      // Arrange
      when(mockApi.getJsonList('/shows/collected/monthly?extended=images'))
          .thenAnswer((_) async => List<Map<String, dynamic>>.from(mostCollectedShowsResponse));

      // Act
      final result = await showsListsApi.getMostCollectedShows();

      // Assert
      expect(result, isA<List<dynamic>>());
      expect(result.length, 10);
      expect(result[0]['show']['title'], 'The Simpsons');
      expect(result[0]['collected_count'], 7427018);
      expect(result[1]['show']['title'], 'The Big Bang Theory');
      expect(result[1]['show']['ids']['trakt'], 1409);
    });

    test('includes correct period parameter in API call', () async {
      // Arrange
      const testPeriod = 'yearly';
      when(mockApi.getJsonList('/shows/collected/$testPeriod?extended=images'))
          .thenAnswer((_) async => []);

      // Act
      await showsListsApi.getMostCollectedShows(period: testPeriod);

      // Assert
      verify(mockApi.getJsonList('/shows/collected/$testPeriod?extended=images'));
    });

    test('throws exception when API call fails', () async {
      // Arrange
      when(mockApi.getJsonList('/shows/collected/monthly?extended=images'))
          .thenThrow(Exception('API Error'));

      // Act & Assert
      expect(
        () => showsListsApi.getMostCollectedShows(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('getPopularShows', () {
    test('returns list of popular shows when API call is successful', () async {
      // Arrange
      when(mockApi.getJsonList('/shows/popular?extended=images'))
          .thenAnswer((_) async => List<Map<String, dynamic>>.from(popularShowsResponse));

      // Act
      final result = await showsListsApi.getPopularShows();

      // Assert
      expect(result, isA<List<dynamic>>());
      expect(result.length, 10);
      expect(result[0]['title'], 'Community');
      expect(result[0]['year'], 2009);
      expect(result[0]['ids']['trakt'], 41);
    });

    test('calls the correct endpoint', () async {
      // Arrange
      when(mockApi.getJsonList('/shows/popular?extended=images'))
          .thenAnswer((_) async => []);

      // Act
      await showsListsApi.getPopularShows();

      // Assert
      verify(mockApi.getJsonList('/shows/popular?extended=images'));
    });

    test('throws exception when API call fails', () async {
      // Arrange
      when(mockApi.getJsonList('/shows/popular?extended=images'))
          .thenThrow(Exception('API Error'));

      // Act & Assert
      expect(
        () => showsListsApi.getPopularShows(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('getMostFavoritedShows', () {
    test('returns list of most favorited shows when API call is successful', () async {
      // Arrange
      when(mockApi.getJsonList('/shows/favorited?extended=images'))
          .thenAnswer((_) async => List<Map<String, dynamic>>.from(mostFavoritedShowsResponse));

      // Act
      final result = await showsListsApi.getMostFavoritedShows();

      // Assert
      expect(result, isA<List<dynamic>>());
      expect(result.length, 3);
      expect(result[0]['show']['title'], 'The Big Bang Theory');
      expect(result[0]['user_count'], 155291);
      expect(result[1]['show']['title'], "Grey's Anatomy");
      expect(result[2]['show']['title'], 'Game of Thrones');
    });

    test('calls the correct endpoint', () async {
      // Arrange
      when(mockApi.getJsonList('/shows/favorited?extended=images'))
          .thenAnswer((_) async => []);

      // Act
      await showsListsApi.getMostFavoritedShows();

      // Assert
      verify(mockApi.getJsonList('/shows/favorited?extended=images'));
    });

    test('includes period parameter when specified', () async {
      // Arrange
      const testPeriod = 'weekly';
      when(mockApi.getJsonList('/shows/favorited?extended=images'))
          .thenAnswer((_) async => []);

      // Act
      await showsListsApi.getMostFavoritedShows(period: testPeriod);

      // Assert - Note: The period parameter doesn't affect the endpoint for favorited shows
      verify(mockApi.getJsonList('/shows/favorited?extended=images'));
    });
  });

  group('getMostWatchedShows', () {
    test('returns list of most watched shows when API call is successful', () async {
      // Arrange
      when(mockApi.getJsonList('/shows/watched/monthly?extended=images'))
          .thenAnswer((_) async => List<Map<String, dynamic>>.from(mostWatchedShowsResponse));

      // Act
      final result = await showsListsApi.getMostWatchedShows();

      // Assert
      expect(result, isA<List<dynamic>>());
      expect(result.length, 10);
      expect(result[0]['show']['title'], 'Game of Thrones');
      expect(result[0]['watcher_count'], 203742);
    });

    test('includes correct period parameter in API call', () async {
      // Arrange
      const testPeriod = 'yearly';
      when(mockApi.getJsonList('/shows/watched/$testPeriod?extended=images'))
          .thenAnswer((_) async => []);

      // Act
      await showsListsApi.getMostWatchedShows(period: testPeriod);

      // Assert
      verify(mockApi.getJsonList('/shows/watched/$testPeriod?extended=images'));
    });

    test('throws exception when API call fails', () async {
      // Arrange
      when(mockApi.getJsonList('/shows/watched/monthly?extended=images'))
          .thenThrow(Exception('API Error'));

      // Act & Assert
      expect(
        () => showsListsApi.getMostWatchedShows(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('getMostAnticipatedShows', () {
    test('returns list of most anticipated shows when API call is successful', () async {
      // Arrange
      when(mockApi.getJsonList('/shows/anticipated?extended=images'))
          .thenAnswer((_) async => List<Map<String, dynamic>>.from(mostAnticipatedShowsResponse));

      // Act
      final result = await showsListsApi.getMostAnticipatedShows();

      // Assert
      expect(result, isA<List<dynamic>>());
      expect(result.length, 10);
      expect(result[0]['show']['title'], 'House of the Dragon');
      expect(result[0]['list_count'], 1524);
    });

    test('calls the correct endpoint', () async {
      // Arrange
      when(mockApi.getJsonList('/shows/anticipated?extended=images'))
          .thenAnswer((_) async => []);

      // Act
      await showsListsApi.getMostAnticipatedShows();

      // Assert
      verify(mockApi.getJsonList('/shows/anticipated?extended=images'));
    });

    test('throws exception when API call fails', () async {
      // Arrange
      when(mockApi.getJsonList('/shows/anticipated?extended=images'))
          .thenThrow(Exception('API Error'));

      // Act & Assert
      expect(
        () => showsListsApi.getMostAnticipatedShows(),
        throwsA(isA<Exception>()),
      );
    });
  });
}
