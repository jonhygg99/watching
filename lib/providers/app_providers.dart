import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:watching/api/trakt/trakt_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'locale_provider.dart';
part 'app_providers.g.dart';

/// Provides a singleton instance of [TraktApi].
@riverpod
TraktApi traktApi(Ref ref) => TraktApi();

/// Provides the user's selected country code, persisted in SharedPreferences.
@riverpod
class CountryCode extends _$CountryCode {
  static const _prefsKey = 'country_code';
  @override
  String build() {
    _load();
    return 'ES';
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString(_prefsKey) ?? 'ES';
  }

  Future<void> setCountry(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, code);
    state = code;
  }
}

/// Provides the current username (null if not authenticated).
@riverpod
class Username extends _$Username {
  @override
  String? build() => null;
  void set(String? username) => state = username;
}

/// Provides the selected bottom navigation index.
@riverpod
class NavIndex extends _$NavIndex {
  @override
  int build() => 0;
  void set(int index) => state = index;
}

/// State for trending shows
class TrendingShowsState {
  final List<dynamic>? shows;
  final bool isLoading;
  final String? error;

  const TrendingShowsState({
    this.shows,
    this.isLoading = false,
    this.error,
  });

  TrendingShowsState copyWith({
    List<dynamic>? shows,
    bool? isLoading,
    String? error,
  }) {
    return TrendingShowsState(
      shows: shows ?? this.shows,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Notifier for trending shows
class TrendingShowsNotifier extends StateNotifier<TrendingShowsState> {
  final Ref _ref;
  
  TrendingShowsNotifier(this._ref) : super(const TrendingShowsState(isLoading: true)) {
    _loadTrendingShows();
  }

  Future<void> _loadTrendingShows() async {
    try {
      state = state.copyWith(isLoading: true);
      final api = _ref.read(traktApiProvider);
      final shows = await api.getTrendingShows();
      state = state.copyWith(
        shows: shows,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load trending shows',
      );
    }
  }
}

/// Provider for trending shows
final trendingShowsProvider = StateNotifierProvider<TrendingShowsNotifier, TrendingShowsState>((ref) {
  return TrendingShowsNotifier(ref);
});
