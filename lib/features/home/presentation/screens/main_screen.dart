import 'package:flutter/material.dart';
import 'package:anti_food_waste_app/features/home/presentation/screens/home_content.dart';
import 'package:anti_food_waste_app/features/search/presentation/screens/search_screen.dart';
import 'package:anti_food_waste_app/features/orders/presentation/screens/orders_screen.dart';
import 'package:anti_food_waste_app/features/favorites/presentation/screens/favorites_screen.dart';
import 'package:anti_food_waste_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:anti_food_waste_app/shared/widgets/bottom_navigation.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeContent(),
    const MyOrdersScreen(),
    const SearchScreen(),
    const FavoritesScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
