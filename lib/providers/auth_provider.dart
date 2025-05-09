import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watching/services/trakt/trakt_api.dart';
import 'app_providers.dart';

/// Holds authentication state: loading, username, error.
class AuthState {
  final bool isLoading;
  final String? username;
  final String? error;

  const AuthState({this.isLoading = false, this.username, this.error});

  AuthState copyWith({bool? isLoading, String? username, String? error}) =>
      AuthState(
        isLoading: isLoading ?? this.isLoading,
        username: username ?? this.username,
        error: error ?? this.error,
      );
}

/// Riverpod AsyncNotifier for authentication logic.
class AuthNotifier extends AsyncNotifier<AuthState> {
  late final TraktApi _apiService;

  @override
  Future<AuthState> build() async {
    _apiService = ref.read(apiServiceProvider);
    return await _loadAuth();
  }

  Future<AuthState> _loadAuth() async {
    try {
      await _apiService.loadToken();
      final response = await _apiService.get('/users/me');
      if (response.statusCode == 200) {
        final data = response.body;
        final username = RegExp(
          r'"username"\s*:\s*"([^"]+)"',
        ).firstMatch(data)?.group(1);
        return AuthState(isLoading: false, username: username);
      } else {
        return const AuthState(isLoading: false, username: null);
      }
    } catch (e) {
      return AuthState(isLoading: false, username: null, error: e.toString());
    }
  }

  /// Attempts to log in using an OAuth authorization code (Trakt.tv flow).
  Future<void> loginWithCode(String code) async {
    state = const AsyncValue.loading();
    try {
      // Exchange code for token via API
      await _apiService.getToken(code);
      // Token is already saved in ApiService; now load user info
      state = AsyncValue.data(await _loadAuth());
    } catch (e) {
      state = AsyncValue.data(
        AuthState(isLoading: false, username: null, error: e.toString()),
      );
    }
  }

  /// Logs out the user by revoking the token via API and clearing local state.
  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token != null && token.isNotEmpty) {
        await _apiService.revokeToken(token);
      }
      // ApiService's revokeToken also calls clearToken
      state = const AsyncValue.data(
        AuthState(isLoading: false, username: null),
      );
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> reload() async {
    state = const AsyncValue.loading();
    state = AsyncValue.data(await _loadAuth());
  }
}

/// The main authentication provider.
final authProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
