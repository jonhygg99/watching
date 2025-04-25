import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart' show MyApp;
import 'login_page.dart';
import 'api_service.dart';

class SplashWrapper extends StatefulWidget {
  const SplashWrapper({super.key});

  @override
  State<SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await apiService.loadToken();
    try {
      final username = await _fetchUsername();
      if (username != null && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => MyApp(username: username)),
        );
        return;
      }
    } catch (e, st) {
      // Puedes loggear el error aquí si lo deseas
      debugPrint('Auth check error: $e\n$st');
    }
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  /// Devuelve el username si está autenticado, null si no
  Future<String?> _fetchUsername() async {
    final response = await apiService.get('/users/me');
    if (response.statusCode == 200) {
      final data = response.body;
      return RegExp(r'"username"\s*:\s*"([^"]+)"').firstMatch(data)?.group(1);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
