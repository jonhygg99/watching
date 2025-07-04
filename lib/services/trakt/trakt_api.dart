import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'shows_api.dart';
import 'shows_lists_api.dart';
import 'history_api.dart';
import 'user_api.dart';
import 'search_api.dart';

/// The main entry point for all Trakt API operations.
///
/// Composes all domain-specific API mixins (shows, history, user) and provides
/// shared logic for token management, headers, and utility methods.
///
/// To use, instantiate [TraktApi] and call any endpoint method directly.
///
/// Example:
///   final trakt = TraktApi();
///   final shows = await trakt.getPopularShows();
abstract class TraktApiBase {
  Future<void> ensureValidToken();
  Future<dynamic> getJsonMap(String endpoint);
  Future<List<dynamic>> getJsonList(String endpoint);
  String get baseUrl;
  Map<String, String> get headers;
}

class TraktApi extends TraktApiBase
    with ShowsApi, ShowsListsApi, HistoryApi, UserApi, SearchApi {
  TraktApi();

  // --- BASE CONFIGURATION ---
  @override
  final String baseUrl = 'https://api.trakt.tv';
  final String? clientId = dotenv.env['TRAKT_CLIENT_ID'];
  final String? clientSecret = dotenv.env['TRAKT_CLIENT_SECRET'];
  final String? redirectUri = dotenv.env['TRAKT_REDIRECT_URI'];

  String? _accessToken;

  /// Loads the access token from SharedPreferences.
  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
  }

  /// Saves token, refresh_token, and expiration to SharedPreferences.
  Future<void> saveTokenData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    if (data['access_token'] != null) {
      await prefs.setString('access_token', data['access_token']);
      _accessToken = data['access_token'];
    }
    if (data['refresh_token'] != null) {
      await prefs.setString('refresh_token', data['refresh_token']);
    }
    if (data['expires_in'] != null) {
      final expiresAt =
          DateTime.now().millisecondsSinceEpoch ~/ 1000 +
          (data['expires_in'] as int);
      await prefs.setInt('expires_at', expiresAt);
    }
  }

  /// Removes the access token from storage.
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    _accessToken = null;
  }

  /// Ensures the access token is valid and refreshes it if needed.
  @override
  Future<void> ensureValidToken() async {
    final prefs = await SharedPreferences.getInstance();
    final expiresAt = prefs.getInt('expires_at');
    final refreshTk = prefs.getString('refresh_token');
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if (expiresAt != null && expiresAt <= now && refreshTk != null) {
      await refreshToken(refreshTk);
    } else if (_accessToken == null) {
      await loadToken();
    }
  }

  /// Returns the headers for authenticated requests.
  @override
  Map<String, String> get headers {
    final headers = {
      'Content-Type': 'application/json',
      'trakt-api-version': '2',
      'trakt-api-key': clientId ?? '',
    };
    if (_accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    return headers;
  }

  // --- UTILITY METHODS ---

  /// Performs a GET request and returns a JSON-decoded list.
  @override
  Future<List<dynamic>> getJsonList(String endpoint) async {
    await ensureValidToken();
    final url = Uri.parse('$baseUrl$endpoint');
    final usedHeaders = headers;
    final response = await http.get(url, headers: usedHeaders);
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception(
        'Error GET $endpoint: ${response.statusCode}\n${response.body}',
      );
    }
  }

  /// Performs a GET request and returns a JSON-decoded map.
  @override
  Future<Map<String, dynamic>> getJsonMap(String endpoint) async {
    await ensureValidToken();
    final url = Uri.parse('$baseUrl$endpoint');
    final usedHeaders = headers;
    final response = await http.get(url, headers: usedHeaders);
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
        'Error GET $endpoint: ${response.statusCode}\n${response.body}',
      );
    }
  }

  /// Performs a GET request with auth headers.
  Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.get(url, headers: headers);
  }

  /// Performs a POST request with auth headers.
  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.post(url, headers: headers, body: jsonEncode(body));
  }

  /// Performs a DELETE request with auth headers.
  Future<http.Response> delete(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.delete(url, headers: headers);
  }

  // --- OAUTH ---

  /// Exchanges an authorization code for an access token.
  Future<Map<String, dynamic>> getToken(String code) async {
    final url = Uri.parse('$baseUrl/oauth/token');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'code': code,
        'client_id': clientId,
        'client_secret': clientSecret,
        'redirect_uri': redirectUri,
        'grant_type': 'authorization_code',
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await saveTokenData(data);
      return data;
    } else {
      throw Exception(
        'Error al obtener el token: \nStatus: ${response.statusCode}\nBody: ${response.body}',
      );
    }
  }

  /// Refreshes the access token using a refresh_token.
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final url = Uri.parse('$baseUrl/oauth/token');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'refresh_token': refreshToken,
        'client_id': clientId,
        'client_secret': clientSecret,
        'redirect_uri': redirectUri,
        'grant_type': 'refresh_token',
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await saveTokenData(data);
      return data;
    } else {
      throw Exception(
        'Error al refrescar el token: \nStatus: ${response.statusCode}\nBody: ${response.body}',
      );
    }
  }

  /// Revokes the Trakt.tv token.
  Future<void> revokeToken(String token) async {
    final url = Uri.parse('$baseUrl/oauth/revoke');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'token': token,
        'client_id': clientId,
        'client_secret': clientSecret,
      }),
    );
    if (response.statusCode == 200) {
      await clearToken();
    } else {
      throw Exception(
        'Error al revocar el token: \nStatus: ${response.statusCode}\nBody: ${response.body}',
      );
    }
  }

  /// Builds the OAuth authorization URL for Trakt.tv.
  String getAuthorizationUrl({
    String state = 'login',
    Map<String, String>? extraParams,
  }) {
    final params = {
      'response_type': 'code',
      'client_id': clientId ?? '',
      'redirect_uri': redirectUri ?? '',
      'state': state,
      ...?extraParams,
    };
    final uri = Uri.https('trakt.tv', '/oauth/authorize', params);
    return uri.toString();
  }
}
