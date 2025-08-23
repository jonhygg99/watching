import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:watching/l10n/app_localizations.dart';
import 'package:watching/providers/app_providers.dart';

class CommentsController extends StateNotifier<CommentsState> {
  final WidgetRef ref;
  final BuildContext context;
  final String showId;
  String sortValue;
  final int? seasonNumber;
  final int? episodeNumber;
  final int commentsPerPage = 10;
  final ScrollController scrollController;

  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  bool _isInitialLoading = true;
  String? _errorMessage;

  CommentsController({
    required this.context,
    required WidgetRef ref,
    required this.showId,
    required this.sortValue,
    this.seasonNumber,
    this.episodeNumber,
    ScrollController? scrollController,
  }) : scrollController = scrollController ?? ScrollController(),
       ref = ref,
       super(CommentsState.initial()) {
    _loadComments();
    this.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    // Do not dispose the scroll controller if it was passed in
    super.dispose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      loadMore();
    }
  }

  bool get isLoadingMore => _isLoadingMore;
  bool get isInitialLoading => _isInitialLoading;
  bool get hasMore => _hasMore;
  String? get errorMessage => _errorMessage;
  List<Map<String, dynamic>> get comments => state.comments;

  // Expose the StateNotifier's stream
  @override
  Stream<CommentsState> get stream => super.stream;

  Future<void> _loadComments() async {
    if (_isLoadingMore || !_hasMore) return;

    // Update loading state
    _updateState(
      isLoadingMore: _currentPage > 1,
      isInitialLoading: _currentPage == 1,
      errorMessage: null,
    );

    try {
      final traktApi = ref.read(traktApiProvider);
      final List<dynamic> response;

      if (seasonNumber != null && episodeNumber != null) {
        // Load episode comments
        response = await traktApi.getEpisodeComments(
          id: showId,
          season: seasonNumber!,
          episode: episodeNumber!,
          sort: sortValue,
          page: _currentPage,
          limit: commentsPerPage,
        );
      } else {
        // Load show comments
        response = await traktApi.getShowComments(
          id: showId,
          sort: sortValue,
          page: _currentPage,
          limit: commentsPerPage,
        );
      }

      final List<Map<String, dynamic>> currentPageComments =
          (response).cast<Map<String, dynamic>>();

      // Check if there's a next page
      bool hasNextPage = false;
      try {
        final nextPageResponse =
            seasonNumber != null && episodeNumber != null
                ? await traktApi.getEpisodeComments(
                  id: showId,
                  season: seasonNumber!,
                  episode: episodeNumber!,
                  sort: sortValue,
                  page: _currentPage + 1,
                  limit: 1,
                )
                : await traktApi.getShowComments(
                  id: showId,
                  sort: sortValue,
                  page: _currentPage + 1,
                  limit: 1,
                );
        hasNextPage = nextPageResponse.isNotEmpty;
      } catch (e) {
        // If there's an error checking the next page, assume there are more
        hasNextPage = true;
      }

      // Update state with new comments
      _updateState(
        comments:
            _currentPage == 1
                ? currentPageComments
                : [...state.comments, ...currentPageComments],
        isLoadingMore: false,
        isInitialLoading: false,
        hasMore:
            hasNextPage ||
            (currentPageComments.isNotEmpty &&
                currentPageComments.length >= commentsPerPage),
      );
    } catch (e) {
      _updateState(
        isLoadingMore: false,
        isInitialLoading: false,
        errorMessage: AppLocalizations.of(context)!.errorLoadingComments,
        hasMore: true,
      );
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore || _isInitialLoading) return;
    _currentPage++;
    await _loadComments();
  }

  Future<void> refresh() async {
    _currentPage = 1;
    _updateState(comments: []);
    await _loadComments();
  }

  void _updateState({
    List<Map<String, dynamic>>? comments,
    bool? isLoadingMore,
    bool? isInitialLoading,
    bool? hasMore,
    String? errorMessage,
  }) {
    // Update internal state variables
    if (isLoadingMore != null) _isLoadingMore = isLoadingMore;
    if (isInitialLoading != null) _isInitialLoading = isInitialLoading;
    if (hasMore != null) _hasMore = hasMore;
    if (errorMessage != null) _errorMessage = errorMessage;

    // Update the state
    state = state.copyWith(
      comments: comments ?? state.comments,
      isLoadingMore: _isLoadingMore,
      isInitialLoading: _isInitialLoading,
      hasMore: _hasMore,
      errorMessage: _errorMessage,
    );
  }
}

class CommentsState {
  final List<Map<String, dynamic>> comments;
  final bool isLoadingMore;
  final bool isInitialLoading;
  final bool hasMore;
  final String? errorMessage;

  const CommentsState({
    required this.comments,
    required this.isLoadingMore,
    required this.isInitialLoading,
    required this.hasMore,
    this.errorMessage,
  });

  factory CommentsState.initial() => const CommentsState(
    comments: [],
    isLoadingMore: false,
    isInitialLoading: true,
    hasMore: true,
    errorMessage: null,
  );

  CommentsState copyWith({
    List<Map<String, dynamic>>? comments,
    bool? isLoadingMore,
    bool? isInitialLoading,
    bool? hasMore,
    String? errorMessage,
  }) {
    return CommentsState(
      comments: comments ?? this.comments,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
