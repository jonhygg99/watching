import 'dart:convert';
import 'package:http/http.dart' as http;
import 'trakt_api.dart';

/// Mixin for calendar-related endpoints.
mixin CalendarApi on TraktApiBase {
  /// Gets upcoming episodes for shows in the user's watchlist.
  ///
  /// [startDate]: The start date in YYYY-MM-DD format (e.g., '2025-08-10')
  /// [days]: Number of days to include in the calendar (1-31)
  Future<List<dynamic>> getMyShowsCalendar({
    required String startDate,
    required int days,
  }) async {
    await ensureValidToken();
    
    final url = Uri.parse(
      '$baseUrl/calendars/my/shows/$startDate/$days?extended=images',
    );
    
    final response = await http.get(url, headers: headers);
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception(
        'Error GET /calendars/my/shows/$startDate/$days:\n'
        '${response.statusCode}\n${response.body}',
      );
    }
  }
}
