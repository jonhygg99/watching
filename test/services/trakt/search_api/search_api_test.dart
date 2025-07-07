import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:watching/services/trakt/search_api.dart';
import 'package:watching/services/trakt/trakt_api.dart';
import 'mock/search_mock_responses.dart';

// Create a concrete implementation of TraktApiBase that includes SearchApi
class TestTraktApi extends TraktApiBase with SearchApi {
  @override
  final String baseUrl = 'https://api.trakt.tv';
  
  @override
  Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'trakt-api-version': '2',
    'trakt-api-key': 'test-client-id',
  };
  
  @override
  Future<void> ensureValidToken() async {}
  
  @override
  Future<Map<String, dynamic>> getJsonMap(String endpoint) async {
    return getJsonMapImpl?.call(endpoint) ?? {};
  }
  
  @override
  Future<List<dynamic>> getJsonList(String endpoint) async {
    return getJsonListImpl?.call(endpoint) ?? [];
  }
  
  // These will be set in tests
  Future<Map<String, dynamic>> Function(String)? getJsonMapImpl;
  Future<List<dynamic>> Function(String)? getJsonListImpl;
}

void main() {
  late TestTraktApi testApi;
  late SearchApi searchApi;

  setUp(() {
    testApi = TestTraktApi();
    searchApi = testApi;
  });

  group('SearchApi', () {
    test('should search for shows by default', () async {
      // Arrange
      testApi.getJsonListImpl = (_) => Future.value(mockShowSearchResponse);

      // Act
      final results = await searchApi.searchMoviesAndShows(
        query: 'tron',
      );

      // Assert
      expect(results, mockShowSearchResponse);
      expect(testApi.getJsonListImpl, isNotNull);
    });

    test('should search for movies when type is specified', () async {
      // Arrange
      testApi.getJsonListImpl = (_) => Future.value(mockMovieSearchResponse);

      // Act
      final results = await searchApi.searchMoviesAndShows(
        query: 'tron',
        type: 'movie',
      );

      // Assert
      expect(results, mockMovieSearchResponse);
      expect(testApi.getJsonListImpl, isNotNull);
    });

    test('should handle empty search results', () async {
      // Arrange
      testApi.getJsonListImpl = (_) => Future.value(mockEmptySearchResponse);

      // Act
      final results = await searchApi.searchMoviesAndShows(
        query: 'nonexistentquery',
      );

      // Assert
      expect(results, mockEmptySearchResponse);
      expect(testApi.getJsonListImpl, isNotNull);
    });

    test('should handle special characters in query', () async {
      // Arrange
      bool wasCalled = false;
      testApi.getJsonListImpl = (endpoint) {
        wasCalled = true;
        expect(endpoint, contains('tron%3A%20legacy'));
        return Future.value(<dynamic>[]);
      };

      // Act
      await searchApi.searchMoviesAndShows(
        query: 'tron: legacy',
      );

      // Assert
      expect(wasCalled, isTrue);
    });
  });
}
