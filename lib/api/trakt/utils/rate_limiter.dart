import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

/// A utility class to enforce rate limiting on API requests.
///
/// This helps prevent hitting rate limits by ensuring that no more than
/// [maxRequests] are made within the [timeWindow] duration.
class RateLimiter {
  final int maxRequests;
  final Duration timeWindow;
  final List<DateTime> _requestTimestamps = [];
  final _logger = Logger('RateLimiter');

  /// Creates a new RateLimiter.
  ///
  /// [maxRequests] is the maximum number of requests allowed in [timeWindow].
  /// [timeWindow] is the duration in which [maxRequests] can be made.
  RateLimiter({this.maxRequests = 2, this.timeWindow = const Duration(seconds: 1)});

  /// Waits if needed to respect the rate limit.
  ///
  /// This should be called before making each request.
  Future<void> waitIfNeeded() async {
    final now = DateTime.now();
    _requestTimestamps.removeWhere((timestamp) => now.difference(timestamp) > timeWindow);

    if (_requestTimestamps.length >= maxRequests) {
      final timeToWait = timeWindow - now.difference(_requestTimestamps.first);
      _logger.fine('Rate limit reached. Waiting for ${timeToWait.inMilliseconds}ms');
      await Future.delayed(timeToWait);
      _requestTimestamps.removeAt(0);
    }

    _requestTimestamps.add(DateTime.now());
  }
}

/// A rate-limited HTTP client that wraps the standard http.Client.
///
/// This client enforces rate limiting and provides automatic retry with
/// exponential backoff for failed requests.
class RateLimitedHttpClient {
  final RateLimiter _rateLimiter = RateLimiter();
  final _client = http.Client();
  final _logger = Logger('RateLimitedHttpClient');

  /// Sends an HTTP POST request with rate limiting and automatic retry.
  ///
  /// This method will automatically handle rate limiting (429) responses and
  /// retry failed requests with exponential backoff.
  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    int maxRetries = 3,
  }) async {
    int attempt = 0;
    while (true) {
      try {
        await _rateLimiter.waitIfNeeded();
        final response = await _client.post(
          url,
          headers: headers,
          body: body,
          encoding: encoding,
        );

        if (response.statusCode == 429) {
          // Handle rate limiting
          final retryAfter = int.tryParse(response.headers['retry-after'] ?? '1') ?? 1;
          _logger.warning('Rate limited. Retrying after $retryAfter seconds');
          await Future.delayed(Duration(seconds: retryAfter));
          continue;
        }

        return response;
      } catch (e) {
        if (attempt >= maxRetries) rethrow;
        
        // Exponential backoff with jitter
        final delayMs = pow(2, attempt) * 1000 + Random().nextInt(1000);
        _logger.warning(
          'Request failed (attempt ${attempt + 1}/$maxRetries): $e. '
          'Retrying in ${delayMs}ms',
        );
        await Future.delayed(Duration(milliseconds: delayMs.toInt()));
        attempt++;
      }
    }
  }

  /// Closes the underlying HTTP client and releases any resources.
  void close() {
    _client.close();
  }
}
