import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watching/providers/app_providers.dart';

/// Shows a modal bottom sheet with all comments for a show
Future<void> showAllComments(
  BuildContext context,
  String showId,
  ValueNotifier<String> sort,
  Map<String, String> sortLabels,
  WidgetRef ref,
) async {
  final apiService = ref.read(traktApiProvider);
  // Fetch comments with the current sort order when the modal is opened
  final commentsFuture = apiService.getShowComments(
    id: showId,
    sort: sort.value,
  );

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Comentarios',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _CommentsList(
              commentsFuture: commentsFuture,
              sort: sort.value,
              sortLabels: sortLabels,
              showId: showId,
            ),
          ),
        ],
      ),
    ),
  );
}

class _CommentsList extends ConsumerStatefulWidget {
  final Future<List<dynamic>> commentsFuture;
  final String sort;
  final Map<String, String> sortLabels;
  final String showId;
  
  const _CommentsList({
    required this.commentsFuture,
    required this.sort,
    required this.sortLabels,
    required this.showId,
  });

  @override
  ConsumerState<_CommentsList> createState() => _CommentsListState();
}

class _CommentsListState extends ConsumerState<_CommentsList> {
  late final ScrollController _scrollController;
  late String _currentSort;
  late Future<List<dynamic>> _commentsFuture;

  @override
  void initState() {
    super.initState();
    _currentSort = widget.sort;
    _commentsFuture = widget.commentsFuture;
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  void _handleSortChanged(String? newSort) {
    if (newSort != null && newSort != _currentSort) {
      setState(() {
        _currentSort = newSort;
        // Save the current scroll position
        final scrollOffset = _scrollController.position.pixels;
        // Update the comments future with the new sort
        final apiService = ref.read(traktApiProvider);
        _commentsFuture = apiService.getShowComments(
          id: widget.showId,
          sort: newSort,
        ).then((comments) {
          // Schedule the scroll restoration after the build is complete
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollController.jumpTo(scrollOffset);
          });
          return comments;
        });
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _commentsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Error loading comments: ${snapshot.error}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final comments = snapshot.data ?? [];

        if (comments.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'No comments yet',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  DropdownButton<String>(
                    value: widget.sort,
                    underline: const SizedBox(),
                    items: widget.sortLabels.entries
                        .map((entry) => DropdownMenuItem(
                              value: entry.key,
                              child: Text(entry.value),
                            ))
                        .toList(),
                    onChanged: _handleSortChanged,
                    isExpanded: false,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                itemCount: comments.length,
                key: PageStorageKey<String>('comments_${widget.showId}_$_currentSort'),
                itemBuilder: (context, index) {
                  final comment = comments[index];
                  return _buildCommentTile(context, comment);
                },
              ),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildCommentTile(BuildContext context, dynamic comment) {
    final user = comment['user'] ?? {};

    final userName = user['username'] ?? 'Unknown';
    final userAvatar = user['images']?['avatar']?['full'];
    final commentText = comment['comment'] ?? '';
    final likes = comment['likes'] ?? 0;
    final isSpoiler = comment['spoiler'] == true;
    final isReview = comment['review'] == true;
    final date = comment['created_at']?.substring(0, 10) ?? '';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (userAvatar != null)
                  CircleAvatar(
                    backgroundImage: NetworkImage(userAvatar),
                    radius: 20,
                  )
                else
                  const CircleAvatar(radius: 20, child: Icon(Icons.person)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      date,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
                const Spacer(),
                if (isSpoiler)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'SPOILER',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                if (isReview) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'REVIEW',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              commentText,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.thumb_up, size: 20),
                const SizedBox(width: 6),
                Text(
                  likes.toString(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.normal,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
