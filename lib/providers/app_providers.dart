import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:watching/api/trakt/trakt_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
