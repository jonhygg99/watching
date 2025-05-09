import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:watching/providers/watchlist_providers.dart';
import 'package:watching/watchlist/watchlist_show_item.dart';

/// Main Watchlist Page - Riverpod + Hooks
class WatchlistPage extends HookConsumerWidget {
  const WatchlistPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchlistAsync = ref.watch(watchlistProvider);
    final animatingOut = useState<Set<String>>({});

    Future<void> refreshWatchlist() async {
      ref.invalidate(watchlistProvider);
    }

    return RefreshIndicator(
      onRefresh: refreshWatchlist,
      child: Column(
        children: [
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
                Consumer(
                  builder: (context, ref, _) {
                    final type = ref.watch(watchlistTypeProvider);
                    return DropdownButton<WatchlistType>(
                      value: type,
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
                      onChanged: (newType) {
                        if (newType != null) {
                          ref.read(watchlistTypeProvider.notifier).state =
                              newType;
                          ref.invalidate(watchlistProvider);
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: watchlistAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (error, stack) => Center(
                    child: SelectableText.rich(
                      TextSpan(
                        text: 'Error: ',
                        style: const TextStyle(color: Colors.red),
                        children: [TextSpan(text: error.toString())],
                      ),
                    ),
                  ),
              data: (items) {
                if (items.isEmpty) {
                  return const Center(
                    child: Text(
                      '¡Felicidades! Has visto todas tus series pendientes 🎉',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return WatchlistShowItem(
                      item: item,
                      animatingOut: animatingOut.value,
                      onFullyWatched: (traktId) {
                        // Aquí puedes refrescar la lista o animar la salida
                        // refreshWatchlist();
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
