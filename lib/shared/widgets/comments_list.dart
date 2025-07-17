import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watching/providers/app_providers.dart';

enum CommentType {
  show,
  episode,
}

class CommentsList extends ConsumerStatefulWidget {
  final CommentType type;
  final String id;
  final int? seasonNumber;
  final int? episodeNumber;
  final ValueNotifier<String> sort;
  final Map<String, String> sortLabels;
  final String title;
  final bool showTitle;

  const CommentsList({
    super.key,
    required this.type,
    required this.id,
    this.seasonNumber,
    this.episodeNumber,
    required this.sort,
    required this.sortLabels,
    this.title = 'Comentarios',
    this.showTitle = true,
  });

  @override
  ConsumerState<CommentsList> createState() => _CommentsListState();
}

class _CommentsListState extends ConsumerState<CommentsList> {
  final List<Map<String, dynamic>> _allComments = [];
  final ScrollController _scrollController = ScrollController();
  final int _commentsPerPage = 10;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  bool _isInitialLoading = true;
  String? _errorMessage;

  _CommentsListState();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Add listener to sort changes
    widget.sort.addListener(_onSortChanged);
    _loadComments();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    widget.sort.removeListener(_onSortChanged);
    super.dispose();
  }

  void _onSortChanged() {
    if (mounted) {
      setState(() {
        _currentPage = 1;
        _allComments.clear();
        _hasMore = true;
        _isInitialLoading = true;
        _loadComments();
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreComments();
    }
  }

  Future<void> _loadComments() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      if (_currentPage == 1) {
        _isInitialLoading = true;
      } else {
        _isLoadingMore = true;
      }
      _errorMessage = null;
    });

    try {
      final sortValue = widget.sort.value; // Get current sort value
      final traktApi = ref.read(traktApiProvider);
      
      List<dynamic> response;
      
      if (widget.type == CommentType.show) {
        response = await traktApi.getShowComments(
          id: widget.id,
          sort: sortValue,
          page: _currentPage,
          limit: _commentsPerPage,
        );
      } else {
        if (widget.seasonNumber == null || widget.episodeNumber == null) {
          throw Exception('Season and episode numbers are required for episode comments');
        }
        response = await traktApi.getEpisodeComments(
          id: widget.id,
          season: widget.seasonNumber!,
          episode: widget.episodeNumber!,
          sort: sortValue,
          page: _currentPage,
          limit: _commentsPerPage,
        );
      }

      setState(() {
        if (_currentPage == 1) {
          _allComments.clear();
        }
        _allComments.addAll(response.cast<Map<String, dynamic>>());
        _hasMore = response.length == _commentsPerPage;
        _isLoadingMore = false;
        _isInitialLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading comments: ${e.toString()}';
        _isLoadingMore = false;
        _isInitialLoading = false;
      });
    }
  }

  Future<void> _loadMoreComments() async {
    if (_isLoadingMore || !_hasMore) return;
    _currentPage++;
    await _loadComments();
  }

  Future<void> _refresh() async {
    _currentPage = 1;
    await _loadComments();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showTitle) ...[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                DropdownButton<String>(
                  value: widget.sort.value,
                  items: widget.sortLabels.entries
                      .map((e) => DropdownMenuItem(
                            value: e.key,
                            child: Text(e.value),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      widget.sort.value = value;
                      _currentPage = 1;
                      _loadComments();
                    }
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
        ],
        Expanded(
          child: _isInitialLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
                  ? Center(child: Text(_errorMessage!))
                  : _allComments.isEmpty
                      ? const Center(child: Text('No comments found'))
                      : RefreshIndicator(
                          onRefresh: _refresh,
                          child: ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(8.0),
                            itemCount: _allComments.length + (_hasMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index >= _allComments.length) {
                                return const Center(
                                    child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: CircularProgressIndicator(),
                                ));
                              }

                              final comment = _allComments[index];
                              return _buildCommentItem(comment);
                            },
                          ),
                        ),
        ),
      ],
    );
  }

  Widget _buildCommentItem(Map<String, dynamic> comment) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: comment['user']?['avatar'] != null
                      ? NetworkImage(
                          'https://www.gravatar.com/avatar/${comment['user']['avatar']}')
                      : null,
                  child: comment['user']?['avatar'] == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                const SizedBox(width: 8.0),
                Text(
                  comment['user']?['username'] ?? 'Unknown',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  _formatDate(comment['created_at']),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Text(comment['comment'] ?? ''),
            const SizedBox(height: 8.0),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.thumb_up_outlined, size: 20.0),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                Text('${comment['likes'] ?? 0}'),
                const SizedBox(width: 16.0),
                IconButton(
                  icon: const Icon(Icons.reply_outlined, size: 20.0),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    final date = DateTime.tryParse(dateString);
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Shows a modal bottom sheet with all comments for a show or episode
Future<void> showCommentsModal(
  BuildContext context, {
  required CommentType type,
  required String id,
  int? seasonNumber,
  int? episodeNumber,
  required ValueNotifier<String> sort,
  required Map<String, String> sortLabels,
  String title = 'Comentarios',
}) async {
  if (type == CommentType.episode && (seasonNumber == null || episodeNumber == null)) {
    throw ArgumentError('seasonNumber and episodeNumber are required for episode comments');
  }

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            expand: false,
            builder: (_, controller) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Column(
                  children: [
                    AppBar(
                      title: Text(title),
                      leading: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                      actions: [
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            setState(() {
                              sort.value = value;
                            });
                          },
                          itemBuilder: (context) => sortLabels.entries
                              .map((e) => PopupMenuItem<String>(
                                    value: e.key,
                                    child: Text(e.value),
                                  ))
                              .toList(),
                          icon: const Icon(Icons.sort),
                        ),
                      ],
                    ),
                    Expanded(
                      child: CommentsList(
                        type: type,
                        id: id,
                        seasonNumber: seasonNumber,
                        episodeNumber: episodeNumber,
                        sort: sort,
                        sortLabels: sortLabels,
                        showTitle: false,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    },
  );
}
