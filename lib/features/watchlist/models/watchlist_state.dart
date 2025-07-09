/// Model for watchlist state
class WatchlistState {
  final List<Map<String, dynamic>> items;
  final bool isLoading;
  final Object? error;
  final bool hasData;

  const WatchlistState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.hasData = false,
  });

  WatchlistState copyWith({
    List<Map<String, dynamic>>? items,
    bool? isLoading,
    Object? error,
    bool? hasData,
  }) {
    return WatchlistState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasData: hasData ?? this.hasData,
    );
  }
}
