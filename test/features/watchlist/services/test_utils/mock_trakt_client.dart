import 'dart:async';

/// Mock TraktClient interface for testing
class MockTraktClient {
  Future<Map<String, dynamic>> getEpisodeInfo({
    required String? id,
    required int? season,
    required int? episode,
    String? language,
  }) async {
    return {};
  }
}
