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
                  sort: sort,
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
  final ValueNotifier<String> sort;
  final Map<String, String> sortLabels;
  final String showId;

  const _CommentsList({
    required this.sort,
    required this.sortLabels,
    required this.showId,
  });

  @override
  ConsumerState<_CommentsList> createState() => _CommentsListState();
}

class _CommentsListState extends ConsumerState<_CommentsList> {
  final List<Map<String, dynamic>> _allComments = [];
  final ScrollController _scrollController = ScrollController();
  final int _commentsPerPage = 10;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  bool _isInitialLoading = true;
  String? _errorMessage;

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
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    widget.sort.removeListener(_onSortChanged);
    super.dispose();
  }

  void _onSortChanged() {
    if (mounted) {
      _resetAndLoadComments();
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreComments();
    }
  }

  void _resetAndLoadComments() {
    setState(() {
      _currentPage = 1;
      _allComments.clear();
      _hasMore = true;
      _isInitialLoading = true;
      _isLoadingMore = false;
      _errorMessage = null;
    });
    _loadComments();
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
      final sortValue = widget.sort.value;
      final traktApi = ref.read(traktApiProvider);

      // Cargar la página actual
      final response = await traktApi.getShowComments(
        id: widget.showId,
        sort: sortValue,
        page: _currentPage,
        limit: _commentsPerPage,
      );

      if (mounted) {
        final List<Map<String, dynamic>> currentPageComments =
            (response).cast<Map<String, dynamic>>();

        // Verificar si hay una siguiente página
        bool hasNextPage = false;
        try {
          final nextPageResponse = await traktApi.getShowComments(
            id: widget.showId,
            sort: sortValue,
            page: _currentPage + 1,
            limit: 1, // Solo necesitamos un comentario para verificar
          );
          hasNextPage = nextPageResponse.isNotEmpty;
        } catch (e) {
          // Si hay un error al verificar la siguiente página, asumimos que hay más
          hasNextPage = true;
        }

        setState(() {
          if (_currentPage == 1) {
            _allComments.clear();
          }

          // Filtrar comentarios duplicados
          final existingIds = _allComments.map((c) => c['id']).toSet();
          final newComments =
              currentPageComments
                  .where((comment) => !existingIds.contains(comment['id']))
                  .toList();

          _allComments.addAll(newComments);

          // Actualizar el estado de carga
          _isLoadingMore = false;
          _isInitialLoading = false;

          // Determinar si hay más comentarios por cargar
          _hasMore =
              hasNextPage ||
              (currentPageComments.isNotEmpty &&
                  currentPageComments.length >= _commentsPerPage);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error al cargar comentarios: ${e.toString()}';
          _isLoadingMore = false;
          _isInitialLoading = false;
          // En caso de error, asumimos que podría haber más comentarios
          _hasMore = true;
        });
      }
    }
  }

  Future<void> _loadMoreComments() async {
    if (_isLoadingMore || !_hasMore || _isInitialLoading) return;

    // Incrementar el contador de página
    _currentPage++;

    // Cargar los comentarios de la siguiente página
    await _loadComments();
  }

  Future<void> _refresh() async {
    _resetAndLoadComments();
  }

  @override
  Widget build(BuildContext context) {
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
              DropdownButton<String>(
                value: widget.sort.value,
                underline: const SizedBox(),
                items:
                    widget.sortLabels.entries
                        .map(
                          (entry) => DropdownMenuItem(
                            value: entry.key,
                            child: Text(entry.value),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  if (value != null) {
                    widget.sort.value = value;
                  }
                },
                isExpanded: false,
              ),
            ],
          ),
        ),
        Expanded(
          child:
              _isInitialLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _errorMessage!,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _refresh,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                  : _allComments.isEmpty
                  ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'No comments yet',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                  : RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(
                        left: 8.0,
                        right: 8.0,
                        top: 8.0,
                        bottom: 24.0,
                      ),
                      itemCount: _allComments.length + (_hasMore ? 1 : 0),
                      key: PageStorageKey<String>(
                        'comments_${widget.showId}_${widget.sort.value}',
                      ),
                      itemBuilder: (context, index) {
                        if (index >= _allComments.length) {
                          // Loading indicator for more comments
                          return _isLoadingMore
                              ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: CircularProgressIndicator(),
                                ),
                              )
                              : const SizedBox.shrink();
                        }
                        final comment = _allComments[index];
                        return _buildCommentTile(context, comment);
                      },
                    ),
                  ),
        ),
      ],
    );
  }

  Widget _buildCommentTile(BuildContext context, Map<String, dynamic> comment) {
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
