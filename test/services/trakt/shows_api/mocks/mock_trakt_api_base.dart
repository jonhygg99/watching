import 'package:mockito/mockito.dart';
import 'dart:async';
import 'package:watching/services/trakt/trakt_api.dart';

class MockTraktApiBase extends Mock implements TraktApiBase {
  @override
  Future<Map<String, dynamic>> getJsonMap(String endpoint) async {
    return super.noSuchMethod(
      Invocation.method(#getJsonMap, [endpoint]),
      returnValue: <String, dynamic>{},
      returnValueForMissingStub: <String, dynamic>{},
    );
  }

  @override
  Future<List<dynamic>> getJsonList(String endpoint) async {
    return super.noSuchMethod(
      Invocation.method(#getJsonList, [endpoint]),
      returnValue: <dynamic>[],
      returnValueForMissingStub: <dynamic>[],
    );
  }
  
  @override
  Future<void> ensureValidToken() async {
    return super.noSuchMethod(
      Invocation.method(#ensureValidToken, []),
      returnValue: Future.value(),
      returnValueForMissingStub: Future.value(),
    );
  }
  
  @override
  String get baseUrl => 'https://api.trakt.tv';
  
  @override
  Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'trakt-api-version': '2',
    'trakt-api-key': 'mock-api-key',
  };
}
