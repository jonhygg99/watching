import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'mocks/test_shows_api.dart';
import 'mocks/mock_get_show_comments.dart';
import 'mocks/mock_trakt_api_base.dart';

void main() {
  late TestShowsApi showsApi;
  late MockTraktApiBase mockTraktApiBase;

  setUp(() {
    mockTraktApiBase = MockTraktApiBase();
    showsApi = TestShowsApi(mockTraktApiBase);
  });

  group('getShowComments', () {
    test('should return show comments when called with valid ID', () async {
      // Arrange
      final mockComments = getMockShowComments();

      when(
        mockTraktApiBase.getJsonList('/shows/game-of-thrones/comments/newest'),
      ).thenAnswer((_) async => mockComments);

      // Act
      final result = await showsApi.getShowComments(id: 'game-of-thrones');

      // Assert
      expect(result, isA<List<dynamic>>());
      expect(result.length, 5);

      // Verify first comment
      expect(result[0]['comment'], contains('amazing'));
      expect(result[0]['user']['username'], 'tvfan123');
      expect(result[0]['likes'], 24);

      // Verify a reply comment
      expect(result[2]['parent_id'], 12345);
      expect(result[2]['replies'], 0);

      // Verify a review
      final review = result.firstWhere(
        (c) => c['review'] == true,
        orElse: () => <String, dynamic>{},
      );
      expect(review.isNotEmpty, true);
      expect(review['user_rating'], 9.5);

      verify(
        mockTraktApiBase.getJsonList('/shows/game-of-thrones/comments/newest'),
      ).called(1);
    });

    test('should use custom sort parameter', () async {
      // Arrange
      final mockComments = getMockShowComments().sublist(0, 2);

      when(
        mockTraktApiBase.getJsonList('/shows/game-of-thrones/comments/likes'),
      ).thenAnswer((_) async => mockComments);

      // Act
      final result = await showsApi.getShowComments(
        id: 'game-of-thrones',
        sort: 'likes',
      );

      // Assert
      expect(result, isA<List<dynamic>>());
      expect(result.length, 2);

      verify(
        mockTraktApiBase.getJsonList('/shows/game-of-thrones/comments/likes'),
      ).called(1);
    });

    test('should handle empty comments response', () async {
      // Arrange
      when(
        mockTraktApiBase.getJsonList('/shows/game-of-thrones/comments/newest'),
      ).thenAnswer((_) async => []);

      // Act
      final result = await showsApi.getShowComments(id: 'game-of-thrones');

      // Assert
      expect(result, isA<List<dynamic>>());
      expect(result.isEmpty, true);

      verify(
        mockTraktApiBase.getJsonList('/shows/game-of-thrones/comments/newest'),
      ).called(1);
    });

    test('should throw an exception when API call fails', () async {
      // Arrange
      when(
        mockTraktApiBase.getJsonList('/shows/game-of-thrones/comments/newest'),
      ).thenThrow(Exception('API Error'));

      // Act & Assert
      await expectLater(
        () => showsApi.getShowComments(id: 'game-of-thrones'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
