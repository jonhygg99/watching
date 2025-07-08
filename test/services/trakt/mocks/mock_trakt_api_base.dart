import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:watching/services/trakt/trakt_api.dart';

// Create a mock TraktApiBase for testing
class MockTraktApiBase extends Mock implements TraktApiBase {
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
    return super.noSuchMethod(
      Invocation.method(#getJsonMap, [endpoint]),
      returnValue: Future<Map<String, dynamic>>.value(<String, dynamic>{}),
    ) as Future<Map<String, dynamic>>;
  }
  
  @override
  Future<List<dynamic>> getJsonList(String endpoint) async {
    return super.noSuchMethod(
      Invocation.method(#getJsonList, [endpoint]),
      returnValue: Future<List<dynamic>>.value(<dynamic>[]),
    ) as Future<List<dynamic>>;
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
