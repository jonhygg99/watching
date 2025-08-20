import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:watching/l10n/app_localizations.dart';
import 'package:watching/shared/widgets/comments/widgets/tile.dart';
import 'package:watching/shared/widgets/comments/widgets/controller.dart';
import 'package:watching/shared/widgets/comments/widgets/error_widget.dart';
import 'package:watching/shared/widgets/comments/widgets/loading_widget.dart';
import 'package:watching/shared/widgets/comments/widgets/sort_selector.dart';

/// Shows a modal bottom sheet with all comments for a show or episode
///
/// [showId] - The ID of the show
/// [sort] - The current sort value
/// [sortLabels] - Map of sort values to display names
/// [ref] - The WidgetRef for Riverpod
/// [seasonNumber] - Optional season number for episode comments
/// [episodeNumber] - Optional episode number for episode comments
Future<void> showAllComments(
  BuildContext context,
  String string, {
  required String showId,
  required ValueNotifier<String> sort,
  required List<String> sortKeys,
  required WidgetRef ref,
  int? seasonNumber,
  int? episodeNumber,
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder:
        (context) => Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              _CommentsHeader(onClose: () => Navigator.of(context).pop()),
              const Divider(height: 1),
              Expanded(
                child: _CommentsList(
                  sort: sort,
                  sortKeys: sortKeys,
                  showId: showId,
                  seasonNumber: seasonNumber,
                  episodeNumber: episodeNumber,
                ),
              ),
            ],
          ),
        ),
  );
}

class _CommentsHeader extends StatelessWidget {
  final VoidCallback onClose;

  const _CommentsHeader({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Comentarios',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          IconButton(icon: const Icon(Icons.close), onPressed: onClose),
        ],
      ),
    );
  }
}

class _CommentsList extends ConsumerStatefulWidget {
  const _CommentsList({
    required this.sort,
    required this.sortKeys,
    required this.showId,
    this.seasonNumber,
    this.episodeNumber,
  });

  final ValueNotifier<String> sort;
  final List<String> sortKeys;
  final String showId;
  final int? seasonNumber;
  final int? episodeNumber;

  @override
  ConsumerState<_CommentsList> createState() => _CommentsListState();
}

class _CommentsListState extends ConsumerState<_CommentsList> {
  late final CommentsController _controller;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = CommentsController(
      context: context,
      ref: ref,
      showId: widget.showId,
      sortValue: widget.sort.value,
      seasonNumber: widget.seasonNumber,
      episodeNumber: widget.episodeNumber,
    );

    widget.sort.addListener(_onSortChanged);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.sort.removeListener(_onSortChanged);
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onSortChanged() {
    // Update the controller's sort value and refresh the data
    _controller.sortValue = widget.sort.value;
    _controller.refresh();
    // No need to call setState, as the StreamBuilder will rebuild
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _controller.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: widget.sort,
      builder: (context, sortValue, _) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: CommentsSortSelector(
                value: sortValue,
                sortKeys: widget.sortKeys,
                onChanged: (value) {
                  if (value != null) {
                    widget.sort.value = value;
                  }
                },
              ),
            ),
            Expanded(
              child: StreamBuilder<CommentsState>(
                stream: _controller.stream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return const CommentsLoadingWidget();
                  }

                  final state = snapshot.data;

                  if (state == null || state.isInitialLoading) {
                    return const CommentsLoadingWidget();
                  }

                  if (state.errorMessage != null) {
                    return CommentsErrorWidget(
                      message: state.errorMessage!,
                      onRetry: _controller.refresh,
                    );
                  }

                  if (state.comments.isEmpty) {
                    return _buildEmptyState(context);
                  }

                  return _buildCommentsList(state);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          AppLocalizations.of(context)!.noCommentsYet,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ),
    );
  }

  Widget _buildCommentsList(CommentsState state) {
    return RefreshIndicator(
      onRefresh: _controller.refresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(
          left: 8.0,
          right: 8.0,
          top: 8.0,
          bottom: 24.0,
        ),
        itemCount: state.comments.length + (state.hasMore ? 1 : 0),
        key: PageStorageKey<String>('comments_${widget.showId}_${widget.sort.value}'),
        itemBuilder: (context, index) {
          if (index >= state.comments.length) {
            return _controller.isLoadingMore
                ? const CommentsLoadingWidget(isInitialLoad: false)
                : const SizedBox.shrink();
          }
          return CommentTile(comment: state.comments[index]);
        },
      ),
    );
  }
}
