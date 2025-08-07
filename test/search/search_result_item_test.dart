import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watching/search/search_result_item.dart';

void main() {
  group('SearchResultItem', () {
    test('should create a valid SearchResultItem', () {
      // Arrange
      final data = {
        'title': 'Test Show',
        'images': {
          'poster': ['https://example.com/poster.jpg']
        },
      };

      // Act
      final result = SearchResultItem(
        data: data,
        type: 'show',
      );

      // Assert
      expect(result.data, equals(data));
      expect(result.type, equals('show'));
    });
  });

  group('SearchResultGridTile', () {
    testWidgets('should display show title', (tester) async {
      // Arrange
      final item = SearchResultItem(
        data: {
          'title': 'Test Show',
          'images': {'poster': ['https://example.com/poster.jpg']}
        },
        type: 'show',
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchResultGridTile(item: item, onTap: () {}),
          ),
        ),
      );

      // Assert
      expect(find.text('Test Show'), findsOneWidget);
    });

    testWidgets('should handle tap events', (tester) async {
      // Arrange
      var tapped = false;
      final item = SearchResultItem(
        data: {
          'title': 'Test Show',
          'images': {'poster': ['https://example.com/poster.jpg']}
        },
        type: 'show',
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchResultGridTile(
              item: item,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GestureDetector).first);
      await tester.pump();

      // Assert
      expect(tapped, isTrue);
    });

    testWidgets('should handle missing poster URL', (tester) async {
      // Test the getPosterUrl method directly
      final widget = const SearchResultGridTile(
        item: SearchResultItem(
          data: {'title': 'Test'},
          type: 'show',
        ),
      );

      // Test with null
      expect(widget.getPosterUrl(null), isNull);

      // Test with empty list
      expect(widget.getPosterUrl([]), isNull);

      // Test with invalid URL (no http)
      expect(widget.getPosterUrl(['example.com/image.jpg']), 'https://example.com/image.jpg');

      // Test with valid URL (http)
      expect(
        widget.getPosterUrl(['http://example.com/image.jpg']),
        'http://example.com/image.jpg',
      );

      // Test with valid URL (https)
      expect(
        widget.getPosterUrl(['https://example.com/image.jpg']),
        'https://example.com/image.jpg',
      );
    });

    testWidgets('should handle missing title', (tester) async {
      // Arrange
      final item = SearchResultItem(
        data: {
          'images': {'poster': ['https://example.com/poster.jpg']}
        },
        type: 'show',
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchResultGridTile(item: item, onTap: () {}),
          ),
        ),
      );

      // Assert
      expect(find.text(''), findsOneWidget);
    });

    testWidgets('should handle null onTap', (tester) async {
      // Arrange
      final item = SearchResultItem(
        data: {
          'title': 'Test Show',
          'images': {'poster': ['https://example.com/poster.jpg']}
        },
        type: 'show',
      );

      // Act & Assert (should not throw)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchResultGridTile(item: item),
          ),
        ),
      );

      await tester.tap(find.byType(GestureDetector).first);
      await tester.pump();
    });
  });

  group('getPosterUrl', () {
    test('should return null for empty poster list', () {
      // Arrange
      final widget = const SearchResultGridTile(
        item: SearchResultItem(
          data: {},
          type: 'show',
        ),
      );

      // Act
      final result = widget.getPosterUrl(null);

      // Assert
      expect(result, isNull);
    });

    test('should format URL without http prefix', () {
      // Arrange
      final widget = const SearchResultGridTile(
        item: SearchResultItem(
          data: {},
          type: 'show',
        ),
      );

      // Act
      final result = widget.getPosterUrl(['example.com/poster.jpg']);

      // Assert
      expect(result, 'https://example.com/poster.jpg');
    });

    test('should keep URL with http prefix', () {
      // Arrange
      final widget = const SearchResultGridTile(
        item: SearchResultItem(
          data: {},
          type: 'show',
        ),
      );

      // Act
      final result = widget.getPosterUrl(['https://example.com/poster.jpg']);

      // Assert
      expect(result, 'https://example.com/poster.jpg');
    });
  });
}
