import 'package:flutter/material.dart';
import 'package:ipj417c_b_2024/providers/navigation_provider.dart';
import 'package:ipj417c_b_2024/views/home/home_screen.dart';
import 'package:ipj417c_b_2024/views/profile/profile_screen.dart';
import 'package:provider/provider.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, child) {
        return Scaffold(
          body: _getBodyWidget(navigationProvider.currentIndex),
          bottomNavigationBar: BottomNavigationBar(
            //backgroundColor: Colors.amber,
            type: BottomNavigationBarType.fixed,
            currentIndex: navigationProvider.currentIndex,
            onTap: (index) => navigationProvider.setIndex(index),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.search), label: 'Search'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.favorite), label: 'Favorites'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person), label: 'Profile'),
            ],
          ),
        );
      },
    );
  }
}

Widget _getBodyWidget(int index) {
  switch (index) {
    case 0:
      return const HomeScreen();
    case 1:
      return const Center(child: Text('Search Screen'));
    case 2:
      return const Center(child: Text('Favorites Screen'));
    case 3:
      return const ProfileScreen();
    default:
      return const Center(child: Text('Unknown Screen'));
  }
}
