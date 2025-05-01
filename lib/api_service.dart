import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

final apiService = ApiService();

extension SeasonsAndProgressApi on ApiService {
  /// Obtiene todas las temporadas de una serie (array de temporadas con número y count)
  Future<List<dynamic>> getSeasons(String showId) async {
    await _ensureValidToken();
    final url = Uri.parse('$baseUrl/shows/$showId/seasons');
    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Error GET /shows/$showId/seasons: \\n${response.statusCode}\\n${response.body}');
    }
  }

  /// Añade películas, series, temporadas o episodios al historial del usuario
  Future<void> addToWatchHistory({
    List<Map<String, dynamic>>? movies,
    List<Map<String, dynamic>>? shows,
    List<Map<String, dynamic>>? seasons,
    List<Map<String, dynamic>>? episodes,
  }) async {
    await _ensureValidToken();

    final Map<String, dynamic> payload = {};
    if (movies != null && movies.isNotEmpty) payload['movies'] = movies;
    if (shows != null && shows.isNotEmpty) payload['shows'] = shows;
    if (seasons != null && seasons.isNotEmpty) payload['seasons'] = seasons;
    if (episodes != null && episodes.isNotEmpty) payload['episodes'] = episodes;

    final url = Uri.parse('$baseUrl/sync/history');
    final response = await http.post(url, headers: _headers, body: jsonEncode(payload));

print(response.body);
    if (response.statusCode != 201) {
      throw Exception('Error POST /sync/history: ${response.statusCode}\n${response.body}');
    }
  }
}


