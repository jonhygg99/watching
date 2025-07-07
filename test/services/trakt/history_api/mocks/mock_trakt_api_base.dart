import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:watching/services/trakt/trakt_api.dart';
import 'package:watching/services/trakt/history_api.dart';

// Create a mock TraktApiBase
class MockTraktApiBase extends Mock implements TraktApiBase, HistoryApi {
  @override
  final String baseUrl = 'https://api.trakt.tv';
  
  // Client getter for internal use - not part of the interface but needed for testing
  final http.Client _client = MockClient();
  http.Client get client => _client;
  
  @override
  Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'trakt-api-version': '2',
        'trakt-api-key': 'test-client-id',
        'Authorization': 'Bearer test-access-token',
      };
      
  @override
  Future<void> ensureValidToken() async {}
  
  @override
  Future<Map<String, dynamic>> getJsonMap(String endpoint, {Map<String, String>? params}) async {
    return super.noSuchMethod(
      Invocation.method(#getJsonMap, [endpoint], {#params: params}),
      returnValue: Future<Map<String, dynamic>>.value(<String, dynamic>{}),
    ) as Future<Map<String, dynamic>>;
  }
  
  @override
  Future<List<dynamic>> getJsonList(String endpoint, {Map<String, String>? params}) async {
    return super.noSuchMethod(
      Invocation.method(#getJsonList, [endpoint], {#params: params}),
      returnValue: Future<List<dynamic>>.value(<dynamic>[]),
    ) as Future<List<dynamic>>;
  }
      
  // Implement HistoryApi methods
  @override
  Future<void> addToWatchHistory({
    List<Map<String, dynamic>>? movies,
    List<Map<String, dynamic>>? shows,
    List<Map<String, dynamic>>? seasons,
    List<Map<String, dynamic>>? episodes,
  }) async {
    return super.noSuchMethod(
      Invocation.method(#addToWatchHistory, [], {
        if (movies != null) #movies: movies,
        if (shows != null) #shows: shows,
        if (seasons != null) #seasons: seasons,
        if (episodes != null) #episodes: episodes,
      }),
      returnValue: Future<void>.value(),
    ) as Future<void>;
  }
  
  @override
  Future<List<dynamic>> getWatched({String type = 'shows'}) async {
    return super.noSuchMethod(
      Invocation.method(#getWatched, [], {#type: type}),
      returnValue: Future<List<dynamic>>.value(<dynamic>[]),
    ) as Future<List<dynamic>>;
  }
  
  @override
  Future<List<dynamic>> getWatchlist({
    String type = 'shows',
    String sort = 'watched',
  }) async {
    return super.noSuchMethod(
      Invocation.method(#getWatchlist, [], {#type: type, #sort: sort}),
      returnValue: Future<List<dynamic>>.value(<dynamic>[]),
    ) as Future<List<dynamic>>;
  }
  
  @override
  Future<Map<String, dynamic>> removeFromHistory({
    List<Map<String, dynamic>>? movies,
    List<Map<String, dynamic>>? shows,
    List<Map<String, dynamic>>? seasons,
    List<Map<String, dynamic>>? episodes,
    List<int>? ids,
  }) async {
    return super.noSuchMethod(
      Invocation.method(#removeFromHistory, [], {
        if (movies != null) #movies: movies,
        if (shows != null) #shows: shows,
        if (seasons != null) #seasons: seasons,
        if (episodes != null) #episodes: episodes,
        if (ids != null) #ids: ids,
      }),
      returnValue: Future<Map<String, dynamic>>.value(<String, dynamic>{}),
    ) as Future<Map<String, dynamic>>;
  }

  // Implementation of postJson for testing - not part of the interface but needed for testing
  Future<Map<String, dynamic>> postJson(String path, {dynamic body, Map<String, String>? params}) async {
    return super.noSuchMethod(
      Invocation.method(#postJson, [path], {#body: body, #params: params}),
      returnValue: Future<Map<String, dynamic>>.value(<String, dynamic>{}),
    ) as Future<Map<String, dynamic>>;
  }
}

// Helper class to mock HTTP client
class MockClient extends Mock implements http.Client {
  @override
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    return super.noSuchMethod(
      Invocation.method(#get, [url], {#headers: headers}),
      returnValue: Future<http.Response>.value(http.Response('[]', 200)),
    ) as Future<http.Response>;
  }
  
  @override
  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    return super.noSuchMethod(
      Invocation.method(#post, [url], {
        #headers: headers,
        #body: body,
        #encoding: encoding,
      }),
      returnValue: Future<http.Response>.value(http.Response('{}', 200)),
    ) as Future<http.Response>;
  }
  
  @override
  void close() {}
}

// Main function for running tests
void main() {
  // This is intentionally left empty as it's used for code generation
}
