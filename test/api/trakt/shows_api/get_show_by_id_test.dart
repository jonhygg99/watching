import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'mocks/test_shows_api.dart';
import 'mocks/mock_get_show_by_id.dart';
import 'mocks/mock_trakt_api_base.dart';

void main() {
  late TestShowsApi showsApi;
  late MockTraktApiBase mockTraktApiBase;

  setUp(() {
    mockTraktApiBase = MockTraktApiBase();
    showsApi = TestShowsApi(mockTraktApiBase);
  });

  group('getShowById', () {
    test('should return show details when called with valid ID', () async {
      // Arrange
      final mockResponse = getMockShowResponse();
      when(
        mockTraktApiBase.getJsonMap('/shows/game-of-thrones'),
      ).thenAnswer((_) async => mockResponse);

      // Act
      final result = await showsApi.getShowById(id: 'game-of-thrones');

      // Assert
      expect(result, isA<Map<String, dynamic>>());
      expect(result['title'], 'Game of Thrones');
      expect(result['year'], 2011);
      verify(mockTraktApiBase.getJsonMap('/shows/game-of-thrones')).called(1);
    });

    test('should return extended show details when extended is true', () async {
      // Arrange
      final mockResponse = getMockExtendedShowResponse();
      when(
        mockTraktApiBase.getJsonMap(
          '/shows/game-of-thrones?extended=full,images',
        ),
      ).thenAnswer((_) async => mockResponse);

      // Act
      final result = await showsApi.getShowById(
        id: 'game-of-thrones',
        extended: true,
      );

      // Assert
      expect(result, isA<Map<String, dynamic>>());
      expect(result['title'], 'Game of Thrones');
      expect(result['tagline'], 'Winter Is Coming');
      expect(result['overview'], isNotNull);
      expect(result['status'], 'returning series');
      expect(result['rating'], 9);
      expect(result['available_translations'], isNotNull);
      expect(result['aired_episodes'], 50);
      verify(
        mockTraktApiBase.getJsonMap(
          '/shows/game-of-thrones?extended=full,images',
        ),
      ).called(1);
    });
  });
}
