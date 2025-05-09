import 'dart:convert';
import 'package:http/http.dart' as http;
import 'trakt_api.dart';

/// Mixin for user-related endpoints.
mixin UserApi on TraktApiBase {
  /// Gets the current user's profile.
  Future<Map<String, dynamic>> getCurrentUserProfile() async {
    await ensureValidToken();
    final url = Uri.parse('$baseUrl/users/me?extended=full');
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
        'Error GET /users/me: ${response.statusCode}\n${response.body}',
      );
    }
  }
}
