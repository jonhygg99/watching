import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:watching/providers/app_providers.dart';
import 'package:watching/api/trakt/trakt_api.dart';
import 'package:watching/shared/widgets/comments/comments_list.dart';

// Test wrapper widget to provide dependencies
class TestWrapper extends StatelessWidget {
  final Widget child;
  final MockTraktApi traktApi;

  const TestWrapper({super.key, required this.child, required this.traktApi});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [traktApiProvider.overrideWithValue(traktApi)],
      child: MaterialApp(home: Scaffold(body: child)),
    );
  }
}

// Mock TraktApi
class MockTraktApi extends Mock implements TraktApi {
  @override
  final String baseUrl = 'https://api.trakt.test';

  @override
  Map<String, String> get headers => {};

  @override
  Future<void> ensureValidToken() async {}

  @override
  Future<Map<String, dynamic>> getJsonMap(String endpoint) async => {};

  @override
  Future<List<dynamic>> getJsonList(String endpoint) async => [];

  @override
  Future<http.Response> get(String endpoint) async => http.Response('', 200);

  @override
  Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async => http.Response('', 200);

  @override
  Future<http.Response> delete(String endpoint) async => http.Response('', 200);

  @override
  Future<List<dynamic>> getShowComments({
    required String id,
    String sort = 'newest',
    int page = 1,
    int limit = 10,
  }) {
    return super.noSuchMethod(
          Invocation.method(#getShowComments, null, {
            #id: id,
            #sort: sort,
            #page: page,
            #limit: limit,
          }),
          returnValue: Future.value(<Map<String, dynamic>>[]),
        )
        as Future<List<dynamic>>;
  }
}

