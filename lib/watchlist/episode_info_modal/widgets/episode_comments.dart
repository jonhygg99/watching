import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:watching/services/trakt/trakt_api.dart';

class EpisodeComments extends HookConsumerWidget {
  final int showId;
  final int seasonNumber;
  final int episodeNumber;

  const EpisodeComments({
    super.key,
    required this.showId,
    required this.seasonNumber,
    required this.episodeNumber,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sort = useState<String>('newest');
    final sortLabels = const {
      'likes': 'Más likes',
      'newest': 'Más recientes',
      'oldest': 'Más antiguos',
      'replies': 'Más respuestas',
      'highest': 'Mejor valorados',
      'lowest': 'Peor valorados',
      'plays': 'Más reproducidos',
      'watched': 'Más vistos',
    };

    return _EpisodeCommentsList(
      showId: showId.toString(),
      seasonNumber: seasonNumber,
      episodeNumber: episodeNumber,
      sort: sort,
      sortLabels: sortLabels,
    );
  }
}

class _EpisodeCommentsList extends ConsumerStatefulWidget {
  final String showId;
  final int seasonNumber;
  final int episodeNumber;
  final ValueNotifier<String> sort;
  final Map<String, String> sortLabels;

  const _EpisodeCommentsList({
    required this.showId,
    required this.seasonNumber,
    required this.episodeNumber,
    required this.sort,
    required this.sortLabels,
  });

  @override
  ConsumerState<_EpisodeCommentsList> createState() =>
      _EpisodeCommentsListState();
}

class _EpisodeCommentsListState extends ConsumerState<_EpisodeCommentsList> {
  final List<Map<String, dynamic>> _allComments = [];
  final _scrollController = ScrollController();
  final int _commentsPerPage = 10;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  bool _isInitialLoading = true;
  String? _errorMessage;
  final _apiService = TraktApi();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadComments();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreComments();
    }
  }

  Future<void> _loadComments() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
      _isInitialLoading = _currentPage == 1;
      _errorMessage = null;
    });

    try {
      final response = await _apiService.getEpisodeComments(
        id: widget.showId,
        season: widget.seasonNumber,
        episode: widget.episodeNumber,
        sort: widget.sort.value,
        page: _currentPage,
        limit: _commentsPerPage,
      );

      // Convert the response to List<Map<String, dynamic>>
      final List<Map<String, dynamic>> comments =
          response
              .map<Map<String, dynamic>>((item) => item as Map<String, dynamic>)
              .toList();

      if (mounted) {
        setState(() {
          _allComments.addAll(comments);
          _hasMore = comments.length == _commentsPerPage;
          _isLoadingMore = false;
          _isInitialLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading comments: $e';
          _isLoadingMore = false;
          _isInitialLoading = false;
        });
      }
    }
  }

  Future<void> _loadMoreComments() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _currentPage++;
    });

    await _loadComments();
  }

  Future<void> _handleSortChanged(String? newSort) async {
    if (newSort != null && newSort != widget.sort.value) {
      if (!mounted) return;

      setState(() {
        widget.sort.value = newSort;
        _currentPage = 1;
        _hasMore = true;
        _allComments.clear();
        _isLoadingMore = false;
      });

      await _loadComments();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _errorMessage!,
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
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: widget.sort.value,
                icon: const Icon(Icons.arrow_drop_down),
                onChanged: _handleSortChanged,
                items:
                    widget.sortLabels.entries.map((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.only(bottom: 16.0),
            itemCount: _allComments.length + (_hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= _allComments.length) {
                return _buildLoadMoreButton();
              }
              final comment = _allComments[index];
              return _buildCommentTile(comment);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLoadMoreButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child:
            _isLoadingMore
                ? const CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: _hasMore ? _loadMoreComments : null,
                  child: const Text('Load more'),
                ),
      ),
    );
  }

  Widget _buildCommentTile(Map<String, dynamic> comment) {
    final user = comment['user'] ?? {};
    final userName = user['username'] ?? 'Unknown';
    final userAvatar = user['images']?['avatar']?['full'];
    final commentText = comment['comment'] ?? '';
    final likes = comment['likes'] ?? 0;
    final isSpoiler = comment['spoiler'] == true;
    final isReview = comment['review'] == true;

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
                Text(
                  userName,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
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
            Text(commentText, style: Theme.of(context).textTheme.bodyMedium),
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
