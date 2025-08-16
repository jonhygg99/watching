import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watching/shared/constants/colors.dart';

// Custom theme mode enum to avoid conflict with Flutter's ThemeMode
enum AppThemeMode { light, dark, system }

final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<AppThemeMode> {
  static const String _themeKey = 'theme_mode';
  late SharedPreferences _prefs;

  ThemeNotifier() : super(AppThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    _prefs = await SharedPreferences.getInstance();
    final themeIndex = _prefs.getInt(_themeKey);
    if (themeIndex != null &&
        themeIndex >= 0 &&
        themeIndex < AppThemeMode.values.length) {
      state = AppThemeMode.values[themeIndex];
    }
  }

  Future<void> setTheme(AppThemeMode theme) async {
    state = theme;
    await _prefs.setInt(_themeKey, theme.index);
  }
}

ThemeData getLightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: scaffoldLightBackgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    ),
  );
}

ThemeData getDarkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blueGrey,
    scaffoldBackgroundColor: scaffoldDarkBackgroundColor,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[850],
      foregroundColor: Colors.white,
    ),
  );
}
