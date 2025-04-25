import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'login_page.dart';
import 'splash_wrapper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'show_carousel.dart';

final apiService = ApiService(); // Instancia global

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    print('Cargando dotenv...');
    await dotenv.load(fileName: "/Users/jonathangomez/code_projects/watching/.env");
    print('dotenv cargado');
    runApp(const MaterialApp(
      title: 'API Variables Viewer',
      home: SplashWrapper(),
      debugShowCheckedModeBanner: false,
    ));
  } catch (e, st) {
    print('Error en main: $e');
    print(st);
    runApp(const MaterialApp(
      home: Scaffold(
        body: Center(child: Text('Error en main')),
      ),
    ));
  }
}

class MyApp extends StatefulWidget {
  final String? username;
  const MyApp({super.key, this.username});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TextEditingController _codeController = TextEditingController();
  String? _lastAuthUrl;
  bool _loadingToken = true;
  String? _username;

  @override
  void initState() {
    super.initState();
    _initToken();
  }

  Future<void> _initToken() async {
    print('Cargando token...');
    await apiService.loadToken();
    print('Token cargado');
    // Intentar obtener el usuario actual
    try {
      final response = await apiService.get('/users/me');
      if (response.statusCode == 200) {
        final data = response.body;
        final username = RegExp(r'"username"\s*:\s*"([^"]+)"').firstMatch(data)?.group(1);
        setState(() {
          _username = username;
          _loadingToken = false;
        });
      } else {
        setState(() {
          _username = null;
          _loadingToken = false;
        });
      }
    } catch (_) {
      setState(() {
        _username = null;
        _loadingToken = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Build ejecutado. _loadingToken=$_loadingToken');
    if (_loadingToken) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    print('Entrando en build principal de MyApp');
    if (_username == null) {
      // Si no está conectado, navegar a la pantalla de login/signue ep
      Future.microtask(() async {
        final result = await Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => LoginPage(username: _username)),
        );
        if (result == true) {
          await _initToken();
        }
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Trakt.tv')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('Botón flotante pulsado');
        },
        child: const Icon(Icons.bug_report),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => LoginPage(username: _username)),
                );
                // Puedes manejar el resultado del login aquí si lo deseas
                if (result == true) {
                  // Por ejemplo, refrescar el usuario
                  await _initToken();
                }
              },
              child: const Text('Login / Registro'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Usuario: ', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(_username ?? 'No conectado'),
              ],
            ),
            const Divider(height: 32),
            const SizedBox(height: 16),
            ShowCarousel(
              title: 'Trending Shows',
              future: apiService.getTrendingShows(),
              extractShow: (item) => item['show'],
              emptyText: 'No hay shows en tendencia.'
            ),
            const SizedBox(height: 16),
            ShowCarousel(
              title: 'Popular Shows',
              future: apiService.getPopularShows(),
              extractShow: (item) => item, // popular ya es el show
              emptyText: 'No hay shows populares.'
            ),
            const SizedBox(height: 16),
            ShowCarousel(
              title: 'Most Favorited (7 días)',
              future: apiService.getMostFavoritedShows(period: 'weekly'),
              extractShow: (item) => item['show'],
              emptyText: 'No hay shows más favoritos de la semana.'
            ),
            const SizedBox(height: 16),
            ShowCarousel(
              title: 'Most Favorited (30 días)',
              future: apiService.getMostFavoritedShows(period: 'monthly'),
              extractShow: (item) => item['show'],
              emptyText: 'No hay shows más favoritos del mes.'
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(child: CircularProgressIndicator()),
                );
                try {
                  final prefs = await SharedPreferences.getInstance();
                  final token = prefs.getString('access_token');
                  if (token == null || token.isEmpty) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No hay token para revocar.')),
                    );
                    return;
                  }
                  await apiService.revokeToken(token);
                  await apiService.clearToken();
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Token revocado correctamente.')),
                  );
                  if (mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                      (route) => false,
                    );
                  }
                } catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al revocar el token: ${e.toString()}')),
                  );
                }
              },
              child: const Text('Revocar token Trakt.tv'),
            ),

          ],
        ),
      ),
    );
  }
}
