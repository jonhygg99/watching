import 'dart:convert';
import 'package:http/http.dart' as http;
import 'trakt_api.dart';

/// Mixin for calendar-related endpoints.
mixin CalendarApi on TraktApiBase {
  /// Gets upcoming episodes for shows in the user's watchlist.
  /// Handles pagination for periods longer than 30 days.
  ///
  /// [startDate]: The start date in YYYY-MM-DD format (e.g., '2025-08-10')
  /// [days]: Number of days to include in the calendar (can be more than 30)
  /// Returns a map containing the combined data and response headers
  Future<Map<String, dynamic>> getMyShowsCalendar({
    required String startDate,
    required int days,
  }) async {
    await ensureValidToken();
    
    final allData = <dynamic>[];
    DateTime currentStart = DateTime.parse(startDate);
    int remainingDays = days;
    String? firstStartDate;
    String? lastEndDate;

    while (remainingDays > 0) {
      final batchDays = remainingDays > 30 ? 30 : remainingDays;
      final batchEndDate = currentStart.add(Duration(days: batchDays - 1));
      
      final batchStartStr = '${currentStart.year}-${currentStart.month.toString().padLeft(2, '0')}-${currentStart.day.toString().padLeft(2, '0')}';
      
      final url = Uri.parse(
        '$baseUrl/calendars/my/shows/$batchStartStr/$batchDays?extended=images',
      );

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        allData.addAll(data);
        
        // Track the first start date and last end date
        firstStartDate ??= response.headers['x-start-date'];
        lastEndDate = response.headers['x-end-date'];
        
        // Move to the next batch
        currentStart = batchEndDate.add(const Duration(days: 1));
        remainingDays = days - (currentStart.difference(DateTime.parse(startDate)).inDays);
      } else {
        throw Exception(
          'Error GET /calendars/my/shows/$batchStartStr/$batchDays:\n'
          '${response.statusCode}\n${response.body}',
        );
      }
    }

    return {
      'data': allData,
      'startDate': firstStartDate,
      'endDate': lastEndDate,
    };
  }

  /// Gets season premieres for shows in the user's watchlist.
  /// Handles pagination for periods longer than 30 days.
  ///
  /// [startDate]: The start date in YYYY-MM-DD format (e.g., '2025-08-10')
  /// [days]: Number of days to include in the calendar (can be more than 30)
  /// Returns a map containing the combined data and response headers
  Future<Map<String, dynamic>> getMyShowsPremieres({
    required String startDate,
    required int days,
  }) async {
    await ensureValidToken();
    
    final allData = <dynamic>[];
    DateTime currentStart = DateTime.parse(startDate);
    int remainingDays = days;
    String? firstStartDate;
    String? lastEndDate;

    while (remainingDays > 0) {
      final batchDays = remainingDays > 30 ? 30 : remainingDays;
      final batchEndDate = currentStart.add(Duration(days: batchDays - 1));
      
      final batchStartStr = '${currentStart.year}-${currentStart.month.toString().padLeft(2, '0')}-${currentStart.day.toString().padLeft(2, '0')}';
      
      final url = Uri.parse(
        '$baseUrl/calendars/my/shows/premieres/$batchStartStr/$batchDays?extended=season_premiere',
      );

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        allData.addAll(data);
        
        // Track the first start date and last end date
        firstStartDate ??= response.headers['x-start-date'];
        lastEndDate = response.headers['x-end-date'];
        
        // Move to the next batch
        currentStart = batchEndDate.add(const Duration(days: 1));
        remainingDays = days - (currentStart.difference(DateTime.parse(startDate)).inDays);
      } else {
        throw Exception(
          'Error GET /calendars/my/shows/premieres/$batchStartStr/$batchDays:\n'
          '${response.statusCode}\n${response.body}',
        );
      }
    }

    return {
      'data': allData,
      'startDate': firstStartDate,
      'endDate': lastEndDate,
    };
  }

  /// Gets new show premieres (series_premiere) airing during the specified time period.
  /// Handles pagination for periods longer than 30 days.
  ///
  /// [startDate]: The start date in YYYY-MM-DD format (e.g., '2025-08-10')
  /// [days]: Number of days to include in the calendar (can be more than 30)
  /// Returns a map containing the combined data and response headers
  Future<Map<String, dynamic>> getMyNewShows({
    required String startDate,
    required int days,
  }) async {
    await ensureValidToken();
    
    final allData = <dynamic>[];
    DateTime currentStart = DateTime.parse(startDate);
    int remainingDays = days;
    String? firstStartDate;
    String? lastEndDate;

    while (remainingDays > 0) {
      final batchDays = remainingDays > 30 ? 30 : remainingDays;
      final batchEndDate = currentStart.add(Duration(days: batchDays - 1));
      
      final batchStartStr = '${currentStart.year}-${currentStart.month.toString().padLeft(2, '0')}-${currentStart.day.toString().padLeft(2, '0')}';
      
      final url = Uri.parse(
        '$baseUrl/calendars/my/shows/new/$batchStartStr/$batchDays?extended=images',
      );

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        allData.addAll(data);
        
        // Track the first start date and last end date
        firstStartDate ??= response.headers['x-start-date'];
        lastEndDate = response.headers['x-end-date'];
        
        // Move to the next batch
        currentStart = batchEndDate.add(const Duration(days: 1));
        remainingDays = days - (currentStart.difference(DateTime.parse(startDate)).inDays);
      } else {
        throw Exception(
          'Error GET /calendars/my/shows/new/$batchStartStr/$batchDays:\n'
          '${response.statusCode}\n${response.body}',
        );
      }
    }

    return {
      'data': allData,
      'startDate': firstStartDate,
      'endDate': lastEndDate,
    };
  }
}
