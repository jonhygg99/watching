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
      // Test with a widget that has no images
      final widget = SearchResultGridTile(
        item: const SearchResultItem(
          data: {'title': 'Test'},
          type: 'show',
        ),
      );

      // Test with null images
      expect(widget.getFirstAvailableImage(null), isNull);
      
      // Test with empty images object
      expect(widget.getFirstAvailableImage({}), isNull);
      
      // Test with empty image lists
      expect(
        widget.getFirstAvailableImage({
          'poster': [],
          'thumb': []
        }), 
        isNull
      );
      
      // Test with a valid image URL (no http)
      final result = widget.getFirstAvailableImage({
        'poster': ['example.com/image.jpg']
      });
      expect(result, 'https://example.com/image.jpg');
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

  group('getFirstAvailableImage', () {
    test('should return null for null images', () {
      // Arrange
      final widget = SearchResultGridTile(
        item: const SearchResultItem(
          data: {},
          type: 'show',
        ),
      );

      // Act
      final result = widget.getFirstAvailableImage(null);

      // Assert
      expect(result, isNull);
    });

    test('should return first available image URL', () {
      // Arrange
      final widget = SearchResultGridTile(
        item: const SearchResultItem(
          data: {},
          type: 'show',
        ),
      );

      final images = {
        'fanart': ['example.com/fanart.jpg'],
        'poster': ['example.com/poster.jpg'],
        'thumb': ['example.com/thumb.jpg'],
      };

      // Act
      final result = widget.getFirstAvailableImage(images);

      // Assert - should return poster first (as per priority)
      expect(result, 'https://example.com/poster.jpg');
    });

    test('should fall back to next available image type', () {
      // Arrange
      final widget = SearchResultGridTile(
        item: const SearchResultItem(
          data: {},
          type: 'show',
        ),
      );

      final images = {
        'fanart': ['example.com/fanart.jpg'],
        'thumb': ['example.com/thumb.jpg'],
      };

      // Act
      final result = widget.getFirstAvailableImage(images);

      // Assert - should return thumb (next in priority after poster)
      expect(result, 'https://example.com/thumb.jpg');
    });

    test('should handle empty image lists', () {
      // Arrange
      final widget = SearchResultGridTile(
        item: const SearchResultItem(
          data: {},
          type: 'show',
        ),
      );

      final images = {
        'poster': [],
        'thumb': [],
      };

      // Act
      final result = widget.getFirstAvailableImage(images);

      // Assert
      expect(result, isNull);
    });
  });
}
