import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watching/providers/app_providers.dart';
import 'package:watching/services/trakt/trakt_api.dart';

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
  final List<dynamic> _allComments = [];
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  static const int _commentsPerPage = 10;
  final _apiService = TraktApi();

  @override
  void initState() {
    super.initState();
    _currentSort = widget.sort;
    _commentsFuture = widget.commentsFuture.then((comments) {
      _allComments.addAll(comments);
      _hasMore = comments.length == _commentsPerPage;
      return _allComments;
    });
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreComments();
    }
  }
  
  Future<void> _loadMoreComments() async {
    if (_isLoadingMore || !_hasMore) return;
    
    setState(() {
      _isLoadingMore = true;
    });
    
    try {
      final nextPage = _currentPage + 1;
      final newComments = await _apiService.getShowComments(
        id: widget.showId,
        sort: _currentSort,
        page: nextPage,
        limit: _commentsPerPage,
      );
      
      if (mounted) {
        setState(() {
          _allComments.addAll(newComments);
          _hasMore = newComments.length == _commentsPerPage;
          _currentPage = nextPage;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
      // Optionally show error message
    }
  }
  
  Future<void> _handleSortChanged(String? newSort) async {
    if (newSort != null && newSort != _currentSort) {
      if (!mounted) return;
      
      setState(() {
        _currentSort = newSort;
        _currentPage = 1;
        _hasMore = true;
        _allComments.clear();
        _isLoadingMore = false;
      });
      
      try {
        final newComments = await _apiService.getShowComments(
          id: widget.showId,
          sort: newSort,
          page: 1,
          limit: _commentsPerPage,
        );
        
        if (mounted) {
          setState(() {
            _allComments.clear();
            _allComments.addAll(newComments);
            _hasMore = newComments.length == _commentsPerPage;
            _currentPage = 1;
          });
        }
      } catch (error) {
        if (mounted) {
          setState(() {
            _hasMore = false;
          });
          // Optionally show error message to user
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error loading comments. Please try again.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _commentsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && _allComments.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError && _allComments.isEmpty) {
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

        if (_allComments.isEmpty) {
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filtros',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  DropdownButton<String>(
                    value: _currentSort,
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
                itemCount: _allComments.length + (_hasMore ? 1 : 0),
                key: PageStorageKey<String>('comments_${widget.showId}_$_currentSort'),
                itemBuilder: (context, index) {
                  if (index >= _allComments.length) {
                    return _buildLoadMoreButton();
                  }
                  final comment = _allComments[index];
                  return _buildCommentTile(context, comment);
                },
              ),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildLoadMoreButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: Center(
        child: _isLoadingMore
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _hasMore ? _loadMoreComments : null,
                child: const Text('Ver más'),
              ),
      ),
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
