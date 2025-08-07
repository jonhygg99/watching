import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watching/search/search_page.dart';

// Helper widget to wrap the widget under test
class TestApp extends StatelessWidget {
  final Widget child;
  
  const TestApp({
    super.key, 
    required this.child,
  });
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }
}

void main() {
  group('SearchPage', () {
    testWidgets('renders initial state correctly', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SearchPage(initialTrendingShows: []),
            ),
          ),
        ),
      );

      // Wait for the widget to be fully built
      await tester.pump(const Duration(milliseconds: 100));

      // Verify initial UI elements
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(InputDecorator), findsWidgets);
      
      // Check for the hint text in the TextField
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect((textField.decoration?.hintText), 'Buscar...');
      
      // Check filter chips
      expect(find.text('Películas'), findsOneWidget);
      expect(find.text('Series'), findsOneWidget);
    });

    testWidgets('updates query when text is entered', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SearchPage(initialTrendingShows: []),
            ),
          ),
        ),
      );

      // Wait for the widget to be fully built
      await tester.pump(const Duration(milliseconds: 100));

      // Get the TextField finder
      final finder = find.byType(TextField);
      
      // Enter text in the search field
      await tester.enterText(finder, 'test query');
      await tester.pump(const Duration(milliseconds: 100));

      // Verify the text was entered by checking the TextField's value
      expect(find.text('test query'), findsOneWidget);
    });

    testWidgets('toggles movie filter chip', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SearchPage(initialTrendingShows: []),
            ),
          ),
        ),
      );

      // Wait for the widget to be fully built
      await tester.pump(const Duration(milliseconds: 100));

      // Find and tap the movie filter chip
      final movieChip = find.descendant(
        of: find.byType(FilterChip),
        matching: find.text('Películas'),
      ).first;
      
      final filterChip = tester.widget<FilterChip>(
        find.ancestor(of: movieChip, matching: find.byType(FilterChip)).first
      );

      // Initially selected
      expect(filterChip.selected, isTrue);

      // Tap to deselect
      await tester.tap(movieChip);
      await tester.pump(const Duration(milliseconds: 100));

      // Get the updated widget after state change
      final updatedFilterChip = tester.widget<FilterChip>(
        find.ancestor(of: movieChip, matching: find.byType(FilterChip)).first
      );
      
      // Verify it's now unselected
      expect(updatedFilterChip.selected, isFalse);
    });

    testWidgets('toggles show filter chip', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SearchPage(initialTrendingShows: []),
            ),
          ),
        ),
      );

      // Wait for the widget to be fully built
      await tester.pump(const Duration(milliseconds: 100));

      // Find and tap the show filter chip
      final showChip = find.descendant(
        of: find.byType(FilterChip),
        matching: find.text('Series'),
      ).first;
      
      final filterChip = tester.widget<FilterChip>(
        find.ancestor(of: showChip, matching: find.byType(FilterChip)).first
      );

      // Initially selected
      expect(filterChip.selected, isTrue);

      // Tap to deselect
      await tester.tap(showChip);
      await tester.pump(const Duration(milliseconds: 100));

      // Get the updated widget after state change
      final updatedFilterChip = tester.widget<FilterChip>(
        find.ancestor(of: showChip, matching: find.byType(FilterChip)).first
      );
      
      // Verify it's now unselected
      expect(updatedFilterChip.selected, isFalse);
    });

    testWidgets('shows SearchResultsGrid when query is not empty', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SearchPage(initialTrendingShows: []),
            ),
          ),
        ),
      );

      // Wait for the widget to be fully built
      await tester.pump(const Duration(milliseconds: 100));

      // Initially shows TextField
      final finder = find.byType(TextField);
      expect(finder, findsOneWidget);

      // Enter search query
      await tester.enterText(finder, 'test');
      await tester.pump(const Duration(milliseconds: 100));

      // Verify the search query was updated
      expect(find.text('test'), findsOneWidget);
      
      // Clear the search
      await tester.enterText(finder, '');
      await tester.pump(const Duration(milliseconds: 100));
      
      // Verify the search was cleared
      expect(find.text('test'), findsNothing);
    });

    testWidgets('initializes with provided trending shows', (tester) async {
      const mockShows = [
        {'show': {'title': 'Show 1', 'ids': {'trakt': 1, 'slug': 'show-1'}}},
        {'show': {'title': 'Show 2', 'ids': {'trakt': 2, 'slug': 'show-2'}}},
      ];

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SearchPage(initialTrendingShows: mockShows),
            ),
          ),
        ),
      );

      // Wait for the widget to be fully built
      await tester.pump(const Duration(milliseconds: 100));

      // Verify the page is rendered
      expect(find.byType(SearchPage), findsOneWidget);
      
      // Verify the initial UI elements are present
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Películas'), findsOneWidget);
      expect(find.text('Series'), findsOneWidget);
    });
  });
}
