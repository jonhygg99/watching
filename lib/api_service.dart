import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

final apiService = ApiService();

class ApiService {
  final String baseUrl = 'https://api.trakt.tv';
  final String? clientId = dotenv.env['CLIENT_ID'];
  final String? clientSecret = dotenv.env['CLIENT_SECRET'];
  final String? redirectUri = dotenv.env['REDIRECT_URI'];

  static const _tokenKey = 'access_token';
  String? _accessToken;

  /// Cargar el token desde SharedPreferences
  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString(_tokenKey);
  }

  /// Guardar el token en SharedPreferences
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    _accessToken = token;
  }

  /// --- MÉTODOS PRIVADOS DE UTILIDAD ---

  /// Realiza una petición GET y retorna una lista JSON
  Future<List<dynamic>> _getJsonList(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.get(url, headers: _headersBase);
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Error GET $endpoint: ${response.statusCode}\n${response.body}');
    }
  }

  /// Realiza una petición GET y retorna un mapa JSON
  Future<Map<String, dynamic>> _getJsonMap(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.get(url, headers: _headersBase);
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Error GET $endpoint: ${response.statusCode}\n${response.body}');
    }
  }

  /// Headers base para peticiones públicas (sin token)
  Map<String, String> get _headersBase => {
    'Content-Type': 'application/json',
    'trakt-api-version': '2',
    'trakt-api-key': clientId ?? '',
  };

  /// --- MÉTODOS DE SHOWS ---

  /// Obtener los shows en tendencia de Trakt.tv
  Future<List<dynamic>> getTrendingShows({int page = 1, int limit = 10}) {
    return _getJsonList('/shows/trending?extended=images&page=$page&limit=$limit');
  }

  /// Obtener los shows populares de Trakt.tv
  Future<List<dynamic>> getPopularShows({int page = 1, int limit = 10}) {
    return _getJsonList('/shows/popular?extended=images&page=$page&limit=$limit');
  }

  /// Obtener los shows más favoritos según periodo (daily, weekly, monthly, all)
  Future<List<dynamic>> getMostFavoritedShows({String period = 'weekly', int page = 1, int limit = 10}) {
    return _getJsonList('/shows/favorited/$period?extended=images&page=$page&limit=$limit');
  }

  /// Obtener los shows más reproducidos según periodo (daily, weekly, monthly, all)
  Future<List<dynamic>> getMostPlayedShows({String period = 'weekly', int page = 1, int limit = 10}) {
    return _getJsonList('/shows/played/$period?extended=images&page=$page&limit=$limit');
  }

  /// Obtener los shows más vistos según periodo (daily, weekly, monthly, all)
  Future<List<dynamic>> getMostWatchedShows({String period = 'weekly', int page = 1, int limit = 10}) {
    return _getJsonList('/shows/watched/$period?extended=images&page=$page&limit=$limit');
  }

  /// Obtener los shows más coleccionados según periodo (daily, weekly, monthly, all)
  Future<List<dynamic>> getMostCollectedShows({String period = 'weekly', int page = 1, int limit = 10}) {
    return _getJsonList('/shows/collected/$period?extended=images&page=$page&limit=$limit');
  }

  /// Obtener los shows más anticipados
  Future<List<dynamic>> getMostAnticipatedShows({int page = 1, int limit = 10}) {
    return _getJsonList('/shows/anticipated?extended=images&page=$page&limit=$limit');
  }

  /// Obtener la información completa de un show por id, slug o imdb
  Future<Map<String, dynamic>> getShowById(String id) {
    return _getJsonMap('/shows/$id?extended=full');
  }



  /// Eliminar el token
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    _accessToken = null;
  }

  /// Construye la URL de autorización OAuth para Trakt.tv
  String getAuthorizationUrl({String state = 'login', Map<String, String>? extraParams}) {
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

  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'trakt-api-version': '2',
      'trakt-api-key': clientId ?? '',
    };
    if (_accessToken != null && _accessToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    return headers;
  }

  Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.get(url, headers: _headers);
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.post(url, headers: _headers, body: jsonEncode(body));
  }

  Future<http.Response> delete(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.delete(url, headers: _headers);
  }

  /// Intercambia el código de autorización por un access token
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
      if (data['access_token'] != null) {
        await saveToken(data['access_token']);
      }
      return data;
    } else {
      throw Exception('Error al obtener el token: \nStatus: \\${response.statusCode}\nBody: \\${response.body}');
    }
  }

  /// Refresca el access token usando un refresh_token
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
      if (data['access_token'] != null) {
        await saveToken(data['access_token']);
      }
      return data;
    } else {
      throw Exception('Error al refrescar el token: \nStatus: \\${response.statusCode}\nBody: \\${response.body}');
    }
  }

  /// Revoca el token de Trakt.tv
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
      throw Exception('Error al revocar el token: \nStatus: \\${response.statusCode}\nBody: \\${response.body}');
    }
  }
}

