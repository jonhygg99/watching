import 'dart:convert';
import 'package:http/http.dart' as http;
import 'trakt_api.dart';

/// Mixin for calendar-related endpoints.
mixin CalendarApi on TraktApiBase {
  Future<Map<String, dynamic>> _fetchBatch({
    required String endpoint,
    required String startDate,
    required int days,
    Map<String, String>? queryParams,
  }) async {
    final params = queryParams ?? {};
    params['extended'] = 'images';
    
    // Extract language for translations if provided
    final language = params['translations'];
    final bool shouldTranslate = language != null && language != 'all';
    
    // Remove translations from params to avoid API errors
    final requestParams = Map<String, String>.from(params)..remove('translations');

    final url = Uri.parse(
      '$baseUrl/$endpoint/$startDate/$days',
    ).replace(queryParameters: requestParams);

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body) as List<dynamic>;
      
      // Process translations if needed
      if (shouldTranslate) {
        data = data.map((item) {
          if (item is Map<String, dynamic> && 
              item.containsKey('episode') && 
              item['episode'] is Map<String, dynamic> &&
              item['episode'].containsKey('translations') &&
              item['episode']['translations'] is List) {
            
            final translations = List<Map<String, dynamic>>.from(
              item['episode']['translations'],
            );
            
            if (translations.isNotEmpty) {
              // Find the translation for the requested language
              final translation = translations.firstWhere(
                (t) => t['language'] == language,
                orElse: () => {},
              );
              
              // Create a new episode map with translated fields if available
              if (translation.isNotEmpty) {
                return {
                  ...item,
                  'episode': {
                    ...item['episode'],
                    'title': translation['title'] ?? item['episode']['title'],
                    'overview': translation['overview'] ?? item['episode']['overview'],
                  },
                };
              }
            }
          }
          return item;
        }).toList();
      }
      
      return {
        'data': data,
        'startDate': response.headers['x-start-date'],
        'endDate': response.headers['x-end-date'],
      };
    } else {
      throw Exception(
        'Error GET $url\n${response.statusCode}\n${response.body}',
      );
    }
  }

  Future<Map<String, dynamic>> _fetchInBatches({
    required String endpoint,
    required String startDate,
    required int days,
    Map<String, String>? queryParams,
    int maxConcurrent = 3,
  }) async {
    final allData = <dynamic>[];
    final startDateTime = DateTime.parse(startDate);
    final batches = <Map<String, dynamic>>[];

    // Create batches of 30 days each
    for (var i = 0; i < days; i += 30) {
      final batchStart = startDateTime.add(Duration(days: i));
      final batchDays = (i + 30 > days) ? days - i : 30;

      batches.add({
        'start': batchStart,
        'days': batchDays,
        'startStr':
            '${batchStart.year}-${batchStart.month.toString().padLeft(2, '0')}-${batchStart.day.toString().padLeft(2, '0')}',
      });
    }

    // Process batches in parallel with limited concurrency
    final results = await Future.wait(
      batches.map(
        (batch) => _fetchBatch(
          endpoint: endpoint,
          startDate: batch['startStr'] as String,
          days: batch['days'] as int,
          queryParams: queryParams,
        ),
      ),
      eagerError: true,
    );

    // Combine results
    for (final result in results) {
      allData.addAll(result['data'] as List<dynamic>);
    }

    return {
      'data': allData,
      'startDate': results.isNotEmpty ? results.first['startDate'] : null,
      'endDate': results.isNotEmpty ? results.last['endDate'] : null,
    };
  }

  /// Gets upcoming episodes for shows in the user's watchlist.
  /// Handles pagination for periods longer than 30 days.
  ///
  /// [startDate]: The start date in YYYY-MM-DD format (e.g., '2025-08-10')
  /// [days]: Number of days to include in the calendar (can be more than 30)
  /// Returns a map containing the combined data and response headers
  Future<Map<String, dynamic>> getMyShowsCalendar({
    required String startDate,
    required int days,
    String? language,
    int maxConcurrent = 3,
  }) async {
    await ensureValidToken();
    
    final queryParams = <String, String>{};
    if (language != null) {
      queryParams['translations'] = language;
    }
    
    return _fetchInBatches(
      startDate: startDate,
      days: days,
      endpoint: 'calendars/my/shows',
      queryParams: queryParams,
      maxConcurrent: maxConcurrent,
    );
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
    int maxConcurrent = 3,
  }) async {
    await ensureValidToken();
    return _fetchInBatches(
      startDate: startDate,
      days: days,
      endpoint: 'calendars/my/shows/premieres',
      queryParams: {
        'extended': 'mid_season_premiere,season_premiere,series_premiere',
      },
      maxConcurrent: maxConcurrent,
    );
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
    int maxConcurrent = 3,
  }) async {
    await ensureValidToken();
    return _fetchInBatches(
      startDate: startDate,
      days: days,
      endpoint: 'calendars/my/shows/new',
      queryParams: {'extended': 'series_premiere'},
      maxConcurrent: maxConcurrent,
    );
  }

  /// Gets show finales (mid_season_finale, season_finale, series_finale) airing during the specified time period.
  /// Handles pagination for periods longer than 30 days.
  ///
  /// [startDate]: The start date in YYYY-MM-DD format (e.g., '2025-08-10')
  /// [days]: Number of days to include in the calendar (can be more than 30)
  /// Returns a map containing the combined data and response headers
  Future<Map<String, dynamic>> getMyShowsFinales({
    required String startDate,
    required int days,
    int maxConcurrent = 3,
  }) async {
    await ensureValidToken();
    return _fetchInBatches(
      startDate: startDate,
      days: days,
      endpoint: 'calendars/my/shows/finales',
      queryParams: {
        'extended': 'mid_season_finale,season_finale,series_finale',
      },
      maxConcurrent: maxConcurrent,
    );
  }
}
