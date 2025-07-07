import 'package:mockito/mockito.dart';
import 'package:watching/services/trakt/trakt_api.dart';
import 'package:watching/services/trakt/shows_lists_api.dart';

// Create a mock TraktApiBase
class MockTraktApiBase extends Mock implements TraktApiBase {
  @override
  String get baseUrl => 'https://api.trakt.tv';
  
  @override
  Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'trakt-api-version': '2',
        'trakt-api-key': 'test-client-id',
      };
      
  @override
  Future<void> ensureValidToken() async {}
  
  @override
  Future<Map<String, dynamic>> getJsonMap(String endpoint) => 
      super.noSuchMethod(
        Invocation.method(#getJsonMap, [endpoint]),
        returnValue: Future<Map<String, dynamic>>.value({}),
      );
      
  @override
  Future<List<dynamic>> getJsonList(String endpoint) => 
      super.noSuchMethod(
        Invocation.method(#getJsonList, [endpoint]),
        returnValue: Future<List<dynamic>>.value([]),
      );
}

// Create a test class that extends Mock and implements the required interfaces
class TestShowsListsApi extends Mock implements TraktApiBase, ShowsListsApi {
  final TraktApiBase _apiBase;

  TestShowsListsApi(this._apiBase);

  // TraktApiBase implementation
  @override
  String get baseUrl => _apiBase.baseUrl;

  @override
  Map<String, String> get headers => _apiBase.headers;

  @override
  Future<void> ensureValidToken() async => _apiBase.ensureValidToken();

  @override
  Future<Map<String, dynamic>> getJsonMap(String endpoint) async {
    final result = await _apiBase.getJsonMap(endpoint);
    return Map<String, dynamic>.from(result);
  }

  @override
  Future<List<dynamic>> getJsonList(String endpoint) async {
    final result = await _apiBase.getJsonList(endpoint);
    return List<dynamic>.from(result);
  }

  // ShowsListsApi implementation - these will be mocked in tests
  @override
  Future<List<dynamic>> getTrendingShows() async {
    return _apiBase.getJsonList('/shows/trending?extended=images');
  }

  @override
  Future<List<dynamic>> getPopularShows() async {
    return _apiBase.getJsonList('/shows/popular?extended=images');
  }

  @override
  Future<List<dynamic>> getMostFavoritedShows({String period = 'monthly'}) async {
    return _apiBase.getJsonList('/shows/favorited?extended=images');
  }

  @override
  Future<List<dynamic>> getMostCollectedShows({String period = 'monthly'}) async {
    return _apiBase.getJsonList('/shows/collected/$period?extended=images');
  }

  @override
  Future<List<dynamic>> getMostPlayedShows({String period = 'monthly'}) async {
    return _apiBase.getJsonList('/shows/played/$period?extended=images');
  }

  @override
  Future<List<dynamic>> getMostWatchedShows({String period = 'monthly'}) async {
    return _apiBase.getJsonList('/shows/watched/$period?extended=images');
  }

  @override
  Future<List<dynamic>> getMostAnticipatedShows() async {
    return _apiBase.getJsonList('/shows/anticipated?extended=images');
  }
}
