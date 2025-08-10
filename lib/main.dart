import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watching/providers/auth_provider.dart';
import 'package:watching/discover/discover_page.dart';

import 'providers/app_providers.dart';
import 'country_list.dart';
import 'splash_wrapper.dart';
import 'settings/settings.dart';
import 'watchlist/watchlist_page.dart';
import 'myshows/my_shows_page.dart';
import 'search/search_page.dart';

/// Main entry point for the Watching app.
/// Loads environment and initializes Riverpod.

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
    runApp(const ProviderScope(child: AppRoot()));
  } catch (e) {
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

  static final List<Widget> _pages = [
    const DiscoverPage(),
    const WatchlistPage(),
    const MyShowsPage(),
  ];

  static final List<BottomNavigationBarItem> _navItems = const [
    BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Discover'),
    BottomNavigationBarItem(
      icon: Icon(Icons.bookmark_border),
      label: 'Watchlist',
    ),
    BottomNavigationBarItem(icon: Icon(Icons.tv), label: 'My Shows'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the trending shows state
    final trendingShowsState = ref.watch(trendingShowsProvider);
    final navIndex = ref.watch(navIndexProvider);
    final countryCode = ref.watch(countryCodeProvider);

    final authAsync = ref.watch(authProvider);

    return authAsync.when(
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error:
          (err, stack) => Scaffold(
            body: Center(
              child: SelectableText.rich(
                TextSpan(
                  text: 'Error: ',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.red),
                  children: [
                    TextSpan(
                      text: '$err',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
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
                          countryCodes: allCountryCodes,
                          countryNames: allCountryNames,
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
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (_) => SearchPage(
                            initialTrendingShows: trendingShowsState.shows,
                          ),
                    ),
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // Main content area with IndexedStack
              Expanded(child: IndexedStack(index: navIndex, children: _pages)),
              // Bottom Navigation Bar
              BottomNavigationBar(
                items: _navItems,
                currentIndex: navIndex,
                selectedItemColor: Colors.redAccent,
                onTap:
                    (index) => ref.read(navIndexProvider.notifier).set(index),
              ),
            ],
          ),
        );
      },
    );
  }
}
