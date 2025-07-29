import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:watching/features/watchlist/enums/watchlist_type.dart';
import 'package:watching/features/watchlist/providers/watchlist_providers.dart';
import 'package:watching/features/watchlist/state/watchlist_notifier.dart';
import 'package:watching/watchlist/loading_skeleton.dart';
import 'package:watching/watchlist/watchlist_show_item.dart';

/// Main Watchlist Page - Riverpod + Hooks
class WatchlistPage extends ConsumerStatefulWidget {
  const WatchlistPage({super.key});

  @override
  ConsumerState<WatchlistPage> createState() => _WatchlistPageState();
}

class _WatchlistPageState extends ConsumerState<WatchlistPage> {
  final ValueNotifier<Set<String>> animatingOut = ValueNotifier<Set<String>>({});
  final ValueNotifier<int> stateUpdater = ValueNotifier<int>(0);
  
  @override
  void dispose() {
    animatingOut.dispose();
    stateUpdater.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    // Watch the watchlist state
    final watchlistState = ref.watch(watchlistProvider);
    final watchlistItems = ref.watch(watchlistItemsProvider);
    final isLoading = ref.watch(watchlistLoadingProvider);
    final error = ref.watch(watchlistErrorProvider);

    // Refresh the watchlist data
    Future<void> refreshWatchlist() async {
      await ref.read(watchlistProvider.notifier).refresh();
    }

    // Handle type change
    void handleTypeChange(WatchlistType? newType) {
      if (newType != null) {
        ref.read(watchlistTypeProvider.notifier).state = newType;
        refreshWatchlist();
      }
    }

    // Show error dialog if there's an error
    if (error != null && !watchlistState.hasData) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Error'),
                content: Text(error.toString()),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      refreshWatchlist();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
        );
      });
    }

    return RefreshIndicator(
      onRefresh: refreshWatchlist,
      child: Column(
        children: [
          // Type selector
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 16.0,
            ),
            child: Row(
              children: [
                const Text(
                  'Tipo:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                DropdownButton<WatchlistType>(
                  value: ref.watch(watchlistTypeProvider),
                  items: const [
                    DropdownMenuItem(
                      value: WatchlistType.shows,
                      child: Text('Series'),
                    ),
                    DropdownMenuItem(
                      value: WatchlistType.movies,
                      child: Text('Películas'),
                    ),
                  ],
                  onChanged: handleTypeChange,
                ),
              ],
            ),
          ),

          // Loading indicator (shown only on initial load)
          if (isLoading && !watchlistState.hasData)
            const LinearProgressIndicator(minHeight: 2),

          // Main content
          Expanded(
            child: Builder(
              builder: (context) {
                // Show empty state if no items and not loading
                if (watchlistItems.isEmpty && !isLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'No hay elementos en tu lista de seguimiento.',
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                // Show shimmer/skeleton loading if no data yet
                if (watchlistItems.isEmpty && isLoading) {
                  return const LoadingSkeleton();
                }

                // Show the list of items
                return ListView.builder(
                  itemCount: watchlistItems.length,
                  itemBuilder: (context, index) {
                    final item = watchlistItems[index];
                    final ids = item['show']?['ids'] ?? item['ids'];
                    final traktId = ids?['trakt']?.toString() ?? ids?['slug'];

                    if (traktId == null) return const SizedBox.shrink();

                    // Skip if this item is already being animated out
                    if (animatingOut.value.contains(traktId)) {
                      return const SizedBox.shrink();
                    }
                    
                    return WatchlistShowItem(
                      key: ValueKey(traktId),
                      item: item,
                      animatingOut: animatingOut.value,
                      onFullyWatched: (traktId) async {
                        if (!mounted) return;
                        
                        // Immediately update the animatingOut set to remove the show
                        setState(() {
                          animatingOut.value = {...animatingOut.value, traktId};
                        });
                        
                        try {
                          // Update the show progress in the background
                          await ref.read(watchlistProvider.notifier).updateShowProgress(traktId);
                        } catch (e) {
                          debugPrint('Error updating show progress: $e');
                          // If there's an error, remove the show from animatingOut so it can be retried
                          if (mounted) {
                            setState(() {
                              animatingOut.value = {...animatingOut.value}..remove(traktId);
                            });
                          }
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
