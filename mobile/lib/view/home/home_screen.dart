import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:newztable/view/bookmarks/bookmarks_screen.dart';
import 'package:newztable/view/feed/feed_screen.dart';
import 'package:newztable/view/search/search_screen.dart';
import 'package:newztable/view/settings/settings_screen.dart';
import 'package:newztable/viewmodel/bookmark_view_model.dart';
import 'package:newztable/viewmodel/feed_view_model.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    FeedScreen(),
    SearchScreen(),
    BookmarksScreen(),
    SettingsScreen()
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      context.read<FeedViewModel>().fetchFeed();
      context.read<BookmarkViewModel>().fetchBookmarks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations:[   
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded), 
            label: 'Home'
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search_rounded), 
            label: 'Search'
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_outline),
            selectedIcon: Icon(Icons.bookmark_rounded), 
            label: 'Saved'
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded), 
            label: 'Settings'
          )
        ] 
      ),
    );
  }
}