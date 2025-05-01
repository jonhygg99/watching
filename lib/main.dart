import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watching/auth_provider.dart';
import 'country_list.dart';
import 'helpers/country_flag.dart';
import 'app_providers.dart';

import 'splash_wrapper.dart';
import 'settings/settings.dart';
import 'watchlist/watchlist_page.dart';
import 'myshows/my_shows_page.dart';
import 'discover/discover_page.dart';
import 'search/search_page.dart';
// Remove unused imports and global ApiService instance.

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
    runApp(const ProviderScope(child: AppRoot()));
  } catch (e, st) {
    runApp(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Unexpected error occurred.\nRestart the app.'),
          ),
        ),
      ),
    );
  }
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'API Variables Viewer',
      home: SplashWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  static const List<Widget> _pages = [
    DiscoverPage(),
    WatchlistPage(),
    MyShowsPage(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navIndex = ref.watch(navIndexProvider);
    final countryCode = ref.watch(countryCodeProvider);
    final countryCodes = allCountryCodes;
    final countryNames = allCountryNames;
    final authAsync = ref.watch(authProvider);

    return authAsync.when(
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error:
          (err, stack) => Scaffold(
            body: Center(
              child: Text('Error: $err', style: TextStyle(color: Colors.red)),
            ),
          ),
      data: (authState) {
        final username = authState.username;
        if (username == null) {
          // Should not happen, SplashWrapper will show login
          return const Scaffold(body: Center(child: Text('Not authenticated')));
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Trakt.tv'),
            leading: IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (_) => SettingsPage(
                          countryCode: countryCode,
                          countryCodes: countryCodes,
                          countryNames: countryNames,
                          username: username,
                          onCountryChanged: (code) async {
                            await ref
                                .read(countryCodeProvider.notifier)
                                .setCountry(code);
                          },
                          onLoginRegister: () async {
                            // Solo recarga el estado de auth, deja que SplashWrapper y Riverpod manejen la navegación
                            await ref.read(authProvider.notifier).reload();
                          },
                          onRevokeToken: () async {
                            if (context.mounted) {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (_) => const SplashWrapper(),
                                ),
                                (route) => false,
                              );
                            }
                            // Realiza el logout después de navegar para evitar el uso de ref en un widget destruido
                            await ref.read(authProvider.notifier).logout();
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
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => const SearchPage()));
                },
              ),
            ],
          ),
          body: _pages[navIndex],
          bottomNavigationBar: BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.explore),
                label: 'Discover',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bookmark_border),
                label: 'Watchlist',
              ),
              BottomNavigationBarItem(icon: Icon(Icons.tv), label: 'My Shows'),
            ],
            currentIndex: navIndex,
            selectedItemColor: Colors.redAccent,
            onTap: (index) => ref.read(navIndexProvider.notifier).state = index,
          ),
        );
      },
    );
  }
}

//   @override
//   Widget build(BuildContext context) {
//     print('Build ejecutado. _loadingToken=$_loadingToken');
//     if (_loadingToken) {
//       return const MaterialApp(
//         home: Scaffold(
//           body: Center(child: CircularProgressIndicator()),
//         ),
//       );
//     }

//     print('Entrando en build principal de MyApp');
//     if (_username == null) {
//       // Si no está conectado, navegar a la pantalla de login/signue ep
//       Future.microtask(() async {
//         final result = await Navigator.of(context).pushReplacement(
//           MaterialPageRoute(builder: (_) => LoginPage(username: _username)),
//         );
//         if (result == true) {
//           await _initToken();
//         }
//       });
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Trakt.tv'),
//         leading: IconButton(
//           icon: const Icon(Icons.settings),
//           onPressed: () {
//             Navigator.of(context).push(
//               MaterialPageRoute(
//                 builder: (_) => SettingsPage(
//                   countryCode: _countryCode,
//                   countryCodes: _countryCodes,
//                   countryNames: _countryNames,
//                   username: _username,
//                   onCountryChanged: (code) async {
//                     await _saveCountry(code);
//                     setState(() {});
//                   },
//                   onLoginRegister: () async {
//                     final result = await Navigator.of(context).push(
//                       MaterialPageRoute(builder: (_) => LoginPage(username: _username)),
//                     );
//                     if (result == true) {
//                       await _initToken();
//                       setState(() {});
//                     }
//                   },
//                   onRevokeToken: () async {
//                     showDialog(
//                       context: context,
//                       barrierDismissible: false,
//                       builder: (context) => const Center(child: CircularProgressIndicator()),
//                     );
//                     try {
//                       final prefs = await SharedPreferences.getInstance();
//                       final token = prefs.getString('access_token');
//                       if (token == null || token.isEmpty) {
//                         Navigator.of(context).pop();
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text('No hay token para revocar.')),
//                         );
//                         return;
//                       }
//                       await apiService.revokeToken(token);
//                       await apiService.clearToken();
//                       Navigator.of(context).pop();
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text('Token revocado correctamente.')),
//                       );
//                       if (mounted) {
//                         Navigator.of(context).pushAndRemoveUntil(
//                           MaterialPageRoute(builder: (_) => const LoginPage()),
//                           (route) => false,
//                         );
//                       }
//                     } catch (e) {
//                       Navigator.of(context).pop();
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text('Error al revocar el token: ${e.toString()}')),
//                       );
//                     }
//                   },
//                 ),
//               ),
//             );
//           },
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.search),
//             onPressed: () {
//               Navigator.of(context).push(
//                 MaterialPageRoute(builder: (_) => const SearchPage()),
//               );
//             },
//           ),
//         ],
//       ),
//       body: _pages[_selectedIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         items: const <BottomNavigationBarItem>[
//           BottomNavigationBarItem(
//             icon: Icon(Icons.explore),
//             label: 'Discover',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.bookmark_border),
//             label: 'Watchlist',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.tv),
//             label: 'My Shows',
//           ),
//         ],
//         currentIndex: _selectedIndex,
//         selectedItemColor: Colors.redAccent,
//         onTap: _onItemTapped,
//       ),
//     );
//   }
// }
