import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'country_list.dart';
import 'api_service.dart';
import 'login_page.dart';
import 'splash_wrapper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'show_carousel.dart';
import 'show_details/details_page.dart';
import 'settings/settings.dart';
import 'watchlist/watchlist_page.dart';
import 'myshows/my_shows_page.dart';
import 'discover/discover_page.dart';
import 'search/search_page.dart';

final apiService = ApiService(); // Instancia global

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    print('Cargando dotenv...');
    await dotenv.load(fileName: ".env");
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
        body: Center(child: Text('Unexpected error occurred.\nRestart the app.')),
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
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    WatchlistPage(),
    MyShowsPage(),
    DiscoverPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  String _countryCode = 'ES';
  // Usamos la lista completa de países desde country_list.dart
  List<String> get _countryCodes => allCountryCodes;
  Map<String, String> get _countryNames => allCountryNames;



  String countryFlag(String code) {
    // Devuelve el emoji de la bandera
    return String.fromCharCodes(code.toUpperCase().codeUnits.map((c) => 0x1F1E6 - 65 + c));
  }
  final TextEditingController _codeController = TextEditingController();
  String? _lastAuthUrl;
  bool _loadingToken = true;
  String? _username;

  @override
  void initState() {
    super.initState();
    _initToken();
    _loadCountry();
  }

  Future<void> _loadCountry() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _countryCode = prefs.getString('country_code') ?? 'ES';
    });
  }

  Future<void> _saveCountry(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('country_code', code);
    setState(() {
      _countryCode = code;
    });
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
      appBar: AppBar(
        title: const Text('Trakt.tv'),
        leading: IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SettingsPage(
                  countryCode: _countryCode,
                  countryCodes: _countryCodes,
                  countryNames: _countryNames,
                  username: _username,
                  onCountryChanged: (code) async {
                    await _saveCountry(code);
                    setState(() {});
                  },
                  onLoginRegister: () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => LoginPage(username: _username)),
                    );
                    if (result == true) {
                      await _initToken();
                      setState(() {});
                    }
                  },
                  onRevokeToken: () async {
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
                ),
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SearchPage()),
              );
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            label: 'Watchlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.tv),
            label: 'My Shows',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Discover',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.redAccent,
        onTap: _onItemTapped,
      ),
    );
  }
}
