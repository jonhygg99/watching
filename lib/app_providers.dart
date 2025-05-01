import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provides a singleton instance of ApiService.
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

/// Provides the user's selected country code, persisted in SharedPreferences.
final countryCodeProvider = StateNotifierProvider<CountryCodeNotifier, String>(
  (ref) => CountryCodeNotifier(),
);

class CountryCodeNotifier extends StateNotifier<String> {
  static const _prefsKey = 'country_code';
  CountryCodeNotifier() : super('ES') {
    _load();
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
final usernameProvider = StateProvider<String?>((ref) => null);

/// Provides the selected bottom navigation index.
final navIndexProvider = StateProvider<int>((ref) => 0);
