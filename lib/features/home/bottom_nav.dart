import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nextpay/core/navigation/navigation_provider.dart';
import 'package:nextpay/features/screens/home/home_screen.dart';
import 'package:nextpay/core/navigation/navigate.dart';

class BottomNavShell extends StatelessWidget {
  const BottomNavShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, nav, _) {
        return Scaffold(
          body: IndexedStack(
            index: nav.currentIndex,
            children: List.generate(nav.navigatorKeys.length, (index) {
              return Navigator(
                key: nav.navigatorKeys[index],
                onGenerateRoute: (settings) {
                  return MaterialPageRoute(
                    builder: (_) => _rootFor(index),
                    settings: settings,
                  );
                },
              );
            }),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: nav.currentIndex,
            onTap: nav.selectTab,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
              BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: 'Activity'),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
            ],
            type: BottomNavigationBarType.fixed,
          ),
        );
      },
    );
  }

  Widget _rootFor(int index) {
    switch (index) {
      case 0:
        return const HomeScreen();
      case 1:
        return const _PlaceholderTab(title: 'Search');
      case 2:
        return const _PlaceholderTab(title: 'Activity');
      case 3:
        return const _PlaceholderTab(title: 'Profile');
      default:
        return const HomeScreen();
    }
  }
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title)),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigate.to(
            context: context,
            page: DetailsPage(title: '$title detail'),
          );
        },
        child: const Icon(Icons.open_in_new),
      ),
    );
  }
}

class DetailsPage extends StatelessWidget {
  const DetailsPage({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigate.back(context: context),
        ),
      ),
      body: Center(child: Text('Details: $title')),
    );
  }
}


