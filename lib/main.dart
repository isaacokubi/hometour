import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/api.dart';
import 'state/app_state.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/tours_screen.dart';
import 'screens/bookings_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HomeTourApp());
}

class HomeTourApp extends StatelessWidget {
  const HomeTourApp({super.key, this.autoBootstrap = true});

  final bool autoBootstrap;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (_) => AppState(ApiClient()),
        child: MaterialApp(
          title: 'Global Tours',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: const Color(0xFF15803D),
          ),
          home: AppShell(autoBootstrap: autoBootstrap),
        ),
      );
}

class AppShell extends StatefulWidget {
  const AppShell({super.key, this.autoBootstrap = true});

  final bool autoBootstrap;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;

  final pages = const [
    HomeScreen(),
    ToursScreen(),
    BookingsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.autoBootstrap) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<AppState>().bootstrap(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    if (state.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!state.authenticated) {
      return LoginScreen(onLoggedIn: () => setState(() {}));
    }

    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (v) => setState(() => index = v),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Tours',
          ),
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book),
            label: 'Bookings',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
