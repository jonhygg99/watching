import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:watching/features/watchlist/cache/watchlist_cache.dart';

/// Provider for watchlist cache
final watchlistCacheProvider = Provider<WatchlistCache>(
  (ref) => WatchlistCache(),
);