class ApiService {
  /// Obtener la información de un episodio específico (extended=full, imágenes)
  Future<Map<String, dynamic>> getEpisodeInfo({
    required String id,
    required int season,
    required int episode,
  }) async {
    await _ensureValidToken();
    final url = Uri.parse(
      '$baseUrl/shows/$id/seasons/$season/episodes/$episode?extended=full,images',
    );
    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
        'Error GET /shows/$id/seasons/$season/episodes/$episode: ${response.statusCode}\n${response.body}',
      );
    }
  }

  /// Obtener el historial visto del usuario (shows o movies) con imágenes extendidas
  /// [type]: 'shows' o 'movies' (por defecto: 'shows')
  Future<List<dynamic>> getWatched({String type = 'shows'}) async {
    await _ensureValidToken();
    final allowedTypes = ['shows', 'movies'];
    final safeType = allowedTypes.contains(type) ? type : 'shows';
    final url = Uri.parse(
      '$baseUrl/sync/watched/$safeType?extended=images,noseasons',
    );
    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception(
        'Error GET /sync/watched/$safeType: \n${response.statusCode}\n${response.body}',
      );
    }
  }

  /// Obtener la watchlist del usuario (shows o movies) con imágenes extendidas
  /// [type]: 'shows' o 'movies' (por defecto: 'shows')
  Future<List<dynamic>> getWatchlist({String type = 'shows'}) async {
    await _ensureValidToken();
    final allowedTypes = ['shows', 'movies'];
    final safeType = allowedTypes.contains(type) ? type : 'shows';
    final url = Uri.parse(
      '$baseUrl/sync/watchlist/$safeType?extended=images&sort_by=rank&sort_how=asc',
    );
    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception(
        'Error GET /sync/watchlist/$safeType: \n${response.statusCode}\n${response.body}',
      );
    }
  }

  /// Busca películas y series usando el endpoint de búsqueda de Trakt.tv.
  /// Devuelve una lista de resultados (tipo 'movie' o 'show').
  Future<List<dynamic>> searchMoviesAndShows(
    String query, {
    List<String> types = const ['movie', 'show'],
  }) async {
    if (query.trim().isEmpty) return [];
    final safeQuery = Uri.encodeQueryComponent(query);
    final typeParam = types.join(',');
    return await _getJsonList(
      '/search/$typeParam?query=$safeQuery&extended=images',
    );
  }

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

  /// Guardar el token, refresh_token y expiración en SharedPreferences
  Future<void> saveTokenData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    if (data['access_token'] != null) {
      await prefs.setString(_tokenKey, data['access_token']);
      _accessToken = data['access_token'];
    }
    if (data['refresh_token'] != null) {
      await prefs.setString('refresh_token', data['refresh_token']);
    }
    if (data['expires_in'] != null) {
      // Guarda la expiración absoluta (segundos desde epoch)
      final expiresAt =
          DateTime.now().millisecondsSinceEpoch ~/ 1000 +
          (data['expires_in'] as int);
      await prefs.setInt('expires_at', expiresAt);
    }
  }

  /// --- MÉTODOS PRIVADOS DE UTILIDAD ---

  /// Obtener comentarios de un show, ordenados por el criterio indicado (por defecto: likes)
  Future<List<dynamic>> getShowComments(
    String id, {
    String sort = 'likes',
  }) async {
    return await _getJsonList('/shows/$id/comments/$sort');
  }

  /// Obtener certificaciones de un show
  Future<List<dynamic>> getShowCertifications(String id) async {
    try {
      return await _getJsonList('/shows/$id/certifications');
    } catch (e) {
      // Si la API falla (por ejemplo, error 500), devuelve lista vacía
      return [];
    }
  }

  /// Obtener reparto y equipo de un show (puede incluir guest_stars)
  Future<Map<String, dynamic>> getShowPeople(
    String id, {
    String extended = '',
  }) async {
    String endpoint = '/shows/$id/people?extended=images';
    if (extended.isNotEmpty) endpoint += ',$extended';
    return await _getJsonMap('/shows/$id/people?extended=images');
  }

  /// Obtener ratings de un show
  Future<Map<String, dynamic>> getShowRatings(String id) async {
    return await _getJsonMap('/shows/$id/ratings');
  }

  /// Obtener progreso visto de un show
  Future<Map<String, dynamic>> getShowWatchedProgress({
    required String id,
    String hidden = 'false',
    String specials = 'false',
    String countSpecials = 'true',
  }) async {
    await _ensureValidToken();
    final url = Uri.parse(
      '$baseUrl/shows/$id/progress/watched'
      '?hidden=$hidden&specials=$specials&count_specials=$countSpecials',
    );
    final response = await http.get(url, headers: _headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
        'Failed to load watched progress: ${response.statusCode}',
      );
    }
  }

  /// --- Manejo de expiración y refresco de token ---
  Future<void> _ensureValidToken() async {
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

  /// Realiza una petición GET y retorna una lista JSON
  Future<List<dynamic>> _getJsonList(String endpoint) async {
    await _ensureValidToken();
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.get(url, headers: _headersBase);
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception(
        'Error GET $endpoint: ${response.statusCode}\n${response.body}',
      );
    }
  }

  /// Realiza una petición GET y retorna un mapa JSON
  Future<Map<String, dynamic>> _getJsonMap(String endpoint) async {
    await _ensureValidToken();
    final url = Uri.parse('$baseUrl$endpoint');
    final response = await http.get(url, headers: _headersBase);
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
        'Error GET $endpoint: ${response.statusCode}\n${response.body}',
      );
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
    return _getJsonList(
      '/shows/trending?extended=images&page=$page&limit=$limit',
    );
  }

  /// Obtener los shows populares de Trakt.tv
  Future<List<dynamic>> getPopularShows({int page = 1, int limit = 10}) {
    return _getJsonList(
      '/shows/popular?extended=images&page=$page&limit=$limit',
    );
  }

  /// Obtener los shows más favoritos según periodo (daily, weekly, monthly, all)
  Future<List<dynamic>> getMostFavoritedShows({
    String period = 'weekly',
    int page = 1,
    int limit = 10,
  }) {
    return _getJsonList(
      '/shows/favorited/$period?extended=images&page=$page&limit=$limit',
    );
  }

  /// Obtener los shows más reproducidos según periodo (daily, weekly, monthly, all)
  Future<List<dynamic>> getMostPlayedShows({
    String period = 'weekly',
    int page = 1,
    int limit = 10,
  }) {
    return _getJsonList(
      '/shows/played/$period?extended=images&page=$page&limit=$limit',
    );
  }

  /// Obtener los shows más vistos según periodo (daily, weekly, monthly, all)
  Future<List<dynamic>> getMostWatchedShows({
    String period = 'weekly',
    int page = 1,
    int limit = 10,
  }) {
    return _getJsonList(
      '/shows/watched/$period?extended=images&page=$page&limit=$limit',
    );
  }

  /// Obtener los shows más coleccionados según periodo (daily, weekly, monthly, all)
  Future<List<dynamic>> getMostCollectedShows({
    String period = 'weekly',
    int page = 1,
    int limit = 10,
  }) {
    return _getJsonList(
      '/shows/collected/$period?extended=images&page=$page&limit=$limit',
    );
  }

  /// Obtener los shows más anticipados
  Future<List<dynamic>> getMostAnticipatedShows({
    int page = 1,
    int limit = 10,
  }) {
    return _getJsonList(
      '/shows/anticipated?extended=images&page=$page&limit=$limit',
    );
  }

  /// Obtener las traducciones de un show para un idioma específico (devuelve lista de traducciones)
  Future<List<dynamic>> getShowTranslations(String id, String language) async {
    return await _getJsonList('/shows/$id/translations/$language');
  }

  /// Obtener los aliases (títulos por país) de un show por id, slug o imdb
  Future<List<dynamic>> getShowAliases(String id) async {
    return await _getJsonList('/shows/$id/aliases');
  }

  /// Obtener la información completa de un show por id, slug o imdb
  Future<Map<String, dynamic>> getShowById(String id) {
    return _getJsonMap('/shows/$id?extended=full,images,');
  }

  /// Eliminar el token
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    _accessToken = null;
  }

  /// Construye la URL de autorización OAuth para Trakt.tv
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
      await saveTokenData(data);
      return data;
    } else {
      throw Exception(
        'Error al obtener el token: \nStatus: \\${response.statusCode}\nBody: \\${response.body}',
      );
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
      await saveTokenData(data);
      return data;
    } else {
      throw Exception(
        'Error al refrescar el token: \nStatus: \\${response.statusCode}\nBody: \\${response.body}',
      );
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
      throw Exception(
        'Error al revocar el token: \nStatus: \\${response.statusCode}\nBody: \\${response.body}',
      );
    }
  }

  /// Obtener shows relacionados por id, slug o imdb, incluyendo imágenes
  Future<List<dynamic>> getRelatedShows(String id) async {
    // "extended=images" para obtener imágenes
    return await _getJsonList(
      '/shows/\u0000{id}/related?extended=images'.replaceFirst(
        '\u0000{id}',
        id,
      ),
    );
  }

  /// Obtener videos de un show (trailers, clips, etc)
  Future<List<dynamic>> getShowVideos(String id) async {
    // /shows/{id}/videos
    return await _getJsonList(
      '/shows/\u0000{id}/videos'.replaceFirst('\u0000{id}', id),
    );
  }
}
