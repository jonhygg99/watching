import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:watching/features/show_list/widgets/error_indicator.dart';
import 'package:watching/features/show_list/widgets/loading_indicator.dart';
import 'package:watching/features/show_list/widgets/shows_grid.dart';
import 'package:watching/l10n/app_localizations.dart';

class ShowListPage extends HookConsumerWidget {
  const ShowListPage({
    super.key,
    required this.title,
    required this.initialShows,
    required this.extractShow,
    required this.fetchShows,
    this.period,
  });

  final String title;
  final List<dynamic> initialShows;
  final dynamic Function(dynamic) extractShow;
  final Future<List<dynamic>> Function({int page, int limit}) fetchShows;
  final String? period;

  static const int _showsPerPage = 20;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // State management with hooks
    final scrollController = useScrollController();
    final currentPage = useState(1);
    final hasMore = useState(true);
    final isLoadingMore = useState(false);
    final isInitialLoading = useState(false);
    final errorMessage = useState<String?>(null);
    final allShows = useState<List<dynamic>>([...initialShows]);

    // Load more shows function
    final loadMoreShows = useCallback(() async {
      if (isLoadingMore.value || !hasMore.value) return;

      isLoadingMore.value = true;
      errorMessage.value = null;

      try {
        final nextPage = currentPage.value + 1;
        final response = await fetchShows(page: nextPage, limit: _showsPerPage);
        final List<dynamic> newShows = List<dynamic>.from(response);
        final bool hasMoreShows = newShows.length >= _showsPerPage;

        allShows.value = [...allShows.value, ...newShows];
        currentPage.value = nextPage;
        hasMore.value = hasMoreShows;
      } catch (e, stackTrace) {
        debugPrint('Error loading more shows: $e');
        debugPrint('Stack trace: $stackTrace');
        errorMessage.value = "Error";
      } finally {
        isLoadingMore.value = false;
      }
    }, [fetchShows]);

    // Check for more shows
    final checkForMoreShows = useCallback(() async {
      if (isLoadingMore.value) return;

      try {
        final nextPageShows = await fetchShows(
          page: currentPage.value + 1,
          limit: 1,
        );
        hasMore.value = nextPageShows.isNotEmpty;
      } catch (e) {
        hasMore.value = true;
      }
    }, [fetchShows]);

    // Setup scroll listener
    useEffect(() {
      void onScroll() {
        if (!scrollController.hasClients ||
            isLoadingMore.value ||
            !hasMore.value) {
          return;
        }

        final maxScroll = scrollController.position.maxScrollExtent;
        final currentScroll = scrollController.position.pixels;
        final double threshold = maxScroll * 0.8;

        if (currentScroll >= threshold) {
          loadMoreShows();
        }
      }

      scrollController.addListener(onScroll);
      return () => scrollController.removeListener(onScroll);
    }, [loadMoreShows, hasMore.value, isLoadingMore.value]);

    // Initial check for more shows
    useEffect(() {
      checkForMoreShows();
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body:
          allShows.value.isEmpty && !isInitialLoading.value
              ? Center(
                child: Text(AppLocalizations.of(context)!.noShowsAvailable),
              )
              : Stack(
                children: [
                  ShowsGrid(
                    scrollController: scrollController,
                    allShows: allShows.value,
                    hasMore: hasMore.value,
                    extractShow: extractShow,
                    ref: ref,
                  ),
                  if (isLoadingMore.value) const LoadingIndicator(),
                  if (errorMessage.value != null)
                    ErrorIndicator(
                      errorMessage: errorMessage.value!,
                      onRetry: loadMoreShows,
                    ),
                ],
              ),
    );
  }
}
