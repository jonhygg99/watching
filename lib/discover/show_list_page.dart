import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watching/api/trakt/show_translation.dart';
import 'package:watching/providers/app_providers.dart';

class ShowListPage extends ConsumerStatefulWidget {
  final String title;
  final List<dynamic> initialShows;
  final dynamic Function(dynamic) extractShow;
  final Future<List<dynamic>> Function({int page, int limit}) fetchShows;
  final String? period;

  const ShowListPage({
    super.key,
    required this.title,
    required this.initialShows,
    required this.extractShow,
    required this.fetchShows,
    this.period,
  });

  @override
  ConsumerState<ShowListPage> createState() => _ShowListPageState();
}

class _ShowListPageState extends ConsumerState<ShowListPage> {
  final ScrollController _scrollController = ScrollController();
  final int _showsPerPage = 20;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  bool _isInitialLoading = false;
  String? _errorMessage;
  late List<dynamic> _allShows = [];
  late dynamic Function(dynamic) _extractShow;
  late Future<List<dynamic>> Function({int page, int limit}) _fetchShows;

  @override
  void initState() {
    super.initState();
    _extractShow = widget.extractShow;
    _fetchShows = widget.fetchShows;
    _allShows = widget.initialShows.toList();
    _scrollController.addListener(_onScroll);
    _checkForMoreShows();
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
      _loadMoreShows();
    }
  }

  Future<void> _loadMoreShows() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
      _errorMessage = null;
    });

    try {
      final nextPage = _currentPage + 1;
      final newShows = await _fetchShows(page: nextPage, limit: _showsPerPage);

      if (mounted) {
        setState(() {
          _allShows.addAll(newShows);
          _currentPage = nextPage;
          _isLoadingMore = false;
          _checkForMoreShows();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error al cargar más shows';
          _isLoadingMore = false;
        });
      }
    }
  }

  void _checkForMoreShows() async {
    if (_isLoadingMore) return;

    try {
      final nextPageShows = await _fetchShows(page: _currentPage + 1, limit: 1);

      if (mounted) {
        setState(() {
          _hasMore = nextPageShows.isNotEmpty;
        });
      }
    } catch (e) {
      // If there's an error, assume there might be more shows
      if (mounted) {
        setState(() {
          _hasMore = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body:
          _allShows.isEmpty && !_isInitialLoading
              ? const Center(child: Text('No hay shows disponibles'))
              : Stack(
                children: [
                  _buildShowsGrid(),
                  if (_isLoadingMore) _buildLoadingIndicator(),
                  if (_errorMessage != null) _buildErrorIndicator(),
                ],
              ),
    );
  }

  Widget _buildShowsGrid() {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2 / 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
      ),
      itemCount: _allShows.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _allShows.length) {
          return const SizedBox.shrink();
        }

        final show = _extractShow(_allShows[index]);
        return _buildShowItem(
          ref: ref,
          context: context,
          show: show,
          shows: _allShows,
          index: index,
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        height: 60,
        color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.8),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorIndicator() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.all(8),
        color: Colors.red[50],
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton(
              onPressed: _loadMoreShows,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShowItem({
    required WidgetRef ref,
    required BuildContext context,
    required Map<String, dynamic> show,
    required List<dynamic> shows,
    required int index,
  }) {
    return FutureBuilder<String>(
      future: ref
          .read(showTranslationServiceProvider)
          .getTranslatedTitle(show: show, traktApi: ref.read(traktApiProvider)),
      builder: (context, snapshot) {
        final title = snapshot.data ?? show['title'] ?? '';
        final posterArr = show['images']?['poster'] as List?;
        final posterUrl =
            (posterArr != null && posterArr.isNotEmpty)
                ? 'https://${posterArr.first}'
                : null;

        return GestureDetector(
          onTap: () {
            final showId = _getShowId(show);
            if (showId.isNotEmpty) {
              // TODO: Navigate to show details when the page is implemented
              // Navigator.of(context).push(
              //   MaterialPageRoute(
              //     builder: (context) => ShowDetailsPage(showId: showId),
              //   ),
              // );
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child:
                      posterUrl != null
                          ? CachedNetworkImage(
                            imageUrl: posterUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            placeholder:
                                (context, url) => Container(
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                            errorWidget:
                                (context, url, error) => Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.error),
                                ),
                          )
                          : Container(
                            color: Colors.grey[300],
                            child: const Center(child: Icon(Icons.tv)),
                          ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getShowId(Map<String, dynamic> show) {
    if (show['ids']?['trakt'] != null) {
      return show['ids']['trakt'].toString();
    } else if (show['ids']?['slug'] != null) {
      return show['ids']['slug'].toString();
    } else if (show['ids']?['imdb'] != null) {
      return show['ids']['imdb'].toString();
    } else if (show['ids']?['tmdb'] != null) {
      return show['ids']['tmdb'].toString();
    } else if (show['ids']?['tvdb'] != null) {
      return show['ids']['tvdb'].toString();
    }
    return '';
  }
}
