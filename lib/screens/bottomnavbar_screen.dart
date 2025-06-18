import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'favorites_screen.dart';
import 'orderhistory_screen.dart';

class BottomNavBar extends StatefulWidget {
  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;


  final List<Widget> _screens = [
    HomeScreen(),
    CartScreen(),
    WishlistScreen(),
    ProfileScreen(),
    OrderHistoryScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped, //on
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.white),
            label: "Home",
            backgroundColor: Color(0xFF476A88),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart, color: Colors.white),
            label: "Cart",
            backgroundColor: Color(0xFF476A88),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border_outlined, color: Colors.white),
            label: "Wishlist",
            backgroundColor: Color(0xFF476A88),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.white),
            label: "Profile",
            backgroundColor: Color(0xFF476A88),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history, color: Colors.white),
            label: "Order History",
            backgroundColor: Color(0xFF476A88),
          ),
        ],
      ),
    );
  }
}
