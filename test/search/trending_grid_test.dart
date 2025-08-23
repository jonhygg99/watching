import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:watching/api/trakt/trakt_api.dart';
import 'package:watching/api/trakt/show_translation.dart';
import 'package:watching/providers/app_providers.dart';
import 'package:watching/pages/search/widgets/trending_grid.dart';
import 'package:watching/pages/search/widgets/search_result_item.dart';

// Mock implementations
class MockTraktApi extends Mock implements TraktApi {
  @override
  Future<List<dynamic>> getTrendingShows({int page = 1, int limit = 10}) =>
      super.noSuchMethod(
        Invocation.method(#getTrendingShows, [], {#page: page, #limit: limit}),
        returnValue: Future.value([]),
        returnValueForMissingStub: Future.value([]),
      );
}

class MockShowTranslationService extends Mock
    implements ShowTranslationService {
  @override
  Future<String> getTranslatedTitle({
    required dynamic show,
    required dynamic traktApi,
  }) {
    return super.noSuchMethod(
          Invocation.method(#getTranslatedTitle, [], {
            #show: show,
            #traktApi: traktApi,
          }),
          returnValue: Future.value('Translated Title'),
          returnValueForMissingStub: Future.value('Translated Title'),
        )
        as Future<String>;
  }
}

// Track translation service calls
class TranslationCallTracker {
  final List<String> translatedTitles = [];
  int callCount = 0;

  void trackCall(dynamic show) {
    callCount++;
    final title = show['title']?.toString() ?? 'Untitled';
    translatedTitles.add('Translated $title');
  }
}

void main() {
  late MockTraktApi mockTraktApi;
  late MockShowTranslationService mockTranslationService;
  late TranslationCallTracker translationTracker;

  final testShows = [
    {
      'show': {
        'title': 'Test Show 1',
        'ids': {'trakt': 1, 'slug': 'test-show-1'},
        'year': 2023,
      },
    },
    {
      'show': {
        'title': 'Test Show 2',
        'ids': {'trakt': 2, 'slug': 'test-show-2'},
        'year': 2023,
      },
    },
  ];

  Widget createTestWidget({List<dynamic>? initialTrendingShows}) {
    return ProviderScope(
      overrides: [
        traktApiProvider.overrideWithValue(mockTraktApi),
        showTranslationServiceProvider.overrideWithValue(
          mockTranslationService,
        ),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: TrendingGrid(initialTrendingShows: initialTrendingShows),
        ),
      ),
    );
  }

  setUp(() {
    mockTraktApi = MockTraktApi();
    mockTranslationService = MockShowTranslationService();
    translationTracker = TranslationCallTracker();

    // Setup default mock responses
    when(mockTraktApi.getTrendingShows()).thenAnswer((_) async => testShows);

    // Setup translation service mock to track calls and return translated titles
    when(
      mockTranslationService.getTranslatedTitle(
        show: anyNamed('show'),
        traktApi: anyNamed('traktApi'),
      ),
    ).thenAnswer((invocation) async {
      final showArg =
          invocation.namedArguments[const Symbol('show')]
              as Map<String, dynamic>;
      translationTracker.trackCall(showArg);
      return 'Translated ${showArg['title']}';
    });
  });

  testWidgets('shows loading indicator when loading and translating', (
    tester,
  ) async {
    // Create a delayed future to test loading state
    final completer = Completer<List<dynamic>>();
    when(mockTraktApi.getTrendingShows()).thenAnswer((_) => completer.future);

    await tester.pumpWidget(createTestWidget(initialTrendingShows: null));

    // Initial build - should show loading indicator for API call
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('No hay shows en tendencia.'), findsNothing);

    // Complete the API future
    completer.complete(testShows);
    await tester.pump();

    // Should still show loading while translating
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Complete translations
    await tester.pumpAndSettle();

    // Verify the translated shows are displayed
    final tiles = tester.widgetList<SearchResultGridTile>(
      find.byType(SearchResultGridTile),
    );
    expect(tiles.length, testShows.length);
    expect(tiles.first.item.data['title'], 'Translated Test Show 1');
    expect(translationTracker.callCount, testShows.length);
  });

  testWidgets('displays shows when loaded and translates them', (tester) async {
    await tester.pumpWidget(createTestWidget(initialTrendingShows: testShows));

    // Initial pump shows loading indicator while translating
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Wait for translations to complete
    await tester.pumpAndSettle();

    // Verify shows are displayed using SearchResultGridTile
    final tiles = tester.widgetList<SearchResultGridTile>(
      find.byType(SearchResultGridTile),
    );
    expect(tiles.length, testShows.length);

    // Verify the first show's data is passed with translated title
    final firstTile = tiles.first;
    expect(firstTile.item.data['title'], 'Translated Test Show 1');

    // Verify translation service was called for each show
    expect(translationTracker.callCount, testShows.length);
    expect(
      translationTracker.translatedTitles,
      contains('Translated Test Show 1'),
    );
    expect(
      translationTracker.translatedTitles,
      contains('Translated Test Show 2'),
    );
  });

  testWidgets('shows empty state when API returns empty list', (tester) async {
    // Create a new mock API for this test
    final mockEmptyApi = MockTraktApi();
    when(mockEmptyApi.getTrendingShows()).thenAnswer((_) async => []);

    // Reset tracker for this test
    translationTracker = TranslationCallTracker();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          traktApiProvider.overrideWithValue(mockEmptyApi),
          showTranslationServiceProvider.overrideWithValue(
            mockTranslationService,
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: TrendingGrid())),
      ),
    );

    // Initial pump shows loading
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Complete the future and settle
    await tester.pumpAndSettle();

    // Verify empty state is shown and no translations were requested
    expect(find.text('No hay shows en tendencia.'), findsOneWidget);
    expect(translationTracker.callCount, 0);
  });

  testWidgets('uses and translates initialShows when provided', (tester) async {
    // Reset tracker for this test
    translationTracker = TranslationCallTracker();

    // Create a new mock API that should never be called
    final mockUnusedApi = MockTraktApi();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          traktApiProvider.overrideWithValue(mockUnusedApi),
          showTranslationServiceProvider.overrideWithValue(
            mockTranslationService,
          ),
        ],
        child: MaterialApp(
          home: Scaffold(body: TrendingGrid(initialTrendingShows: testShows)),
        ),
      ),
    );

    // Should show loading indicator while translating
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Wait for translations to complete
    await tester.pumpAndSettle();

    // Verify the API was never called
    verifyNever(mockUnusedApi.getTrendingShows());
  });
}
