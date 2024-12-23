import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/radio_model.dart';
import '../../../view_models/home_view_model.dart';
import '../login/login_screen.dart';
import '../register/register_screen.dart';
import 'widgets/radio_tile.dart';

class HomeScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late Future<void> radiosFuture;

  @override
  void initState() {
    super.initState();
    // ignore: discarded_futures
    radiosFuture = ref.read(homeViewModelProvider).fetchRadios();
  }

  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeViewModel = ref.watch(homeViewModelProvider);

    // List widget untuk konten tiap tab
    final List<Widget> _pages = <Widget>[
      _buildFavPage(homeViewModel),
      _buildSearchPage(homeViewModel),
      _buildAccountPage(),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        foregroundColor: Theme.of(context).colorScheme.primary,
        leading: const Icon(Icons.radio),
        title: Text(
          _selectedIndex == 0
              ? 'Favorite'
              : _selectedIndex == 1
                  ? 'Search'
                  : 'Account',
        ),
        actions: [
          PopupMenuButton<String>(
            color: Theme.of(context).colorScheme.surface,
            icon: const Icon(Icons.more_vert),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'settings',
                child: TextButton.icon(
                  onPressed: null,
                  icon: Icon(
                    Icons.settings,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  label: Text(
                    'Settings',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
              PopupMenuItem<String>(
                value: 'about',
                child: TextButton.icon(
                  onPressed: null,
                  icon: Icon(
                    Icons.info,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  label: Text(
                    'About',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
            onSelected: (String value) async {
              if (value == 'settings') {
                await Navigator.pushNamed(context, 'settings');
              } else if (value == 'about') {
                await Navigator.pushNamed(context, 'about');
              }
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Theme.of(context).colorScheme.primary,
        selectedFontSize: 10,
        selectedIconTheme:
            const IconThemeData(color: Colors.amberAccent, size: 30),
        selectedItemColor: Colors.amberAccent,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Favorite',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
      ),
      body: _pages[_selectedIndex],
    );
  }

  Widget _buildAccountPage() {
    final user = FirebaseAuth.instance.currentUser;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
            child: Icon(
              Icons.person_outline,
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            user != null ? 'Welcome, ${user.email}' : 'Account Page',
            style: TextStyle(
              fontSize: 24,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;

              if (user != null) {
                // Logout user
                try {
                  await FirebaseAuth.instance.signOut();
                  // Refresh UI or navigate to login screen
                  await Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                } catch (e) {
                  // Handle logout error
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error during logout: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } else {
                // Navigate to login screen
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              foregroundColor: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: Text(user != null ? 'Logout' : 'Login'),
          ),
          if (user == null)
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterScreen()),
                ); // Navigate to register
              },
              child: const Text(
                'Register',
                style: TextStyle(
                  color: Colors.amberAccent,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFavPage(HomeViewModel homeViewModel) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'You need to log in to view favorites.',
              style: TextStyle(
                fontSize: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: const Text('Login'),
            ),
          ],
        ),
      );
    }

    return FutureBuilder<List<RadioModel>>(
      future: homeViewModel.fetchFavorites(user.uid), // Fetch favorite radios
      builder: (context, snapshot) {
        final favorites = snapshot.data;

        if (favorites == null || favorites.isEmpty) {
          return Center(
            child: Text(
              'No favorites added yet!',
              style: TextStyle(
                fontSize: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        }

        return ListView.builder(
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final radio = favorites[index];
            return RadioTile(
              name: radio.name,
              url: radio.url,
              favicon: radio.favicon,
              tags: radio.tags,
            );
          },
        );
      },
    );
  }

  Widget _buildSearchPage(HomeViewModel homeViewModel) {
    return FutureBuilder(
      future: radiosFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error,
                  color: Theme.of(context).colorScheme.error,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  'Something went wrong!',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 24,
                  ),
                ),
                TextButton(
                  onPressed: () async => homeViewModel.fetchRadios(),
                  child: Text(
                    'Try Again',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      decorationColor: Theme.of(context).colorScheme.primary,
                      decorationStyle: TextDecorationStyle.solid,
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          return RefreshIndicator(
            backgroundColor: Theme.of(context).colorScheme.primary,
            color: Theme.of(context).colorScheme.inversePrimary,
            onRefresh: () async => homeViewModel.fetchRadios(),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    onChanged: (query) {
                      homeViewModel.searchQuery.value = query;
                    },
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    decoration: InputDecoration(
                      labelStyle: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      labelText: 'Search Radios',
                      prefixIcon: Icon(
                        Icons.search,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .primary, // Color for the border when not focused
                          width: 1.5, // Optional: Border width
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .secondary, // Color for the border when focused
                          width: 2.0, // Optional: Border width
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ValueListenableBuilder<String>(
                    valueListenable: homeViewModel.searchQuery,
                    builder: (context, value, child) {
                      final radios = homeViewModel.radios
                          .where(
                            (radio) => radio.name
                                .toLowerCase()
                                .contains(value.toLowerCase()),
                          )
                          .toList();
                      return ListView.builder(
                        itemCount: radios.length,
                        itemBuilder: (context, index) {
                          final radio = radios[index];
                          return RadioTile(
                            name: radio.name,
                            url: radio.url,
                            favicon: radio.favicon,
                            tags: radio.tags,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
