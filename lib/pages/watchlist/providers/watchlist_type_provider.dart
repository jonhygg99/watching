import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:watching/pages/watchlist/enums/watchlist_type.dart';

/// Provider for selected watchlist type
final watchlistTypeProvider = StateProvider<WatchlistType>(
  (ref) => WatchlistType.shows,
);