void main() {
  late MockTraktApi mockTraktApi;
  late ValueNotifier<String> sortNotifier;
  late Map<String, String> sortLabels;
  const testShowId = 'test-show-123';

  setUp(() {
    mockTraktApi = MockTraktApi();
    sortNotifier = ValueNotifier<String>('newest');
    sortLabels = {'newest': 'Newest', 'oldest': 'Oldest'};
  });

  tearDown(() {
    sortNotifier.dispose();
  });

  // Helper to build the comments list widget
  Widget buildCommentsList() {
    return TestWrapper(
      traktApi: mockTraktApi,
      child: Consumer(
        builder:
            (context, ref, _) => TextButton(
              onPressed:
                  () => showAllComments(
                    context,
                    testShowId,
                    sortNotifier,
                    sortLabels,
                    ref,
                  ),
              child: const Text('Show Comments'),
            ),
      ),
    );
  }

  group('showAllComments', () {
    testWidgets('shows modal bottom sheet when button is pressed', (
      tester,
    ) async {
      // Arrange
      when(
        mockTraktApi.getShowComments(
          id: testShowId,
          sort: 'newest',
          page: 1,
          limit: 10,
        ),
      ).thenAnswer((_) async => <Map<String, dynamic>>[]);

      // Act
      await tester.pumpWidget(buildCommentsList());
      await tester.tap(find.text('Show Comments'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Comentarios'), findsOneWidget);
      expect(find.byType(IconButton), findsOneWidget);
    });

    testWidgets('displays loading indicator when loading comments', (
      tester,
    ) async {
      // Arrange
      final completer = Completer<List<Map<String, dynamic>>>();
      when(
        mockTraktApi.getShowComments(
          id: testShowId,
          sort: 'newest',
          page: 1,
          limit: 10,
        ),
      ).thenAnswer((_) => completer.future);

      // Act
      await tester.pumpWidget(buildCommentsList());
      await tester.tap(find.text('Show Comments'));
      await tester.pump();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete the future to avoid unhandled future errors
      completer.complete([]);
      await tester.pumpAndSettle();
    });

    testWidgets('displays error message when loading fails', (tester) async {
      // Arrange
      when(
        mockTraktApi.getShowComments(
          id: testShowId,
          sort: 'newest',
          page: 1,
          limit: 10,
        ),
      ).thenThrow(Exception('Failed to load comments'));

      // Act
      await tester.pumpWidget(buildCommentsList());
      await tester.tap(find.text('Show Comments'));
      await tester.pumpAndSettle();

      // Assert
      expect(
        find.text(
          'Error al cargar comentarios: Exception: Failed to load comments',
        ),
        findsOneWidget,
      );
    });

    testWidgets('loads more comments when scrolled to bottom', (tester) async {
      // Arrange
      // First page with 10 comments
      final firstPageComments = List<Map<String, dynamic>>.generate(
        10,
        (index) => ({
          'id': 'comment-$index',
          'comment': 'Comment $index',
          'user': {'username': 'user$index'},
          'likes': 0,
          'replies': 0,
          'created_at': DateTime.now().toIso8601String(),
        }),
      );

      // Second page with 5 more comments
      final secondPageComments = List<Map<String, dynamic>>.generate(
        5,
        (index) => ({
          'id': 'comment-${index + 10}',
          'comment':
              'Comment from second page ${index + 1}', // Make comment text more distinct
          'user': {'username': 'user${index + 10}'},
          'likes': 0,
          'replies': 0,
          'created_at': DateTime.now().toIso8601String(),
        }),
      );

      // Mock first page request
      when(
        mockTraktApi.getShowComments(
          id: testShowId,
          sort: 'newest',
          page: 1,
          limit: 10,
        ),
      ).thenAnswer((_) async => firstPageComments);

      // Mock second page request (will be called when scrolling)
      when(
        mockTraktApi.getShowComments(
          id: testShowId,
          sort: 'newest',
          page: 2,
          limit: 10,
        ),
      ).thenAnswer((_) async => secondPageComments);

      // Build and display the test widget
      await tester.pumpWidget(buildCommentsList());

      // Verify the 'Show Comments' button is present
      expect(find.text('Show Comments'), findsOneWidget);

      // Tap the button to show comments
      await tester.tap(find.text('Show Comments'));
      await tester.pump();

      // Wait for the modal to appear
      await tester.pumpAndSettle();

      // Verify the modal is shown
      expect(find.text('Comentarios'), findsOneWidget);

      // Verify the first page is loaded by checking for the first comment
      expect(find.text('Comment 0'), findsOneWidget);

      // Find the ListView in the modal bottom sheet
      final listView = find.byType(ListView);
      expect(listView, findsOneWidget);

      // Scroll to the bottom to trigger loading more comments
      await tester.drag(listView, const Offset(0, -1000));
      await tester.pumpAndSettle();

      // Verify the second page is loaded by checking for a comment from the second page
      expect(find.text('Comment from second page 1'), findsOneWidget);
    });

    testWidgets('refreshes comments when sort order changes', (tester) async {
      // Arrange - Initial sort order (newest)
      when(
        mockTraktApi.getShowComments(
          id: testShowId,
          sort: 'newest',
          page: 1,
          limit: 10,
        ),
      ).thenAnswer(
        (_) async => [
          {
            'id': '1',
            'comment': 'New Comment',
            'user': {'username': 'user1'},
            'likes': 0,
            'replies': 0,
            'created_at': DateTime.now().toIso8601String(),
          },
        ],
      );

      // Act - Show with initial sort
      await tester.pumpWidget(buildCommentsList());
      await tester.tap(find.text('Show Comments'));
      await tester.pumpAndSettle();

      // Assert initial load
      expect(find.text('New Comment'), findsOneWidget);

      // Arrange - Change sort order
      when(
        mockTraktApi.getShowComments(
          id: testShowId,
          sort: 'oldest',
          page: 1,
          limit: 10,
        ),
      ).thenAnswer(
        (_) async => [
          {
            'id': '2',
            'comment': 'Old Comment',
            'user': {'username': 'user2'},
            'likes': 0,
            'replies': 0,
            'created_at': DateTime.now().toIso8601String(),
          },
        ],
      );

      // Act - Change sort order
      sortNotifier.value = 'oldest';
      await tester.pumpAndSettle();

      // Assert new comments loaded
      expect(find.text('Old Comment'), findsOneWidget);
      expect(find.text('New Comment'), findsNothing);
    });
  });
}
